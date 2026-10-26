import 'package:flutter/foundation.dart';
import '../../../core/router/app_router.dart';

/// Muc do manh cua mat khau dung cho S-03 va S-06 (khong chi dung mau).
enum PasswordStrength {
  empty('Chưa nhập', 0.0),
  weak('Yếu (cần tối thiểu 8 ký tự)', 0.25),
  fair('Trung bình (thêm chữ hoa hoặc số)', 0.55),
  strong('Mạnh (đạt chuẩn bảo mật)', 1.0);

  final String label;
  final double progress;
  const PasswordStrength(this.label, this.progress);

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 8) return PasswordStrength.weak;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    if ((hasUpper && hasDigit) || (hasDigit && hasSpecial)) {
      return PasswordStrength.strong;
    }
    return PasswordStrength.fair;
  }
}

/// Ngữ cảnh dùng chung cho màn hình S-04 OTP theo 03-danh-sach-man-hinh.md.
enum OtpPurpose {
  verifyEmail('Xác thực email đăng ký'),
  login2fa('Xác thực đăng nhập thiết bị mới'),
  resetPassword('Xác thực đặt lại mật khẩu'),
  changePassword('Xác thực đổi mật khẩu');

  final String title;
  const OtpPurpose(this.title);
}

/// FE-10: Quan ly phien dang nhap, token, deviceId va danh sach thiet bi tin cay.
class AuthSessionStore extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  UserRole _role = UserRole.customer;
  String _email = 'huuda@gmail.com';
  String _deviceId = 'AND-PIXEL7-9821';
  final Set<String> _trustedDevices = {'AND-PIXEL7-9821'};

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserRole get role => _role;
  String get email => _email;
  String get deviceId => _deviceId;

  bool isDeviceTrusted(String id) => _trustedDevices.contains(id);

  /// Che email theo quy uoc S-04: hu***@gmail.com
  static String maskEmail(String rawEmail) {
    final parts = rawEmail.trim().split('@');
    if (parts.length != 2) return rawEmail;
    final name = parts[0];
    final domain = parts[1];
    final prefix = name.length >= 2 ? name.substring(0, 2) : name;
    return '$prefix***@$domain';
  }

  void saveSession({
    required String accessToken,
    required String refreshToken,
    required UserRole role,
    required String email,
    bool trustCurrentDevice = false,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _role = role;
    _email = email;
    if (trustCurrentDevice) {
      _trustedDevices.add(_deviceId);
    }
    notifyListeners();
  }

  void setDeviceId(String newDeviceId) {
    _deviceId = newDeviceId;
    notifyListeners();
  }

  Future<bool> tryRefreshSession() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) return false;
    _accessToken = 'refreshed_${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
    return true;
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }
}
