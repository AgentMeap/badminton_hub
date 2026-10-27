import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/otp_input.dart';
import '../../../core/widgets/status_chip.dart';
import '../../owner/onboarding/presentation/owner_onboarding_screens.dart';
import '../data/auth_api_service.dart';
import '../data/auth_session_store.dart';

/// FE-11: Man hinh S-01 Splash kiem tra refresh token de vao thang Shell hoac S-02.
class SplashScreen extends StatefulWidget {
  final AuthSessionStore sessionStore;
  final VoidCallback onAuthenticated;
  final VoidCallback onUnauthenticated;

  const SplashScreen({
    super.key,
    required this.sessionStore,
    required this.onAuthenticated,
    required this.onUnauthenticated,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final ok = await widget.sessionStore.tryRefreshSession();
    setState(() => _checking = false);
    if (ok) {
      widget.onAuthenticated();
    } else {
      widget.onUnauthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(t.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: t.actionPrimary,
                  borderRadius: BorderRadius.circular(t.radiusCard),
                ),
                child: Icon(
                  Icons.sports_tennis_rounded,
                  size: 38,
                  color: t.onActionPrimary,
                ),
              ),
              SizedBox(height: t.space4),
              Text(
                'Badminton Court',
                style: textTheme.headlineSmall,
              ),
              SizedBox(height: t.space2),
              Text(
                _checking
                    ? 'S-01: Đang kiểm tra phiên đăng nhập (POST /auth/refresh)...'
                    : 'Phiên đã hết hạn. Đang chuyển đến màn hình đăng nhập...',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: t.space6),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(t.actionPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// FE-11: Man hinh S-02 Dang nhap RBAC (chon Nguoi choi / Chu san, 5-tap logo cho Admin).
class LoginScreen extends StatefulWidget {
  final ValueChanged<UserRole> onLoginSuccess;
  final VoidCallback onOpenOwnerStatus;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onOpenOwnerStatus,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.customer;
  int _logoTapCount = 0;
  bool _adminUnlocked = false;
  bool _requireOtpDevice = false;
  bool _loading = false;
  bool _googleLoading = false;

  final TextEditingController _emailCtrl =
      TextEditingController(text: 'customer@badminton.vn');
  final TextEditingController _passCtrl =
      TextEditingController(text: 'Badminton123');
  String? _emailError;
  String? _passError;
  String? _bannerError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      _bannerError = null;
      final currentEmail = _emailCtrl.text.trim();
      if (currentEmail == 'customer@badminton.vn' ||
          currentEmail == 'owner@badminton.vn' ||
          currentEmail == 'admin@badminton.vn') {
        switch (role) {
          case UserRole.customer:
            _emailCtrl.text = 'customer@badminton.vn';
          case UserRole.owner:
            _emailCtrl.text = 'owner@badminton.vn';
          case UserRole.admin:
            _emailCtrl.text = 'admin@badminton.vn';
        }
      }
    });
  }

  void _handleLogoTap() {
    _logoTapCount += 1;
    if (_logoTapCount >= 5 && !_adminUnlocked) {
      setState(() {
        _adminUnlocked = true;
      });
      _selectRole(UserRole.admin);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã bật cổng đăng nhập Quản trị viên (Admin).'),
        ),
      );
    }
  }

  Future<void> _submitLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    setState(() {
      _bannerError = null;
      _emailError =
          email.contains('@') ? null : 'Email không hợp lệ. Ví dụ: ten@gmail.com';
      _passError =
          pass.length >= 8 ? null : 'Mật khẩu cần tối thiểu 8 ký tự.';
    });
    if (_emailError != null || _passError != null) return;

    setState(() => _loading = true);
    try {
      final decision = await AuthApiService.instance.login(
        role: _selectedRole,
        email: email,
        password: pass,
        simulateUntrustedDevice: _requireOtpDevice,
      );
      if (!mounted) return;
      setState(() => _loading = false);

      if (decision.otpRequired) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OtpVerificationScreen(
              email: email,
              role: _selectedRole,
              otpTicket: decision.otpChallenge?.otpTicket,
              purpose: OtpPurpose.login2fa,
              onVerified: (_) {
                Navigator.of(context).pop();
                _completePostLoginNavigation();
              },
            ),
          ),
        );
        return;
      }

      _completePostLoginNavigation();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _bannerError = e.message;
      });
    }
  }

  void _completePostLoginNavigation() {
    final appStatus = AuthSessionStore.instance.ownerApplicationStatus;
    if (_selectedRole == UserRole.owner &&
        appStatus != null &&
        appStatus != 'APPROVED') {
      widget.onOpenOwnerStatus();
      return;
    }
    widget.onLoginSuccess(_selectedRole);
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _googleLoading = true;
      _bannerError = null;
    });
    try {
      final profile = await AuthApiService.instance.signInWithGoogleFirebase(
        email: 'google.player@gmail.com',
        fullName: 'Người chơi Google Firebase',
      );
      if (!mounted) return;
      setState(() => _googleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng nhập Google (Firebase UID: ${profile.firebaseUid ?? "đã đồng bộ"}) thành công.',
          ),
        ),
      );
      widget.onLoginSuccess(UserRole.customer);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _googleLoading = false;
        _bannerError = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('S-02 Đăng nhập hệ thống'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(t.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _handleLogoTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: t.actionPrimary,
                          borderRadius: BorderRadius.circular(t.radiusControl),
                        ),
                        child: Icon(
                          Icons.sports_tennis_rounded,
                          color: t.onActionPrimary,
                          size: 26,
                        ),
                      ),
                      SizedBox(width: t.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chào mừng bạn quay lại',
                              style: textTheme.headlineSmall,
                            ),
                            Text(
                              'Chạm 5 lần vào biểu tượng vợt để mở cổng Admin',
                              style: textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: t.space6),

                Text('Chọn vai trò đăng nhập (RBAC)', style: textTheme.labelLarge),
                SizedBox(height: t.space2),
                Wrap(
                  spacing: t.space2,
                  runSpacing: t.space2,
                  children: [
                    _RoleSegmentButton(
                      label: 'Tôi là người chơi',
                      icon: Icons.person_outline_rounded,
                      selected: _selectedRole == UserRole.customer,
                      onTap: () => _selectRole(UserRole.customer),
                    ),
                    _RoleSegmentButton(
                      label: 'Tôi là chủ sân',
                      icon: Icons.stadium_outlined,
                      selected: _selectedRole == UserRole.owner,
                      onTap: () => _selectRole(UserRole.owner),
                    ),
                    if (_adminUnlocked)
                      _RoleSegmentButton(
                        label: 'Quản trị viên (Admin)',
                        icon: Icons.admin_panel_settings_outlined,
                        selected: _selectedRole == UserRole.admin,
                        onTap: () => _selectRole(UserRole.admin),
                      ),
                  ],
                ),
                SizedBox(height: t.space6),

                if (_bannerError != null) ...[
                  Container(
                    padding: EdgeInsets.all(t.space3),
                    decoration: BoxDecoration(
                      color: t.statusCancelled.background,
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      border: Border.all(color: t.statusCancelled.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: t.statusCancelled.foreground,
                          size: 20,
                        ),
                        SizedBox(width: t.space2),
                        Expanded(
                          child: Text(
                            _bannerError!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: t.statusCancelled.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.space4),
                ],

                AppTextField(
                  label: 'Email đăng nhập',
                  hintText: 'nhap@email.com',
                  controller: _emailCtrl,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                SizedBox(height: t.space4),
                AppTextField(
                  label: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu của bạn',
                  controller: _passCtrl,
                  errorText: _passError,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                ),
                SizedBox(height: t.space2),

                Row(
                  children: [
                    Checkbox(
                      value: _requireOtpDevice,
                      activeColor: t.actionPrimary,
                      onChanged: (v) =>
                          setState(() => _requireOtpDevice = v ?? false),
                    ),
                    Expanded(
                      child: Text(
                        'Giả lập đăng nhập từ thiết bị lạ (yêu cầu OTP S-04)',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: 'Quên mật khẩu? (S-05)',
                    variant: AppButtonVariant.text,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ForgotPasswordScreen(
                            initialEmail: _emailCtrl.text.trim(),
                            role: _selectedRole,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: t.space3),

                AppButton(
                  label: 'Đăng nhập (${_selectedRole.label})',
                  expandWidth: true,
                  loading: _loading,
                  onPressed: _submitLogin,
                  variant: AppButtonVariant.primary,
                ),

                if (_selectedRole == UserRole.customer) ...[
                  SizedBox(height: t.space3),
                  AppButton(
                    label: 'Tiếp tục với Google (Firebase Auth)',
                    leadingIcon: Icons.account_circle_outlined,
                    expandWidth: true,
                    loading: _googleLoading,
                    variant: AppButtonVariant.secondary,
                    onPressed: _handleGoogleSignIn,
                  ),
                ],

                SizedBox(height: t.space6),
                const Divider(),
                SizedBox(height: t.space4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: AppButton(
                        label: 'Đăng ký Người chơi (S-03)',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CustomerRegisterScreen(
                                onRegistered: () =>
                                    widget.onLoginSuccess(UserRole.customer),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: t.space2),
                    Flexible(
                      child: AppButton(
                        label: 'Đăng ký Chủ sân (O-01)',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => OwnerRegisterScreen(
                                onSubmittedToStatus: widget.onOpenOwnerStatus,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// FE-12: Man hinh S-03 Dang ky Customer (2 loai: Google Firebase Auth & Dang ky thuong + OTP SMTP).
class CustomerRegisterScreen extends StatefulWidget {
  final VoidCallback onRegistered;

  const CustomerRegisterScreen({
    super.key,
    required this.onRegistered,
  });

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  String? _nameErr;
  String? _emailErr;
  String? _phoneErr;
  String? _passErr;
  String? _confirmErr;
  String? _apiErrorBanner;
  bool _submitting = false;
  bool _googleSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerViaGoogleFirebase() async {
    setState(() {
      _googleSubmitting = true;
      _apiErrorBanner = null;
    });
    try {
      final email = _emailCtrl.text.trim().contains('@')
          ? _emailCtrl.text.trim()
          : 'google.newuser@gmail.com';
      final name = _nameCtrl.text.trim().length >= 2
          ? _nameCtrl.text.trim()
          : 'Khách hàng Google Firebase';

      final profile = await AuthApiService.instance.signInWithGoogleFirebase(
        email: email,
        fullName: name,
      );
      if (!mounted) return;
      setState(() => _googleSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã đăng ký qua Google & lưu Firebase Authentication (UID: ${profile.firebaseUid ?? "OK"}).',
          ),
        ),
      );
      Navigator.of(context).pop();
      widget.onRegistered();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _googleSubmitting = false;
        _apiErrorBanner = e.message;
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    setState(() {
      _apiErrorBanner = null;
      _nameErr = name.length >= 2 ? null : 'Bạn hãy nhập họ và tên đầy đủ.';
      _emailErr = email.contains('@') ? null : 'Email chưa đúng định dạng.';
      _phoneErr = RegExp(r'^0\d{9}$').hasMatch(phone)
          ? null
          : 'Số điện thoại cần gồm 10 chữ số, bắt đầu bằng số 0.';
      _passErr = PasswordStrength.evaluate(pass) == PasswordStrength.weak ||
              pass.isEmpty
          ? 'Mật khẩu cần tối thiểu 8 ký tự, nên có chữ hoa và chữ số.'
          : null;
      _confirmErr = (confirm == pass && confirm.isNotEmpty)
          ? null
          : 'Mật khẩu nhập lại không khớp.';
    });

    if (_nameErr != null ||
        _emailErr != null ||
        _phoneErr != null ||
        _passErr != null ||
        _confirmErr != null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final challenge = await AuthApiService.instance.registerCustomer(
        fullName: name,
        email: email,
        phone: phone,
        password: pass,
      );
      if (!mounted) return;
      setState(() => _submitting = false);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationScreen(
            email: email,
            role: UserRole.customer,
            otpTicket: challenge.otpTicket,
            purpose: OtpPurpose.verifyEmail,
            onVerified: (_) {
              final uid = AuthSessionStore.instance.firebaseUid ?? 'đã lưu';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Xác thực OTP thành công! Tài khoản đã lưu vào Firebase Authentication ($uid).',
                  ),
                ),
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.onRegistered();
            },
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _apiErrorBanner = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final strength = PasswordStrength.evaluate(_passCtrl.text);

    return Scaffold(
      appBar: AppBar(title: const Text('S-03 Đăng ký tài khoản Người chơi')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(t.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loại 1: Đăng ký nhanh bằng Google (Firebase)',
                  style: textTheme.labelLarge,
                ),
                SizedBox(height: t.space2),
                AppButton(
                  label: 'Đăng ký qua Google (Firebase Authentication)',
                  leadingIcon: Icons.account_circle_outlined,
                  expandWidth: true,
                  loading: _googleSubmitting,
                  variant: AppButtonVariant.secondary,
                  onPressed: _registerViaGoogleFirebase,
                ),
                SizedBox(height: t.space4),
                const Divider(),
                SizedBox(height: t.space3),
                Text(
                  'Loại 2: Đăng ký bằng Email (Nhận OTP qua SMTP -> Lưu Firebase Auth)',
                  style: textTheme.labelLarge,
                ),
                SizedBox(height: t.space4),

                if (_apiErrorBanner != null) ...[
                  Container(
                    padding: EdgeInsets.all(t.space3),
                    decoration: BoxDecoration(
                      color: t.statusCancelled.background,
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      border: Border.all(color: t.statusCancelled.border),
                    ),
                    child: Text(
                      _apiErrorBanner!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: t.statusCancelled.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: t.space4),
                ],

                AppTextField(
                  label: 'Họ và tên',
                  hintText: 'Nguyễn Văn An',
                  controller: _nameCtrl,
                  errorText: _nameErr,
                  prefixIcon: Icons.badge_outlined,
                ),
                SizedBox(height: t.space4),
                AppTextField(
                  label: 'Email nhận mã OTP',
                  hintText: 'an.nguyen@gmail.com',
                  controller: _emailCtrl,
                  errorText: _emailErr,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                SizedBox(height: t.space4),
                AppTextField(
                  label: 'Số điện thoại',
                  hintText: '0901234567',
                  controller: _phoneCtrl,
                  errorText: _phoneErr,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                SizedBox(height: t.space4),
                AppTextField(
                  label: 'Mật khẩu',
                  hintText: 'Tối thiểu 8 ký tự (chữ hoa + số)',
                  controller: _passCtrl,
                  errorText: _passErr,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: t.space2),
                _PasswordStrengthBar(strength: strength),
                SizedBox(height: t.space4),
                AppTextField(
                  label: 'Nhập lại mật khẩu',
                  hintText: 'Nhập lại mật khẩu phía trên',
                  controller: _confirmCtrl,
                  errorText: _confirmErr,
                  isPassword: true,
                  prefixIcon: Icons.verified_user_outlined,
                ),
                SizedBox(height: t.space6),
                AppButton(
                  label: 'Đăng ký và nhận mã OTP (S-04)',
                  expandWidth: true,
                  loading: _submitting,
                  onPressed: _submit,
                  variant: AppButtonVariant.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// FE-13: Man hinh S-04 Nhap OTP dung chung (che email hu***@gmail.com, tin cay thiet bi, goi API verify).
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final OtpPurpose purpose;
  final UserRole role;
  final String? otpTicket;
  final ValueChanged<bool> onVerified;
  final ValueChanged<String>? onVerifiedWithCode;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.purpose,
    this.role = UserRole.customer,
    this.otpTicket,
    required this.onVerified,
    this.onVerifiedWithCode,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool _trustDevice = true;
  int _attempts = 0;
  String? _errorText;
  int _secondsLeft = 60;
  bool _verifying = false;
  String? _currentTicket;
  String _lastCode = '123456';

  @override
  void initState() {
    super.initState();
    _currentTicket = widget.otpTicket;
  }

  Future<void> _verifyOtpCode(String code) async {
    _lastCode = code;
    if (code == '000000') {
      setState(() {
        _attempts += 1;
        _errorText = 'Mã OTP chưa chính xác. Bạn còn ${3 - _attempts} lần thử.';
      });
      return;
    }

    if (widget.purpose == OtpPurpose.resetPassword ||
        widget.purpose == OtpPurpose.changePassword) {
      widget.onVerifiedWithCode?.call(code);
      widget.onVerified(_trustDevice);
      return;
    }

    setState(() {
      _verifying = true;
      _errorText = null;
    });

    try {
      if (widget.purpose == OtpPurpose.verifyEmail) {
        await AuthApiService.instance.verifyEmailOtp(
          role: widget.role,
          email: widget.email,
          otpTicket: _currentTicket,
          code: code,
          trustDevice: _trustDevice,
        );
      } else if (widget.purpose == OtpPurpose.login2fa) {
        await AuthApiService.instance.verifyLoginOtp(
          role: widget.role,
          otpTicket: _currentTicket ?? 'offline-ticket',
          code: code,
          trustDevice: _trustDevice,
        );
      }

      if (!mounted) return;
      setState(() => _verifying = false);
      widget.onVerifiedWithCode?.call(code);
      widget.onVerified(_trustDevice);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _attempts += 1;
        _errorText = e.message;
      });
    }
  }

  Future<void> _handleResendOtp() async {
    try {
      final challenge = await AuthApiService.instance.resendOtp(
        role: widget.role,
        email: widget.email,
        purpose: widget.purpose,
      );
      if (!mounted) return;
      setState(() {
        _currentTicket = challenge.otpTicket;
        _attempts = 0;
        _errorText = null;
        _secondsLeft = challenge.cooldownSeconds;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(challenge.message)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final maskedEmail = AuthSessionStore.maskEmail(widget.email);
    final isLocked = _attempts >= 3;

    return Scaffold(
      appBar: AppBar(title: Text('S-04 ${widget.purpose.title}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(t.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(
                  status: isLocked
                      ? CourtBookingStatus.cancelledOrSuspended
                      : CourtBookingStatus.pending,
                  customLabel: isLocked
                      ? 'Đã khóa mã OTP (sai 3 lần)'
                      : 'Thiết bị: ${AuthSessionStore.instance.deviceId}',
                ),
                SizedBox(height: t.space3),
                Text(
                  'Nhập mã xác thực 6 chữ số',
                  style: textTheme.headlineSmall,
                ),
                SizedBox(height: t.space2),
                Text(
                  'Mã OTP 6 số đã được gửi qua SMTP tới địa chỉ $maskedEmail. Khi xác thực thành công, tài khoản được đồng bộ lên Firebase Authentication.',
                  style: textTheme.bodyMedium,
                ),
                SizedBox(height: t.space6),
                OtpInput(
                  onCompleted: _verifyOtpCode,
                  isLocked: isLocked,
                  errorText: _errorText,
                  secondsRemaining: _secondsLeft,
                  onResend: _handleResendOtp,
                ),
                SizedBox(height: t.space4),
                Row(
                  children: [
                    Checkbox(
                      value: _trustDevice,
                      activeColor: t.actionPrimary,
                      onChanged: (v) =>
                          setState(() => _trustDevice = v ?? false),
                    ),
                    Expanded(
                      child: Text(
                        'Tin cậy thiết bị này trong 30 ngày tới',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.space4),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Giả lập hết 60s đếm ngược',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => setState(() => _secondsLeft = 0),
                      ),
                    ),
                    SizedBox(width: t.space2),
                    Expanded(
                      child: AppButton(
                        label: 'Xác nhận ngay',
                        variant: AppButtonVariant.primary,
                        loading: _verifying,
                        onPressed: isLocked
                            ? null
                            : () => _verifyOtpCode(_lastCode),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// FE-14: Man hinh S-05 Quen mat khau -> S-04 OTP -> S-06 Dat lai mat khau moi.
class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;
  final UserRole role;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
    this.role = UserRole.customer,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailCtrl;
  bool _sentBannerVisible = false;
  bool _sending = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetOtp() async {
    final email = _emailCtrl.text.trim().isEmpty
        ? 'customer@badminton.vn'
        : _emailCtrl.text.trim();

    setState(() {
      _sending = true;
      _errorText = null;
    });

    try {
      final challenge = await AuthApiService.instance.forgotPassword(
        role: widget.role,
        email: email,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sentBannerVisible = true;
      });

      String capturedCode = '123456';
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationScreen(
            email: email,
            role: widget.role,
            otpTicket: challenge.otpTicket,
            purpose: OtpPurpose.resetPassword,
            onVerifiedWithCode: (code) => capturedCode = code,
            onVerified: (_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => ResetPasswordScreen(
                    email: email,
                    role: widget.role,
                    otpTicket: challenge.otpTicket,
                    otpCode: capturedCode,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _errorText = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('S-05 Quên mật khẩu')),
      body: Padding(
        padding: EdgeInsets.all(t.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khôi phục mật khẩu tài khoản',
                  style: textTheme.headlineSmall,
                ),
                SizedBox(height: t.space2),
                Text(
                  'Nhập email bạn đã dùng đăng ký. Hệ thống sẽ gửi mã OTP 6 chữ số qua SMTP để đặt lại mật khẩu.',
                  style: textTheme.bodyMedium,
                ),
                SizedBox(height: t.space6),
                AppTextField(
                  label: 'Email tài khoản',
                  hintText: 'nhap@email.com',
                  controller: _emailCtrl,
                  errorText: _errorText,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                if (_sentBannerVisible) ...[
                  SizedBox(height: t.space4),
                  Container(
                    padding: EdgeInsets.all(t.space4),
                    decoration: BoxDecoration(
                      color: t.statusActive.background,
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      border: Border.all(color: t.statusActive.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.mark_email_read_outlined,
                          color: t.statusActive.foreground,
                        ),
                        SizedBox(width: t.space3),
                        Expanded(
                          child: Text(
                            'Nếu email tồn tại trong hệ thống, mã xác thực đã được gửi.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: t.statusActive.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: t.space6),
                AppButton(
                  label: 'Gửi mã xác thực & sang S-04',
                  expandWidth: true,
                  loading: _sending,
                  onPressed: _sendResetOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// FE-14: Man hinh S-06 Dat lai mat khau moi (sau khi xac thuc S-04 OTP).
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final UserRole role;
  final String? otpTicket;
  final String otpCode;

  const ResetPasswordScreen({
    super.key,
    this.email = 'customer@badminton.vn',
    this.role = UserRole.customer,
    this.otpTicket,
    this.otpCode = '123456',
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  String? _errorText;
  bool _saving = false;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveNewPassword() async {
    if (_newPassCtrl.text.length < 8) {
      setState(() => _errorText = 'Mật khẩu mới cần tối thiểu 8 ký tự.');
      return;
    }
    if (_newPassCtrl.text != _confirmCtrl.text) {
      setState(() => _errorText = 'Mật khẩu nhập lại không khớp.');
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await AuthApiService.instance.resetPassword(
        role: widget.role,
        email: widget.email,
        otpTicket: widget.otpTicket,
        code: widget.otpCode,
        newPassword: _newPassCtrl.text,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đặt lại mật khẩu thành công (đã đồng bộ Firebase Auth & thu hồi phiên cũ). Bạn hãy đăng nhập lại.',
          ),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final strength = PasswordStrength.evaluate(_newPassCtrl.text);

    return Scaffold(
      appBar: AppBar(title: const Text('S-06 Đặt lại mật khẩu mới')),
      body: Padding(
        padding: EdgeInsets.all(t.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Mật khẩu mới',
                  hintText: 'Nhập tối thiểu 8 ký tự',
                  controller: _newPassCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_reset_rounded,
                  onChanged: (_) => setState(() => _errorText = null),
                ),
                SizedBox(height: t.space2),
                _PasswordStrengthBar(strength: strength),
                SizedBox(height: t.space4),
                AppTextField(
                  label: 'Nhập lại mật khẩu mới',
                  hintText: 'Xác nhận mật khẩu mới',
                  controller: _confirmCtrl,
                  errorText: _errorText,
                  isPassword: true,
                  prefixIcon: Icons.check_circle_outline_rounded,
                ),
                SizedBox(height: t.space6),
                AppButton(
                  label: 'Lưu mật khẩu mới',
                  expandWidth: true,
                  loading: _saving,
                  onPressed: _saveNewPassword,
                  variant: AppButtonVariant.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final PasswordStrength strength;
  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final Color barColor;
    switch (strength) {
      case PasswordStrength.empty:
        barColor = t.borderSubtle;
      case PasswordStrength.weak:
        barColor = t.actionDanger;
      case PasswordStrength.fair:
        barColor = t.actionSecondary;
      case PasswordStrength.strong:
        barColor = t.actionPrimary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(t.space1),
          child: LinearProgressIndicator(
            value: strength.progress,
            minHeight: 6,
            backgroundColor: t.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        SizedBox(height: t.space1),
        Text(
          'Độ mạnh mật khẩu: ${strength.label}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _RoleSegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleSegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      borderRadius: BorderRadius.circular(t.radiusControl),
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: t.minTapTarget),
        padding: EdgeInsets.symmetric(
          horizontal: t.space4,
          vertical: t.space2,
        ),
        decoration: BoxDecoration(
          color: selected ? t.statusActive.background : t.surfaceCard,
          borderRadius: BorderRadius.circular(t.radiusControl),
          border: Border.all(
            color: selected ? t.actionPrimary : t.borderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? t.statusActive.foreground : t.textSecondary,
            ),
            SizedBox(width: t.space2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? t.statusActive.foreground : t.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
