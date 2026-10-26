import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../data/customer_booking_models.dart';
import 'booking_detail_screen.dart';

/// FE-32: Man hinh C-09 Lich dat cua toi:
/// - 3 tab: Sap toi, Da qua, Da huy
/// - Danh sach the luot dat hien day du ten san, ngay gio, so tien, trang thai
/// - Chuyen sang C-10 xem chi tiet kem ma QR check-in
/// - Xu ly EmptyState khi danh sach rong
class MyBookingsScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;

  const MyBookingsScreen({
    super.key,
    this.onExploreTap,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FakeCustomerBookingRepository _repo = FakeCustomerBookingRepository.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDetail(CustomerBookingOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingDetailScreen(bookingId: order.id),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('C-09 Lịch đặt của tôi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: t.actionPrimary,
          unselectedLabelColor: t.textSecondary,
          indicatorColor: t.actionPrimary,
          tabs: const [
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đã qua'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(context, 0),
          _buildBookingList(context, 1),
          _buildBookingList(context, 2),
        ],
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, int tabIndex) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final bookings = _repo.getBookingsByTab(tabIndex);

    if (bookings.isEmpty) {
      String message = 'Bạn chưa có lịch đặt sân nào sắp tới.';
      if (tabIndex == 1) message = 'Chưa có lịch sử các buổi chơi đã qua.';
      if (tabIndex == 2) message = 'Không có lượt đặt nào bị hủy.';

      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Chưa có lượt đặt nào',
        description: message,
        actionLabel: tabIndex == 0 ? 'Tìm sân ngay' : null,
        onAction: widget.onExploreTap,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(t.space4),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => SizedBox(height: t.space3),
      itemBuilder: (ctx, index) {
        final order = bookings[index];
        final slotTimes = order.slots.map((s) => s.timeRangeLabel).join(', ');
        final courtNames = order.slots.map((s) => s.courtName).toSet().join(', ');

        return InkWell(
          onTap: () => _openDetail(order),
          borderRadius: BorderRadius.circular(t.radiusCard),
          child: Container(
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
                    Text(
                      order.bookingCode,
                      style: textTheme.labelMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w700,
                        color: t.textSecondary,
                      ),
                    ),
                    StatusChip(
                      status: order.status,
                      customLabel: order.status == CourtBookingStatus.cancelledOrSuspended
                          ? 'Đã hủy'
                          : (order.isPaidInFull ? 'Đã xác nhận' : 'Đã cọc 30%'),
                    ),
                  ],
                ),
                SizedBox(height: t.space2),
                Text(
                  order.venueName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.space1),
                Text(
                  order.venueAddress,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: t.space3),
                Container(
                  padding: EdgeInsets.all(t.space2),
                  decoration: BoxDecoration(
                    color: t.surfaceMuted,
                    borderRadius: BorderRadius.circular(t.radiusControl),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: t.textSecondary,
                      ),
                      SizedBox(width: t.space2),
                      Expanded(
                        child: Text(
                          '${AppFormatters.dateVn(order.playDate)} | $slotTimes ($courtNames)',
                          style: textTheme.bodySmall?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: t.space3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đã thanh toán:', style: textTheme.bodySmall),
                        PriceText(amountVnd: order.paidAmountVnd),
                      ],
                    ),
                    AppButton(
                      label: 'Chi tiết & QR',
                      leadingIcon: Icons.qr_code_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _openDetail(order),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
