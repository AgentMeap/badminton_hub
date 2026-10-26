import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../data/customer_booking_models.dart';
import 'payos_payment_screen.dart';

/// FE-32: Man hinh C-10 Chi tiet luot dat co Ma QR Check-in:
/// - Khung QR ma tran do tuong phan cao, nut che do sang toi da
/// - Thong tin san, ngay thi dau, cac ca san con
/// - Thong tin thanh toan: da tra, con lai can tra tai san
/// - Cac hanh dong theo trang thai:
///   + Chi duong
///   + Thanh toan phan con lai (neu moi dat coc)
///   + Huy luot dat (C-11 Bottom sheet xem so tien hoan theo chinh sach + ly do)
///   + Viet danh gia (C-12 Chon 1-5 sao + nhan xet <= 500 ky tu)
///   + Xem hoa don / bien lai
class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final FakeCustomerBookingRepository _repo = FakeCustomerBookingRepository.instance;
  late CustomerBookingOrder? _order;
  bool _highBrightnessMode = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  void _loadOrder() {
    setState(() {
      _order = _repo.getBookingById(widget.bookingId);
    });
  }

  /// C-11: Bottom Sheet Huy luot dat san theo chinh sach hoan tien
  void _openCancelBottomSheet(CustomerBookingOrder order) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final reasonController = TextEditingController();

    // Tinh % hoan theo thoi diem truoc gio choi
    final hoursDiff = order.playDate.difference(DateTime.now()).inHours;
    int refundPercent = 0;
    if (hoursDiff >= 24) {
      refundPercent = 100;
    } else if (hoursDiff >= 12) {
      refundPercent = 50;
    } else {
      refundPercent = 0;
    }

    final refundAmountVnd = (order.paidAmountVnd * refundPercent / 100).round();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusCard)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: t.space4,
                right: t.space4,
                top: t.space4,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + t.space6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: t.borderSubtle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: t.space4),
                    Text(
                      'C-11 Hủy lượt đặt sân',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: t.space2),
                    Text(
                      'Lượt đặt: ${order.bookingCode} tại ${order.venueName}',
                      style: textTheme.bodySmall,
                    ),
                    SizedBox(height: t.space4),

                    // Chinh sach hoan tien
                    Container(
                      padding: EdgeInsets.all(t.space3),
                      decoration: BoxDecoration(
                        color: t.surfaceMuted,
                        borderRadius: BorderRadius.circular(t.radiusControl),
                        border: Border.all(color: t.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chính sách hoàn tiền áp dụng:',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: t.space1),
                          Text(
                            'Hủy trước 24h: Hoàn 100% tiền đã trả\nHủy trước 12h: Hoàn 50% tiền đã trả\nHủy dưới 12h: Không hoàn tiền',
                            style: textTheme.bodySmall,
                          ),
                          SizedBox(height: t.space2),
                          const Divider(),
                          SizedBox(height: t.space1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tỷ lệ hoàn tính toán:', style: textTheme.bodySmall),
                              Text(
                                '$refundPercent%',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: refundPercent > 0
                                      ? t.statusActive.foreground
                                      : t.statusCancelled.foreground,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: t.space1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Số tiền dự kiến hoàn lại:', style: textTheme.bodySmall),
                              PriceText(
                                amountVnd: refundAmountVnd,
                                isHero: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.space4),

                    Text(
                      'Lý do hủy (bắt buộc):',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: t.space2),
                    AppTextField(
                      controller: reasonController,
                      label: 'Nhập lý do hủy đặt sân',
                      hintText: 'Ví dụ: Bận việc gia đình đột xuất, thời tiết...',
                    ),
                    SizedBox(height: t.space6),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Đóng',
                            variant: AppButtonVariant.secondary,
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ),
                        SizedBox(width: t.space3),
                        Expanded(
                          child: AppButton(
                            label: 'Xác nhận hủy',
                            variant: AppButtonVariant.danger,
                            onPressed: () {
                              final reason = reasonController.text.trim();
                              if (reason.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng nhập lý do hủy đặt sân.'),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(ctx).pop();
                              _executeCancel(order.id, reason);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _executeCancel(String bookingId, String reason) {
    final success = _repo.cancelBooking(bookingId: bookingId, reason: reason);
    if (success) {
      _loadOrder();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy lượt đặt sân và tạo yêu cầu hoàn tiền thành công.'),
        ),
      );
    }
  }

  /// C-12: Viet danh gia san 1 - 5 sao va nhan xet
  void _openReviewDialog(CustomerBookingOrder order) {
    int rating = 5;
    final reviewController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final t = context.tokens;
        final textTheme = Theme.of(context).textTheme;

        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            return AlertDialog(
              backgroundColor: t.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t.radiusCard),
              ),
              title: Text(
                'C-12 Đánh giá cơ sở: ${order.venueName}',
                style: textTheme.titleMedium,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chấm điểm dịch vụ & chất lượng sân:', style: textTheme.bodySmall),
                    SizedBox(height: t.space3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        final isFilled = star <= rating;
                        return IconButton(
                          icon: Icon(
                            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => setDlgState(() => rating = star),
                        );
                      }),
                    ),
                    Center(
                      child: Text(
                        '$rating / 5 sao',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: t.space4),
                    Text('Nhận xét (tối đa 500 ký tự):', style: textTheme.labelSmall),
                    SizedBox(height: t.space2),
                    TextField(
                      controller: reviewController,
                      maxLength: 500,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Chất lượng thảm, ánh sáng, dịch vụ lễ tân...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(t.radiusControl),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                AppButton(
                  label: 'Bỏ qua',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                AppButton(
                  label: 'Gửi đánh giá',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cảm ơn bạn đã đánh giá $rating sao cho ${order.venueName}!'),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Thanh toan phan con lai bang PayOS VietQR
  void _payRemaining(CustomerBookingOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PayOsPaymentScreen(
          order: order,
          paymentAmountVnd: order.remainingAmountVnd,
        ),
      ),
    ).then((_) => _loadOrder());
  }

  /// Xem hoa don dien tu / Bien lai
  void _showInvoiceDialog(CustomerBookingOrder order) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusCard),
        ),
        title: Text('Hóa đơn điện tử: ${order.invoiceCode ?? 'INV-2026-DEFAULT'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn vị cung cấp: ${order.venueName}', style: textTheme.bodySmall),
            Text('Địa chỉ: ${order.venueAddress}', style: textTheme.bodySmall),
            SizedBox(height: t.space2),
            const Divider(),
            SizedBox(height: t.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng tiền dịch vụ:', style: textTheme.bodySmall),
                PriceText(amountVnd: order.totalAmountVnd),
              ],
            ),
            if (order.discountAmountVnd > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Giảm giá voucher:', style: textTheme.bodySmall),
                  Text(
                    '-${AppFormatters.currencyVnd(order.discountAmountVnd)}',
                    style: TextStyle(color: t.statusCancelled.foreground),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đã thanh toán:', style: textTheme.bodySmall),
                PriceText(amountVnd: order.paidAmountVnd),
              ],
            ),
            SizedBox(height: t.space2),
            const Divider(),
            SizedBox(height: t.space2),
            Text(
              'Trạng thái: ${order.status.name}',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Đóng',
            variant: AppButtonVariant.primary,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lượt đặt')),
        body: const Center(child: Text('Không tìm thấy thông tin lượt đặt sân.')),
      );
    }

    final order = _order!;
    final isUpcoming = order.status == CourtBookingStatus.activeConfirmed;
    final isPast = order.status == CourtBookingStatus.completedOrCheckedIn;
    final isCancelled = order.status == CourtBookingStatus.cancelledOrSuspended;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: Text('C-10 Vé đặt sân: ${order.bookingCode}'),
        actions: [
          IconButton(
            tooltip: 'Hóa đơn / Biên nhận',
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => _showInvoiceDialog(order),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          // 1. Khoi QR Check-in trung tam
          Container(
            padding: EdgeInsets.all(t.space6),
            decoration: BoxDecoration(
              color: _highBrightnessMode ? Colors.white : t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(
                color: isCancelled ? t.statusCancelled.border : t.borderSubtle,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusChip(
                      status: order.status,
                      customLabel: isCancelled
                          ? 'Đã hủy'
                          : (order.isPaidInFull ? 'Đã xác nhận' : 'Đã đặt cọc 30%'),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_high_rounded,
                          size: 16,
                          color: _highBrightnessMode ? Colors.amber[800] : t.textSecondary,
                        ),
                        SizedBox(width: t.space1),
                        InkWell(
                          onTap: () => setState(() => _highBrightnessMode = !_highBrightnessMode),
                          child: Text(
                            _highBrightnessMode ? 'Sáng cao' : 'Chuẩn',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: t.space4),

                // Ma QR
                Opacity(
                  opacity: isCancelled ? 0.3 : 1.0,
                  child: Container(
                    width: 200,
                    height: 200,
                    padding: EdgeInsets.all(t.space3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: CustomPaint(
                      painter: _HighContrastQrPainter(payload: order.qrCodePayload),
                    ),
                  ),
                ),
                SizedBox(height: t.space3),

                SelectableText(
                  order.bookingCode,
                  style: textTheme.headlineSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: t.space1),
                Text(
                  isCancelled
                      ? 'Lượt đặt này đã bị hủy - Mã QR không còn giá trị'
                      : 'Đưa mã QR này cho lễ tân khi đến nhận sân',
                  style: textTheme.bodySmall?.copyWith(
                    color: isCancelled ? t.statusCancelled.foreground : Colors.black54,
                    fontWeight: isCancelled ? FontWeight.w700 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 2. Thong tin san va lich thi dau
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
                    Expanded(
                      child: Text(
                        order.venueName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppButton(
                      label: 'Chỉ đường',
                      leadingIcon: Icons.directions_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đang mở ứng dụng bản đồ đến ${order.venueAddress}...'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: t.space1),
                Text(
                  order.venueAddress,
                  style: textTheme.bodySmall,
                ),
                SizedBox(height: t.space1),
                Text(
                  'Hotline sân: ${order.venuePhone}',
                  style: textTheme.bodySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(height: t.space3),
                const Divider(),
                SizedBox(height: t.space2),
                Text(
                  'Ngày thi đấu: ${AppFormatters.dateVn(order.playDate)}',
                  style: textTheme.titleSmall,
                ),
                SizedBox(height: t.space2),
                ...order.slots.map((slot) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: t.space2),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: t.space3,
                        vertical: t.space2,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceMuted,
                        borderRadius: BorderRadius.circular(t.radiusControl),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sports_tennis_rounded, size: 16),
                              SizedBox(width: t.space2),
                              Text(slot.courtName, style: textTheme.bodyMedium),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                slot.timeRangeLabel,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: t.space3),
                              PriceText(amountVnd: slot.priceVnd),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 3. Chi tiet thanh toan
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
                Text('Thông tin thanh toán', style: textTheme.titleSmall),
                SizedBox(height: t.space3),
                _buildPaymentRow('Tổng tiền sân:', order.totalAmountVnd),
                if (order.discountAmountVnd > 0)
                  _buildPaymentRow(
                    'Khuyến mãi voucher:',
                    -order.discountAmountVnd,
                    isNegative: true,
                  ),
                _buildPaymentRow('Tổng cộng:', order.finalTotalVnd, isBold: true),
                const Divider(),
                _buildPaymentRow('Đã thanh toán:', order.paidAmountVnd, isHighlight: true),
                if (!order.isPaidInFull && !isCancelled)
                  _buildPaymentRow(
                    'Còn lại cần thanh toán tại quầy:',
                    order.remainingAmountVnd,
                    isNotice: true,
                  ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // Ly do neu da bi huy
          if (isCancelled && order.cancelReason != null) ...[
            Container(
              padding: EdgeInsets.all(t.space4),
              decoration: BoxDecoration(
                color: t.statusCancelled.background,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(color: t.statusCancelled.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin hủy đặt sân:',
                    style: textTheme.titleSmall?.copyWith(
                      color: t.statusCancelled.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: t.space1),
                  Text(
                    order.cancelReason!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: t.statusCancelled.foreground,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: t.space4),
          ],

          // 4. Cac hanh dong phu hop theo ngu canh
          if (isUpcoming) ...[
            if (!order.isPaidInFull)
              Padding(
                padding: EdgeInsets.only(bottom: t.space3),
                child: AppButton(
                  label: 'Thanh toán phần còn lại (${AppFormatters.currencyVnd(order.remainingAmountVnd)})',
                  leadingIcon: Icons.payment_rounded,
                  variant: AppButtonVariant.primary,
                  onPressed: () => _payRemaining(order),
                ),
              ),
            AppButton(
              label: 'Hủy lượt đặt sân (C-11)',
              leadingIcon: Icons.cancel_outlined,
              variant: AppButtonVariant.danger,
              onPressed: () => _openCancelBottomSheet(order),
            ),
          ],

          if (isPast) ...[
            AppButton(
              label: 'Viết đánh giá cơ sở này (C-12)',
              leadingIcon: Icons.rate_review_outlined,
              variant: AppButtonVariant.primary,
              onPressed: () => _openReviewDialog(order),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    int amountVnd, {
    bool isBold = false,
    bool isNegative = false,
    bool isHighlight = false,
    bool isNotice = false,
  }) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isNotice ? t.statusCancelled.foreground : t.textPrimary,
            ),
          ),
          if (isNegative)
            Text(
              '-${AppFormatters.currencyVnd(amountVnd.abs())}',
              style: textTheme.bodyMedium?.copyWith(
                color: t.statusCancelled.foreground,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            PriceText(
              amountVnd: amountVnd,
              isHero: isBold || isNotice,
            ),
        ],
      ),
    );
  }
}

/// Custom painter cho ma QR check-in
class _HighContrastQrPainter extends CustomPainter {
  final String payload;

  _HighContrastQrPainter({required this.payload});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final step = size.width / 21;

    void drawBox(int col, int row, int width, int height) {
      canvas.drawRect(
        Rect.fromLTWH(col * step, row * step, width * step, height * step),
        paint,
      );
    }

    // 3 Target Finder Patterns
    // Top-left
    drawBox(0, 0, 7, 7);
    canvas.drawRect(
      Rect.fromLTWH(1 * step, 1 * step, 5 * step, 5 * step),
      Paint()..color = Colors.white,
    );
    drawBox(2, 2, 3, 3);

    // Top-right
    drawBox(14, 0, 7, 7);
    canvas.drawRect(
      Rect.fromLTWH(15 * step, 1 * step, 5 * step, 5 * step),
      Paint()..color = Colors.white,
    );
    drawBox(16, 2, 3, 3);

    // Bottom-left
    drawBox(0, 14, 7, 7);
    canvas.drawRect(
      Rect.fromLTWH(1 * step, 15 * step, 5 * step, 5 * step),
      Paint()..color = Colors.white,
    );
    drawBox(2, 16, 3, 3);

    // Timing strips
    for (int i = 8; i < 13; i += 2) {
      drawBox(i, 6, 1, 1);
      drawBox(6, i, 1, 1);
    }

    // Pseudo data dots derived from hash
    final hash = payload.hashCode.abs();
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if ((r < 8 && c < 8) || (r < 8 && c > 13) || (r > 13 && c < 8)) {
          continue;
        }
        if (((r * 31 + c * 17 + hash) % 3) == 0) {
          drawBox(c, r, 1, 1);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
