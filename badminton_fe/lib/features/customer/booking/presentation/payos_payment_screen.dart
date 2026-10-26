import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../data/customer_booking_models.dart';
import 'booking_detail_screen.dart';

/// FE-31: Man hinh C-08 Cong thanh toan PayOS (VietQR Open Banking):
/// - Giao dien chuan PayOS Gateway: Ma VietQR dong, Ngan hang thu huong, So tai khoan,
///   Noi dung chuyen khoan chinh xac kem nut sao chep nhanh (Copy).
/// - Dong ho dem nguoc giu cho 10 phut tiep tuc dem.
/// - Bat Return URL / Webhook event:
///   + Thanh cong (PayOS status = PAID) -> Man ket qua thanh cong kem nut xem ve QR (C-10)
///   + That bai / Huy (PayOS status = CANCELLED) -> Man ket qua bao loi kem nut thanh toan lai
class PayOsPaymentScreen extends StatefulWidget {
  final CustomerBookingOrder order;
  final int paymentAmountVnd;
  final int initialRemainingSeconds;

  const PayOsPaymentScreen({
    super.key,
    required this.order,
    required this.paymentAmountVnd,
    this.initialRemainingSeconds = 600,
  });

  @override
  State<PayOsPaymentScreen> createState() => _PayOsPaymentScreenState();
}

class _PayOsPaymentScreenState extends State<PayOsPaymentScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isProcessing = false;

  // Trang thai ket qua giao dich PayOS
  // null = dang o giao dien thanh toan PayOS
  // true = thanh cong (PAID / returnUrl)
  // false = that bai / huy (CANCELLED / cancelUrl)
  bool? _paymentSuccess;
  String? _payOsTransactionId;

  // Thong tin thanh toan VietQR theo chuan PayOS
  static const String _bankName = 'MBBank (Ngan hang Quan Doi)';
  static const String _bankCode = 'MB';
  static const String _accountNumber = '9820268899';
  static const String _accountName = 'BADMINTON HUB VIETNAM';

  String get _transferContent => 'PAYOS ${widget.order.bookingCode.replaceAll('-', '')}';

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialRemainingSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _onTimeExpired();
      }
    });
  }

  void _onTimeExpired() {
    if (_paymentSuccess == true) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Hết thời gian giữ chỗ!'),
        content: const Text(
          'Đã hết 10 phút giữ chỗ trên cổng thanh toán PayOS. Link thanh toán đã hết hạn và khung giờ được hoàn trả lại hệ thống.',
        ),
        actions: [
          AppButton(
            label: 'Quay lại',
            variant: AppButtonVariant.primary,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Mo phong Webhook PayOS tra ve trang thai PAID (Thanh toan thanh cong)
  Future<void> _simulatePayOsSuccess() async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final txnId = 'POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    // Cap nhat don dat san va luu vao Repo
    final updatedOrder = widget.order.copyWith(
      paidAmountVnd: widget.order.paidAmountVnd + widget.paymentAmountVnd,
      status: CourtBookingStatus.activeConfirmed,
    );
    FakeCustomerBookingRepository.instance.addBooking(updatedOrder);

    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
      _payOsTransactionId = txnId;
    });
  }

  /// Mo phong Webhook PayOS tra ve trang thai CANCELLED (Huy giao dich)
  Future<void> _simulatePayOsCancelled() async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _paymentSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    // 1. Man hinh ket qua thanh cong
    if (_paymentSuccess == true) {
      return _buildSuccessScreen(context);
    }

    // 2. Man hinh ket qua that bai / huy
    if (_paymentSuccess == false) {
      return _buildFailureScreen(context);
    }

    // 3. Giao dien Cổng thanh toán PayOS VietQR
    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('C-08 Cổng thanh toán PayOS VietQR'),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: t.space4),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: t.space3,
                  vertical: t.space1,
                ),
                decoration: BoxDecoration(
                  color: _remainingSeconds < 120
                      ? t.statusCancelled.background
                      : t.statusPending.background,
                  borderRadius: BorderRadius.circular(t.radiusControl),
                  border: Border.all(
                    color: _remainingSeconds < 120
                        ? t.statusCancelled.border
                        : t.statusPending.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: _remainingSeconds < 120
                          ? t.statusCancelled.foreground
                          : t.statusPending.foreground,
                    ),
                    SizedBox(width: t.space1),
                    Text(
                      _formatTimer(_remainingSeconds),
                      style: textTheme.labelMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w700,
                        color: _remainingSeconds < 120
                            ? t.statusCancelled.foreground
                            : t.statusPending.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          // Header PayOS & VietQR
          Container(
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: t.space2,
                            vertical: t.space1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0052CC),
                            borderRadius: BorderRadius.circular(t.radiusControl),
                          ),
                          child: const Text(
                            'payOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(width: t.space2),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: t.space2,
                            vertical: t.space1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFED1C24),
                            borderRadius: BorderRadius.circular(t.radiusControl),
                          ),
                          child: const Text(
                            'VietQR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: t.space2),
                        const StatusChip(
                          status: CourtBookingStatus.activeConfirmed,
                          customLabel: 'Open Banking 24/7',
                        ),
                      ],
                    ),
                    Text(
                      widget.order.bookingCode,
                      style: textTheme.labelMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: t.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.space3),
                Text(
                  'Thanh toán đặt sân: ${widget.order.venueName}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.space1),
                Text(
                  'Ngày chơi: ${AppFormatters.dateVn(widget.order.playDate)} (${widget.order.slots.length} ca)',
                  style: textTheme.bodySmall,
                ),
                SizedBox(height: t.space3),
                const Divider(),
                SizedBox(height: t.space2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Số tiền thanh toán:', style: textTheme.bodyMedium),
                    PriceText(
                      amountVnd: widget.paymentAmountVnd,
                      isHero: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // Khung VietQR dong cua PayOS
          Container(
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle),
            ),
            child: Column(
              children: [
                Text(
                  'Quét mã VietQR bằng bất kỳ App Ngân hàng nào',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: t.space1),
                Text(
                  'Hệ thống tự động xác nhận sau 1 đến 3 giây khi nhận được tiền',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: t.space4),

                // Khoi Ma QR
                Container(
                  width: 220,
                  height: 220,
                  padding: EdgeInsets.all(t.space3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(t.radiusControl),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _PayOsVietQrPainter(payload: _transferContent),
                  ),
                ),
                SizedBox(height: t.space3),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton(
                      label: 'Tải ảnh QR',
                      leadingIcon: Icons.download_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu mã VietQR vào thư viện ảnh thiết bị.'),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: t.space3),
                    AppButton(
                      label: 'Mở App Ngân hàng',
                      leadingIcon: Icons.open_in_new_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang mở ứng dụng ngân hàng liên kết...'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // Thong tin chuyen khoan chi tiet PayOS kem nut Copy
          Container(
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoặc chuyển khoản thủ công chính xác',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.space3),
                _buildCopyRow(
                  label: 'Ngân hàng thụ hưởng:',
                  value: _bankName,
                  copyValue: _bankCode,
                  isCopyable: false,
                ),
                _buildCopyRow(
                  label: 'Chủ tài khoản:',
                  value: _accountName,
                  copyValue: _accountName,
                  isCopyable: false,
                ),
                _buildCopyRow(
                  label: 'Số tài khoản:',
                  value: _accountNumber,
                  copyValue: _accountNumber,
                  isCopyable: true,
                  isHighlight: true,
                ),
                _buildCopyRow(
                  label: 'Số tiền:',
                  value: AppFormatters.currencyVnd(widget.paymentAmountVnd),
                  copyValue: widget.paymentAmountVnd.toString(),
                  isCopyable: true,
                  isHighlight: true,
                ),
                _buildCopyRow(
                  label: 'Nội dung chuyển khoản (bắt buộc):',
                  value: _transferContent,
                  copyValue: _transferContent,
                  isCopyable: true,
                  isAlert: true,
                ),
              ],
            ),
          ),
          SizedBox(height: t.space6),

          // Bang dieu khien Mo phong Webhook PayOS cho QA / Tester
          Container(
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.webhook_rounded, size: 20),
                    SizedBox(width: t.space2),
                    Text(
                      'PayOS Webhook Sandbox Simulator',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.space2),
                Text(
                  'Mô phỏng Webhook tự động của PayOS khi tài khoản nhận được tiền qua Open Banking VietQR.',
                  style: textTheme.bodySmall,
                ),
                SizedBox(height: t.space4),
                if (_isProcessing)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Webhook PAID (Thành công)',
                          leadingIcon: Icons.check_circle_outline_rounded,
                          variant: AppButtonVariant.primary,
                          onPressed: _simulatePayOsSuccess,
                        ),
                      ),
                      SizedBox(width: t.space2),
                      Expanded(
                        child: AppButton(
                          label: 'Hủy đơn (CANCELLED)',
                          leadingIcon: Icons.cancel_outlined,
                          variant: AppButtonVariant.secondary,
                          onPressed: _simulatePayOsCancelled,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: t.space6),
        ],
      ),
    );
  }

  Widget _buildCopyRow({
    required String label,
    required String value,
    required String copyValue,
    required bool isCopyable,
    bool isHighlight = false,
    bool isAlert = false,
  }) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall),
                SizedBox(height: t.space1),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: isHighlight || isAlert ? FontWeight.w800 : FontWeight.w600,
                    color: isAlert
                        ? t.actionPrimary
                        : (isHighlight ? t.textPrimary : t.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          if (isCopyable)
            AppButton(
              label: 'Sao chép',
              leadingIcon: Icons.copy_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: () => _copyToClipboard(copyValue, label),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('Kết quả thanh toán PayOS'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space6),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: t.statusActive.background,
                shape: BoxShape.circle,
                border: Border.all(color: t.statusActive.border, width: 2),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 48,
                color: t.statusActive.foreground,
              ),
            ),
          ),
          SizedBox(height: t.space4),
          Center(
            child: Text(
              'Thanh toán PayOS thành công!',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: t.statusActive.foreground,
              ),
            ),
          ),
          SizedBox(height: t.space1),
          Center(
            child: Text(
              'Hệ thống đã nhận được tiền qua VietQR Open Banking',
              style: textTheme.bodyMedium,
            ),
          ),
          SizedBox(height: t.space6),

          // Thong tin bien lai
          Container(
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle),
            ),
            child: Column(
              children: [
                _buildReceiptRow('Cổng thanh toán:', 'PayOS VietQR 24/7'),
                _buildReceiptRow('Mã đặt sân:', widget.order.bookingCode),
                _buildReceiptRow('Mã giao dịch PayOS:', _payOsTransactionId ?? 'POS-998822'),
                _buildReceiptRow('Cơ sở sân:', widget.order.venueName),
                _buildReceiptRow('Ngày thi đấu:', AppFormatters.dateVn(widget.order.playDate)),
                _buildReceiptRow('Số lượng ca:', '${widget.order.slots.length} ca'),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Số tiền đã chuyển:', style: textTheme.bodyMedium),
                    PriceText(
                      amountVnd: widget.paymentAmountVnd,
                      isHero: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: t.space6),

          AppButton(
            label: 'Xem vé đặt sân & Mã QR check-in (C-10)',
            leadingIcon: Icons.qr_code_rounded,
            variant: AppButtonVariant.primary,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => BookingDetailScreen(
                    bookingId: widget.order.id,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: t.space3),
          AppButton(
            label: 'Về trang chủ',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFailureScreen(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final canRetry = _remainingSeconds > 0;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('Kết quả thanh toán PayOS'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space6),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: t.statusCancelled.background,
                shape: BoxShape.circle,
                border: Border.all(color: t.statusCancelled.border, width: 2),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 48,
                color: t.statusCancelled.foreground,
              ),
            ),
          ),
          SizedBox(height: t.space4),
          Center(
            child: Text(
              'Giao dịch PayOS đã bị hủy',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: t.statusCancelled.foreground,
              ),
            ),
          ),
          SizedBox(height: t.space2),
          Center(
            child: Text(
              'Trạng thái giao dịch: CANCELLED (Người dùng hủy hoặc liên kết thanh toán đã bị đóng).',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: t.space6),

          if (canRetry) ...[
            Container(
              padding: EdgeInsets.all(t.space4),
              decoration: BoxDecoration(
                color: t.statusPending.background,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(color: t.statusPending.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: t.statusPending.foreground,
                  ),
                  SizedBox(width: t.space3),
                  Expanded(
                    child: Text(
                      'Khung giờ của bạn vẫn đang được giữ trong ${_formatTimer(_remainingSeconds)}. Bạn có thể mở lại mã VietQR ngay.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: t.statusPending.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: t.space6),
            AppButton(
              label: 'Thanh toán lại bằng VietQR',
              leadingIcon: Icons.refresh_rounded,
              variant: AppButtonVariant.primary,
              onPressed: () {
                setState(() => _paymentSuccess = null);
              },
            ),
            SizedBox(height: t.space3),
          ],

          AppButton(
            label: 'Quay lại chọn khung giờ (C-05)',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodySmall),
          Flexible(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter de ve ma VietQR chuan PayOS
class _PayOsVietQrPainter extends CustomPainter {
  final String payload;

  _PayOsVietQrPainter({required this.payload});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0052CC) // Mau xanh thuong hieu PayOS
      ..style = PaintingStyle.fill;

    final step = size.width / 19;

    void drawBox(int col, int row, int width, int height) {
      canvas.drawRect(
        Rect.fromLTWH(col * step, row * step, width * step, height * step),
        paint,
      );
    }

    // 3 Target Finder Patterns
    // Top-left
    drawBox(0, 0, 5, 5);
    canvas.drawRect(
      Rect.fromLTWH(1 * step, 1 * step, 3 * step, 3 * step),
      Paint()..color = Colors.white,
    );
    drawBox(2, 2, 1, 1);

    // Top-right
    drawBox(14, 0, 5, 5);
    canvas.drawRect(
      Rect.fromLTWH(15 * step, 1 * step, 3 * step, 3 * step),
      Paint()..color = Colors.white,
    );
    drawBox(16, 2, 1, 1);

    // Bottom-left
    drawBox(0, 14, 5, 5);
    canvas.drawRect(
      Rect.fromLTWH(1 * step, 15 * step, 3 * step, 3 * step),
      Paint()..color = Colors.white,
    );
    drawBox(2, 16, 1, 1);

    // Core VietQR logo icon in center
    final centerBox = Rect.fromLTWH(8 * step, 8 * step, 3 * step, 3 * step);
    canvas.drawRect(centerBox, Paint()..color = const Color(0xFFED1C24));

    // Data dots
    final hash = payload.hashCode.abs();
    for (int r = 0; r < 19; r++) {
      for (int c = 0; c < 19; c++) {
        if ((r < 6 && c < 6) || (r < 6 && c > 12) || (r > 12 && c < 6)) {
          continue;
        }
        if (r >= 8 && r <= 10 && c >= 8 && c <= 10) {
          continue;
        }
        if (((r * 19 + c * 7 + hash) % 3) == 0 || (r + c) % 5 == 0) {
          drawBox(c, r, 1, 1);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
