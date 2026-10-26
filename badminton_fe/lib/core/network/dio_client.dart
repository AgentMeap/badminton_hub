import 'dart:convert';
import 'dart:io';

import '../config/env.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();
typedef RefreshTokenHandler = Future<bool> Function();
typedef UnauthorizedCallback = void Function();

/// Client goi HTTP chuan hoa theo 01-kien-truc.md:
/// - Gan Authorization Bearer token
/// - Tu dong thu refresh 1 lan khi gap 401
/// - Chuyen loi BE {code, message} thanh ApiException
class DioClient {
  final String baseUrl;
  final TokenProvider? getAccessToken;
  final RefreshTokenHandler? onRefreshToken;
  final UnauthorizedCallback? onForceLogout;
  final HttpClient _httpClient;

  DioClient({
    this.baseUrl = Env.apiBaseUrl,
    this.getAccessToken,
    this.onRefreshToken,
    this.onForceLogout,
  }) : _httpClient = HttpClient()..connectionTimeout = Env.connectTimeout;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _send('GET', path, queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters:
          (queryParameters != null && queryParameters.isNotEmpty)
              ? queryParameters
              : null,
    );

    try {
      final request = await _httpClient.openUrl(method, uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final token = await getAccessToken?.call();
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      if (body != null) {
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close().timeout(Env.receiveTimeout);
      final rawBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == HttpStatus.unauthorized && !isRetry) {
        final refreshed = await onRefreshToken?.call() ?? false;
        if (refreshed) {
          return await _send(
            method,
            path,
            queryParameters: queryParameters,
            body: body,
            isRetry: true,
          );
        }
        onForceLogout?.call();
      }

      final decoded = rawBody.isNotEmpty
          ? (jsonDecode(rawBody) as Map<String, dynamic>)
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }

      throw ApiException.fromJson(decoded, statusCode: response.statusCode);
    } on SocketException {
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Không có kết nối mạng. Bạn hãy kiểm tra Wi-Fi hoặc 4G.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        code: 'UNKNOWN',
        message: 'Đã xảy ra lỗi không xác định. Bạn hãy thử lại.',
      );
    }
  }
}
