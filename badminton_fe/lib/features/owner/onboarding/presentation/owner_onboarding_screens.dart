import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../auth/data/auth_api_service.dart';
import '../../../auth/data/auth_session_store.dart';
import '../../../auth/presentation/auth_flow_screens.dart';

/// FE-15: Man hinh O-01 Dang ky chu san (2 buoc: Thong tin ca nhan -> Ten co so & Giay phep <= 5 MB).
class OwnerRegisterScreen extends StatefulWidget {
  final VoidCallback onSubmittedToStatus;

  const OwnerRegisterScreen({
    super.key,
    required this.onSubmittedToStatus,
  });

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  int _step = 1;
  final TextEditingController _ownerNameCtrl =
      TextEditingController(text: 'Nguyễn Văn Minh');
  final TextEditingController _emailCtrl =
      TextEditingController(text: 'minh.owner@gmail.com');
  final TextEditingController _phoneCtrl =
      TextEditingController(text: '0909888777');
  final TextEditingController _passCtrl =
      TextEditingController(text: 'Owner1234');
  final TextEditingController _venueNameCtrl =
      TextEditingController(text: 'Cụm Sân Cầu Lông Phú Thọ Arena');
  final TextEditingController _taxCodeCtrl =
      TextEditingController(text: '0316892410');
  final TextEditingController _addressCtrl =
      TextEditingController(text: '219 Lý Thường Kiệt, Quận 11, TP.HCM');

  String? _uploadedLicenseFile = 'giay_phep_kinh_doanh_san_cau_long.pdf';
  bool _submitting = false;
  String? _errorBanner;

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _venueNameCtrl.dispose();
    _taxCodeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitOwnerRegistration() async {
    setState(() {
      _submitting = true;
      _errorBanner = null;
    });

    try {
      final challenge = await AuthApiService.instance.registerOwner(
        fullName: _ownerNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
        businessName: _venueNameCtrl.text.trim(),
        taxCode: _taxCodeCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        licenseFileName: _uploadedLicenseFile ?? 'giay_phep_kinh_doanh.pdf',
      );
      if (!mounted) return;
      setState(() => _submitting = false);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationScreen(
            email: _emailCtrl.text.trim(),
            role: UserRole.owner,
            otpTicket: challenge.otpTicket,
            purpose: OtpPurpose.verifyEmail,
            onVerified: (_) {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => OwnerApplicationStatusScreen(
                    onEnterOwnerShell: widget.onSubmittedToStatus,
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
        _submitting = false;
        _errorBanner = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('O-01 Đăng ký Chủ sân (Bước $_step/2)'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(t.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: t.actionPrimary,
                          borderRadius: BorderRadius.circular(t.space1),
                        ),
                      ),
                    ),
                    SizedBox(width: t.space2),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: _step == 2 ? t.actionPrimary : t.surfaceMuted,
                          borderRadius: BorderRadius.circular(t.space1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.space4),

                if (_errorBanner != null) ...[
                  Container(
                    padding: EdgeInsets.all(t.space3),
                    decoration: BoxDecoration(
                      color: t.statusCancelled.background,
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      border: Border.all(color: t.statusCancelled.border),
                    ),
                    child: Text(
                      _errorBanner!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: t.statusCancelled.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: t.space4),
                ],

                if (_step == 1) ...[
                  Text(
                    'Bước 1: Thông tin người đại diện',
                    style: textTheme.headlineSmall,
                  ),
                  SizedBox(height: t.space4),
                  AppTextField(
                    label: 'Họ và tên chủ sân',
                    controller: _ownerNameCtrl,
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  SizedBox(height: t.space4),
                  AppTextField(
                    label: 'Email liên hệ & nhận mã OTP',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                  ),
                  SizedBox(height: t.space4),
                  AppTextField(
                    label: 'Số điện thoại',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  SizedBox(height: t.space4),
                  AppTextField(
                    label: 'Mật khẩu quản lý',
                    controller: _passCtrl,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline_rounded,
                  ),
                  SizedBox(height: t.space6),
                  AppButton(
                    label: 'Tiếp tục sang Bước 2',
                    expandWidth: true,
                    onPressed: () => setState(() => _step = 2),
                  ),
                ] else ...[
                  Text(
                    'Bước 2: Hồ sơ cơ sở & Giấy phép',
                    style: textTheme.headlineSmall,
                  ),
                  SizedBox(height: t.space4),
                  AppTextField(
                    label: 'Tên cụm sân cầu lông dự kiến',
                    controller: _venueNameCtrl,
                    prefixIcon: Icons.stadium_outlined,
                  ),
                  SizedBox(height: t.space4),
                  AppTextField(
                    label: 'Mã số hộ kinh doanh / doanh nghiệp',
                    controller: _taxCodeCtrl,
                    prefixIcon: Icons.assignment_outlined,
                  ),
                  SizedBox(height: t.space4),
                  AppTextField(
                    label: 'Địa chỉ cơ sở',
                    controller: _addressCtrl,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  SizedBox(height: t.space4),
                  Text(
                    'Giấy phép kinh doanh (PDF / JPG tối đa 5 MB)',
                    style: textTheme.labelLarge,
                  ),
                  SizedBox(height: t.space2),
                  Container(
                    padding: EdgeInsets.all(t.space4),
                    decoration: BoxDecoration(
                      color: t.surfaceCard,
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      border: Border.all(color: t.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: t.actionPrimary,
                        ),
                        SizedBox(width: t.space3),
                        Expanded(
                          child: Text(
                            _uploadedLicenseFile ?? 'Chưa chọn tệp đính kèm',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        AppButton(
                          label: _uploadedLicenseFile == null
                              ? 'Chọn tệp'
                              : 'Đổi tệp',
                          variant: AppButtonVariant.secondary,
                          onPressed: () {
                            setState(() {
                              _uploadedLicenseFile =
                                  'giay_phep_ho_kinh_doanh_2026.pdf';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.space6),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Quay lại Bước 1',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => setState(() => _step = 1),
                        ),
                      ),
                      SizedBox(width: t.space3),
                      Expanded(
                        child: AppButton(
                          label: 'Gửi hồ sơ & xác thực OTP',
                          variant: AppButtonVariant.primary,
                          loading: _submitting,
                          onPressed: _uploadedLicenseFile != null
                              ? _submitOwnerRegistration
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 3 trang thai ho so chu san O-02 theo 03-danh-sach-man-hinh.md.
enum OwnerApplicationState { pending, rejected, approved }

/// FE-15: Man hinh O-02 Trang thai ho so chu san (dong bo tu GET /api/v1/owner/applications/latest).
class OwnerApplicationStatusScreen extends StatefulWidget {
  final VoidCallback onEnterOwnerShell;

  const OwnerApplicationStatusScreen({
    super.key,
    required this.onEnterOwnerShell,
  });

  @override
  State<OwnerApplicationStatusScreen> createState() =>
      _OwnerApplicationStatusScreenState();
}

class _OwnerApplicationStatusScreenState
    extends State<OwnerApplicationStatusScreen> {
  OwnerApplicationState _state = OwnerApplicationState.pending;
  String? _rejectReasonFromServer;

  @override
  void initState() {
    super.initState();
    _syncFromBackend();
  }

  Future<void> _syncFromBackend() async {
    try {
      final latest = await AuthApiService.instance.fetchLatestOwnerApplication();
      if (!mounted || latest == null) return;
      setState(() {
        _rejectReasonFromServer = latest.rejectReason;
        switch (latest.status.toUpperCase()) {
          case 'APPROVED':
            _state = OwnerApplicationState.approved;
          case 'REJECTED':
            _state = OwnerApplicationState.rejected;
          default:
            _state = OwnerApplicationState.pending;
        }
      });
    } catch (_) {
      // Giữ trạng thái mặc định khi chạy offline
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    final CourtBookingStatus chipStatus;
    final String chipLabel;
    final String headline;
    final String body;

    switch (_state) {
      case OwnerApplicationState.pending:
        chipStatus = CourtBookingStatus.pending;
        chipLabel = 'Đang chờ Admin phê duyệt';
        headline = 'Hồ sơ chủ sân của bạn đã được tiếp nhận';
        body =
            'Quản trị viên sẽ kiểm tra giấy phép kinh doanh trong vòng 24 giờ làm việc và gửi thông báo đẩy ngay khi hoàn tất.';
      case OwnerApplicationState.rejected:
        chipStatus = CourtBookingStatus.cancelledOrSuspended;
        chipLabel = 'Cần bổ sung hồ sơ';
        headline = 'Hồ sơ đăng ký chủ sân bị từ chối';
        body = _rejectReasonFromServer != null &&
                _rejectReasonFromServer!.isNotEmpty
            ? 'Lý do từ Admin: $_rejectReasonFromServer'
            : 'Lý do từ Admin: Ảnh chụp giấy phép hộ kinh doanh bị mờ góc phải. Bạn hãy tải lại bản chụp rõ nét hơn và gửi lại.';
      case OwnerApplicationState.approved:
        chipStatus = CourtBookingStatus.activeConfirmed;
        chipLabel = 'Đã phê duyệt chính thức';
        headline = 'Chúc mừng! Tài khoản Chủ sân đã kích hoạt';
        body =
            'Bạn có thể bắt đầu tạo cơ sở sân (O-05), ghim tọa độ bản đồ (O-06), cấu hình sân con (O-07) và bảng giá (O-08).';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('O-02 Trạng thái hồ sơ Chủ sân')),
      body: Padding(
        padding: EdgeInsets.all(t.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: t.space2,
                  runSpacing: t.space2,
                  children: [
                    ChoiceChip(
                      label: const Text('Chờ duyệt'),
                      selected: _state == OwnerApplicationState.pending,
                      onSelected: (_) => setState(
                        () => _state = OwnerApplicationState.pending,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Bị từ chối'),
                      selected: _state == OwnerApplicationState.rejected,
                      onSelected: (_) => setState(
                        () => _state = OwnerApplicationState.rejected,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Đã duyệt'),
                      selected: _state == OwnerApplicationState.approved,
                      onSelected: (_) => setState(
                        () => _state = OwnerApplicationState.approved,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.space6),
                Container(
                  padding: EdgeInsets.all(t.space6),
                  decoration: BoxDecoration(
                    color: t.surfaceCard,
                    borderRadius: BorderRadius.circular(t.radiusCard),
                    border: Border.all(color: t.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusChip(status: chipStatus, customLabel: chipLabel),
                      SizedBox(height: t.space4),
                      Text(headline, style: textTheme.headlineSmall),
                      SizedBox(height: t.space2),
                      Text(body, style: textTheme.bodyMedium),
                      SizedBox(height: t.space6),
                      if (_state == OwnerApplicationState.rejected)
                        AppButton(
                          label: 'Bổ sung giấy phép & Nộp lại hồ sơ',
                          expandWidth: true,
                          onPressed: () => setState(
                            () => _state = OwnerApplicationState.pending,
                          ),
                        ),
                      if (_state == OwnerApplicationState.approved)
                        AppButton(
                          label: 'Vào bảng điều khiển Chủ sân (Owner Shell)',
                          expandWidth: true,
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            widget.onEnterOwnerShell();
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
