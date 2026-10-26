import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../venue/data/fake_venue_repository.dart';
import '../data/customer_booking_models.dart';
import 'booking_detail_screen.dart';
import 'payos_payment_screen.dart';

/// FE-30: Man hinh C-07 Xac nhan dat san & Thanh toan:
/// - Tom tat luot dat, danh sach ca san con
/// - Dong ho dem nguoc giu cho 10:00 (tu dong huy va quay lai C-05 khi ve 00:00)
/// - O ma giam gia (kiem tra hop le voi BADMINTON10, SANDEP20K)
/// - Chon hinh thuc: Thanh toan du / Dat coc X% / Tra tai san
/// - Chon cong thanh toan: VNPay
/// - Bang ke chi tiet: tien san, giam gia, tong cong, so tien can tra ngay
class BookingCheckoutScreen extends StatefulWidget {
  final VenueDetailModel venue;
  final DateTime playDate;
  final List<BookingSlotItem> selectedSlots;

  const BookingCheckoutScreen({
    super.key,
    required this.venue,
    required this.playDate,
    required this.selectedSlots,
  });

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  final TextEditingController _voucherController = TextEditingController();
  VoucherPromo? _appliedVoucher;
  String? _voucherErrorMessage;

  BookingPaymentType _paymentType = BookingPaymentType.full;
  int _remainingSeconds = 600; // 10 phut dem nguoc giu cho
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _onHoldExpired();
      }
    });
  }

  void _onHoldExpired() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Hết thời gian giữ chỗ!'),
        content: const Text(
          'Thời gian giữ chỗ 10 phút đã kết thúc. Các khung giờ bạn chọn đã được mở lại cho người khác.',
        ),
        actions: [
          AppButton(
            label: 'Quay lại chọn ca (C-05)',
            variant: AppButtonVariant.primary,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _voucherController.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _subtotalVnd {
    int sum = 0;
    for (final s in widget.selectedSlots) {
      sum += s.priceVnd;
    }
    return sum;
  }

  int get _discountVnd {
    if (_appliedVoucher == null) return 0;
    return _appliedVoucher!.calculateDiscount(_subtotalVnd);
  }

  int get _finalTotalVnd => (_subtotalVnd - _discountVnd).clamp(0, 999999999);

  int get _payableNowVnd {
    switch (_paymentType) {
      case BookingPaymentType.full:
        return _finalTotalVnd;
      case BookingPaymentType.deposit:
        final pct = widget.venue.depositPercentage;
        return (_finalTotalVnd * pct / 100).round();
      case BookingPaymentType.payAtVenue:
        return 0;
    }
  }

  int get _payAtCourtLaterVnd {
    return (_finalTotalVnd - _payableNowVnd).clamp(0, 999999999);
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    try {
      final voucher = FakeCustomerBookingRepository.sampleVouchers.firstWhere(
        (v) => v.code == code,
      );
      if (_subtotalVnd < voucher.minOrderVnd) {
        setState(() {
          _voucherErrorMessage =
              'Đơn tối thiểu áp dụng mã này là ${AppFormatters.currencyVnd(voucher.minOrderVnd)}.';
          _appliedVoucher = null;
        });
      } else {
        setState(() {
          _appliedVoucher = voucher;
          _voucherErrorMessage = null;
        });
      }
    } catch (_) {
      setState(() {
        _voucherErrorMessage = 'Mã giảm giá không tồn tại hoặc đã hết hạn.';
        _appliedVoucher = null;
      });
    }
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _voucherErrorMessage = null;
      _voucherController.clear();
    });
  }

  CustomerBookingOrder _buildOrderPayload() {
    final randId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final bookingCode = 'BM-2026-$randId';

    return CustomerBookingOrder(
      id: 'BK-$randId',
      bookingCode: bookingCode,
      venueId: widget.venue.summary.id,
      venueName: widget.venue.summary.name,
      venueAddress: widget.venue.summary.address,
      venuePhone: '0903123456',
      playDate: widget.playDate,
      slots: widget.selectedSlots,
      totalAmountVnd: _subtotalVnd,
      discountAmountVnd: _discountVnd,
      depositPercentage: widget.venue.depositPercentage,
      paidAmountVnd: 0,
      paymentType: _paymentType,
      status: CourtBookingStatus.pending,
      createdAt: DateTime.now(),
      qrCodePayload: 'BM-PASS-$bookingCode',
      invoiceCode: 'INV-2026-$randId',
    );
  }

  Future<void> _proceedPayment() async {
    final order = _buildOrderPayload();

    if (_paymentType == BookingPaymentType.payAtVenue) {
      // Tra tai san: tao luot dat truc tiep voi paidAmount = 0
      final venueOrder = order.copyWith(
        status: CourtBookingStatus.activeConfirmed,
      );
      FakeCustomerBookingRepository.instance.addBooking(venueOrder);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xác nhận đặt sân! Vui lòng thanh toán khi đến nhận sân.'),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => BookingDetailScreen(bookingId: venueOrder.id),
        ),
      );
      return;
    }

    // Chuyen den cong thanh toan PayOS (C-08)
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PayOsPaymentScreen(
          order: order,
          paymentAmountVnd: _payableNowVnd,
          initialRemainingSeconds: _remainingSeconds,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('C-07 Xác nhận & Thanh toán'),
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          // 1. Dong ho dem nguoc giu cho 10 phut
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: t.space4,
              vertical: t.space3,
            ),
            decoration: BoxDecoration(
              color: _remainingSeconds < 120
                  ? t.statusCancelled.background
                  : t.statusPending.background,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(
                color: _remainingSeconds < 120
                    ? t.statusCancelled.border
                    : t.statusPending.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: _remainingSeconds < 120
                      ? t.statusCancelled.foreground
                      : t.statusPending.foreground,
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thời gian giữ chỗ còn lại:',
                        style: textTheme.labelSmall?.copyWith(
                          color: _remainingSeconds < 120
                              ? t.statusCancelled.foreground
                              : t.statusPending.foreground,
                        ),
                      ),
                      Text(
                        _formatTimer(_remainingSeconds),
                        style: textTheme.titleMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w800,
                          color: _remainingSeconds < 120
                              ? t.statusCancelled.foreground
                              : t.statusPending.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '10 phút tối đa',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 2. Tom tat thong tin san & ca da chon
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
                        widget.venue.summary.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    StatusChip(
                      status: CourtBookingStatus.activeConfirmed,
                      customLabel: '${widget.selectedSlots.length} ca đã chọn',
                    ),
                  ],
                ),
                SizedBox(height: t.space1),
                Text(
                  widget.venue.summary.address,
                  style: textTheme.bodySmall,
                ),
                SizedBox(height: t.space2),
                Text(
                  'Ngày thi đấu: ${AppFormatters.dateVn(widget.playDate)}',
                  style: textTheme.titleSmall,
                ),
                SizedBox(height: t.space3),
                const Divider(),
                SizedBox(height: t.space2),
                ...widget.selectedSlots.map((slot) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: t.space2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${slot.courtName} (${slot.timeRangeLabel})',
                          style: textTheme.bodyMedium,
                        ),
                        PriceText(amountVnd: slot.priceVnd),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 3. O nhap ma giam gia (Voucher)
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
                Text('Mã giảm giá (Khuyến mãi)', style: textTheme.titleSmall),
                SizedBox(height: t.space2),
                if (_appliedVoucher != null) ...[
                  Container(
                    padding: EdgeInsets.all(t.space3),
                    decoration: BoxDecoration(
                      color: t.statusActive.background,
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      border: Border.all(color: t.statusActive.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _appliedVoucher!.code,
                              style: textTheme.titleSmall?.copyWith(
                                color: t.statusActive.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _appliedVoucher!.description,
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Hủy mã',
                          icon: Icon(
                            Icons.close_rounded,
                            color: t.statusActive.foreground,
                          ),
                          onPressed: _removeVoucher,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _voucherController,
                          label: 'Nhập mã voucher',
                          hintText: 'VD: BADMINTON10, SANDEP20K',
                        ),
                      ),
                      SizedBox(width: t.space2),
                      AppButton(
                        label: 'Áp dụng',
                        variant: AppButtonVariant.secondary,
                        onPressed: _applyVoucher,
                      ),
                    ],
                  ),
                  if (_voucherErrorMessage != null) ...[
                    SizedBox(height: t.space1),
                    Text(
                      _voucherErrorMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        color: t.statusCancelled.foreground,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 4. Chon hinh thuc thanh toan
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
                Text('Hình thức thanh toán', style: textTheme.titleSmall),
                SizedBox(height: t.space2),
                ...BookingPaymentType.values.map((type) {
                  final isSelected = _paymentType == type;
                  String title = '';
                  String subtitle = '';
                  switch (type) {
                    case BookingPaymentType.full:
                      title = 'Thanh toán đủ 100%';
                      subtitle =
                          'Thanh toán toàn bộ ${AppFormatters.currencyVnd(_finalTotalVnd)} qua PayOS VietQR';
                      break;
                    case BookingPaymentType.deposit:
                      title = 'Đặt cọc ${widget.venue.depositPercentage}%';
                      subtitle =
                          'Trả trước ${AppFormatters.currencyVnd((_finalTotalVnd * widget.venue.depositPercentage / 100).round())}, còn lại trả tại quầy sân';
                      break;
                    case BookingPaymentType.payAtVenue:
                      title = 'Trả tại sân';
                      subtitle =
                          'Thanh toán tiền mặt hoặc chuyển khoản tại quầy check-in';
                      break;
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: t.space2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      onTap: () => setState(() => _paymentType = type),
                      child: Container(
                        padding: EdgeInsets.all(t.space3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? t.statusActive.background
                              : t.surfaceCard,
                          borderRadius: BorderRadius.circular(t.radiusControl),
                          border: Border.all(
                            color: isSelected
                                ? t.statusActive.border
                                : t.borderSubtle,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected
                                  ? t.statusActive.foreground
                                  : t.textSecondary,
                            ),
                            SizedBox(width: t.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: textTheme.titleSmall?.copyWith(
                                      color: isSelected
                                          ? t.statusActive.foreground
                                          : t.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  Text(subtitle, style: textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 5. Cong thanh toan
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
                Text('Cổng thanh toán điện tử', style: textTheme.titleSmall),
                SizedBox(height: t.space2),
                ListTile(
                  leading: Container(
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: const Text('Cổng PayOS VietQR'),
                  subtitle: const Text('Quét mã VietQR tự động khớp đơn qua 40+ ứng dụng ngân hàng'),
                  trailing: const Icon(Icons.check_circle_rounded, color: Colors.green),
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 6. Bang chi tiet thanh toan
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
                Text('Chi tiết thanh toán', style: textTheme.titleSmall),
                SizedBox(height: t.space3),
                _buildSummaryLine('Tổng tiền sân:', _subtotalVnd),
                if (_discountVnd > 0)
                  _buildSummaryLine(
                    'Giảm giá khuyến mãi:',
                    -_discountVnd,
                    isDiscount: true,
                  ),
                _buildSummaryLine('Tổng cộng đơn:', _finalTotalVnd, isBold: true),
                const Divider(),
                _buildSummaryLine(
                  'Số tiền cần thanh toán ngay:',
                  _payableNowVnd,
                  isHighlight: true,
                ),
                if (_payAtCourtLaterVnd > 0)
                  _buildSummaryLine(
                    'Số tiền trả tại sân lúc nhận sân:',
                    _payAtCourtLaterVnd,
                  ),
              ],
            ),
          ),
          SizedBox(height: t.space6),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(t.space4),
          decoration: BoxDecoration(
            color: t.surfaceCard,
            border: Border(top: BorderSide(color: t.borderSubtle, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thanh toán ngay',
                    style: textTheme.bodySmall,
                  ),
                  PriceText(
                    amountVnd: _payableNowVnd,
                    isHero: true,
                  ),
                ],
              ),
              AppButton(
                label: _paymentType == BookingPaymentType.payAtVenue
                    ? 'Xác nhận giữ chỗ'
                    : 'Thanh toán ngay (PayOS VietQR)',
                leadingIcon: _paymentType == BookingPaymentType.payAtVenue
                    ? Icons.check_circle_outline_rounded
                    : Icons.payment_rounded,
                variant: AppButtonVariant.primary,
                onPressed: _proceedPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryLine(
    String label,
    int amountVnd, {
    bool isBold = false,
    bool isDiscount = false,
    bool isHighlight = false,
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
              fontWeight: isBold || isHighlight ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          if (isDiscount)
            Text(
              '-${AppFormatters.currencyVnd(amountVnd.abs())}',
              style: textTheme.bodyMedium?.copyWith(
                color: t.statusCancelled.foreground,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            PriceText(
              amountVnd: amountVnd,
              isHero: isHighlight,
            ),
        ],
      ),
    );
  }
}
