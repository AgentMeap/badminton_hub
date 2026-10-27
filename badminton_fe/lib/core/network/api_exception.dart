/// Cac ma loi nghiep vu tu Backend theo tai lieu 01-kien-truc.md va ErrorCode.java.
enum ApiErrorCode {
  slotAlreadyBooked('SLOT_ALREADY_BOOKED'),
  holdExpired('HOLD_EXPIRED'),
  emailNotVerified('AUTH_EMAIL_NOT_VERIFIED'),
  authInvalidCredentials('AUTH_INVALID_CREDENTIALS'),
  emailAlreadyExists('EMAIL_ALREADY_EXISTS'),
  emailRegisteredWithGoogle('EMAIL_REGISTERED_WITH_GOOGLE'),
  accountLocked('ACCOUNT_LOCKED'),
  otpInvalid('OTP_INVALID'),
  otpExpired('OTP_EXPIRED'),
  otpTooManyAttempts('OTP_MAX_ATTEMPTS'),
  otpCooldown('OTP_COOLDOWN'),
  otpHourlyLimit('OTP_HOURLY_LIMIT'),
  tokenExpired('TOKEN_EXPIRED'),
  refreshTokenInvalid('REFRESH_TOKEN_INVALID'),
  firebaseTokenInvalid('FIREBASE_TOKEN_INVALID'),
  unauthorized('UNAUTHORIZED'),
  forbidden('FORBIDDEN'),
  validationError('VALIDATION_ERROR'),
  networkError('NETWORK_ERROR'),
  unknown('UNKNOWN');

  final String raw;
  const ApiErrorCode(this.raw);

  static ApiErrorCode fromString(String? code) {
    if (code == null) return ApiErrorCode.unknown;
    if (code == 'EMAIL_NOT_VERIFIED') return ApiErrorCode.emailNotVerified;
    if (code == 'OTP_TOO_MANY_ATTEMPTS') return ApiErrorCode.otpTooManyAttempts;
    for (final item in ApiErrorCode.values) {
      if (item.raw == code) return item;
    }
    return ApiErrorCode.unknown;
  }
}

/// Ngoai le chuan hoa cho moi loi tra ve tu Backend ApiResponse {success, error: {code, message, details}}.
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  ApiErrorCode get errorCode => ApiErrorCode.fromString(code);

  bool get shouldReloadSlots =>
      errorCode == ApiErrorCode.slotAlreadyBooked ||
      errorCode == ApiErrorCode.holdExpired;

  bool get isAccountLocked => errorCode == ApiErrorCode.accountLocked;

  bool get isOtpLocked => errorCode == ApiErrorCode.otpTooManyAttempts;

  bool get isNetworkError => errorCode == ApiErrorCode.networkError;

  factory ApiException.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    final errorObj = json['error'];
    if (errorObj is Map<String, dynamic>) {
      final parsedFields = <String, String>{};
      final detailsList = errorObj['details'];
      if (detailsList is List) {
        for (final item in detailsList) {
          if (item is Map<String, dynamic>) {
            final f = item['field']?.toString();
            final issue = item['issue']?.toString();
            if (f != null && issue != null) {
              parsedFields[f] = issue;
            }
          }
        }
      }
      return ApiException(
        code: (errorObj['code'] as String?) ?? 'UNKNOWN',
        message: (errorObj['message'] as String?) ??
            'Không thể xử lý yêu cầu. Bạn hãy thử lại sau.',
        statusCode: statusCode,
        fieldErrors: parsedFields,
      );
    }

    return ApiException(
      code: (json['code'] as String?) ?? 'UNKNOWN',
      message: (json['message'] as String?) ??
          'Không thể kết nối máy chủ. Bạn hãy thử lại sau.',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => 'ApiException($code, status: $statusCode): $message';
}
