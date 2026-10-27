import 'package:flutter/foundation.dart';
import '../../../core/router/app_router.dart';
import 'google_auth_service.dart';

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

/// Ngu canh dung chung cho man hinh S-04 OTP theo 03-danh-sach-man-hinh.md.
enum OtpPurpose {
  verifyEmail('Xác thực email đăng ký', 'VERIFY_EMAIL'),
  login2fa('Xác thực đăng nhập thiết bị mới', 'LOGIN'),
  resetPassword('Xác thực đặt lại mật khẩu', 'RESET_PASSWORD'),
  changePassword('Xác thực đổi mật khẩu', 'CHANGE_PASSWORD');

  final String title;
  final String backendCode;
  const OtpPurpose(this.title, this.backendCode);
}

/// Thong tin User RBAC tra ve tu Backend (UserSummaryResponse).
class AuthenticatedUserProfile {
  final int id;
  final String? firebaseUid;
  final String authProvider;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String status;
  final Set<String> roles;
  final Set<String> permissions;
  final String? ownerApplicationStatus;
  final String? ownerRejectReason;

  const AuthenticatedUserProfile({
    required this.id,
    this.firebaseUid,
    required this.authProvider,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.status,
    required this.roles,
    required this.permissions,
    this.ownerApplicationStatus,
    this.ownerRejectReason,
  });

  factory AuthenticatedUserProfile.fromJson(Map<String, dynamic> json) {
    final rawRoles = (json['roles'] as List?) ?? const [];
    final rawPerms = (json['permissions'] as List?) ?? const [];
    return AuthenticatedUserProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firebaseUid: json['firebaseUid'] as String?,
      authProvider: (json['authProvider'] as String?) ?? 'LOCAL',
      fullName: (json['fullName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      status: (json['status'] as String?) ?? 'ACTIVE',
      roles: rawRoles.map((e) => e.toString()).toSet(),
      permissions: rawPerms.map((e) => e.toString()).toSet(),
      ownerApplicationStatus: json['ownerApplicationStatus'] as String?,
      ownerRejectReason: json['ownerRejectReason'] as String?,
    );
  }

  UserRole get primaryUserRole {
    if (roles.contains('ADMIN')) return UserRole.admin;
    if (roles.contains('OWNER')) return UserRole.owner;
    return UserRole.customer;
  }
}

/// FE-10: Quan ly phien dang nhap RBAC, token, firebaseUid, deviceId va thiet bi tin cay.
class AuthSessionStore extends ChangeNotifier {
  static final AuthSessionStore instance = AuthSessionStore();

  String? _accessToken;
  String? _refreshToken;
  UserRole _role = UserRole.customer;
  String _email = 'customer@badminton.vn';
  String _fullName = 'Nguyễn Văn Khách';
  String? _firebaseUid;
  String _authProvider = 'LOCAL';
  Set<String> _permissions = const {'BOOKING_CREATE', 'BOOKING_VIEW_OWN', 'CHAT_AI_USE'};
  String? _ownerApplicationStatus;
  String? _ownerRejectReason;
  String _deviceId = 'AND-PIXEL7-9821';
  final Set<String> _trustedDevices = {'AND-PIXEL7-9821'};

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserRole get role => _role;
  String get email => _email;
  String get fullName => _fullName;
  String? get firebaseUid => _firebaseUid;
  String get authProvider => _authProvider;
  Set<String> get permissions => _permissions;
  String? get ownerApplicationStatus => _ownerApplicationStatus;
  String? get ownerRejectReason => _ownerRejectReason;
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
    String? fullName,
    String? firebaseUid,
    String? authProvider,
    Set<String>? permissions,
    String? ownerApplicationStatus,
    String? ownerRejectReason,
    bool trustCurrentDevice = false,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _role = role;
    _email = email;
    if (fullName != null && fullName.isNotEmpty) {
      _fullName = fullName;
    }
    _firebaseUid = firebaseUid;
    if (authProvider != null) {
      _authProvider = authProvider;
    }
    if (permissions != null) {
      _permissions = permissions;
    }
    _ownerApplicationStatus = ownerApplicationStatus;
    _ownerRejectReason = ownerRejectReason;
    if (trustCurrentDevice) {
      _trustedDevices.add(_deviceId);
    }
    notifyListeners();
  }

  void saveFromUserProfile({
    required String accessToken,
    required String refreshToken,
    required AuthenticatedUserProfile profile,
    bool trustCurrentDevice = false,
  }) {
    saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      role: profile.primaryUserRole,
      email: profile.email,
      fullName: profile.fullName,
      firebaseUid: profile.firebaseUid,
      authProvider: profile.authProvider,
      permissions: profile.permissions,
      ownerApplicationStatus: profile.ownerApplicationStatus,
      ownerRejectReason: profile.ownerRejectReason,
      trustCurrentDevice: trustCurrentDevice,
    );
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
    _firebaseUid = null;
    GoogleAuthService.instance.signOut();
    notifyListeners();
  }
}
