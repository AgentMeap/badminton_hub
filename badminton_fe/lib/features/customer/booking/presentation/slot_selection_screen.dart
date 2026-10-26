import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/slot_grid.dart';
import '../../venue/data/fake_venue_repository.dart';
import '../data/customer_booking_models.dart';
import 'booking_checkout_screen.dart';

/// FE-23: Man hinh C-05 Chon khung gio dat san:
/// - Dai chon ngay 14 ngay tiep theo
/// - Luoi SlotGrid san con x khung gio
/// - Kiem tra chon cac o lien tiep va xu ly ma loi 409 (SLOT_ALREADY_BOOKED)
///   tu dong bao loi + tai lai luoi lich trong moi nhat
/// - Thanh co dinh o day man hinh hien tong so gio + tong tien + nut "Tiep tuc".
class SlotSelectionScreen extends StatefulWidget {
  final VenueDetailModel venue;

  const SlotSelectionScreen({
    super.key,
    required this.venue,
  });

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  final FakeVenueRepository _repo = const FakeVenueRepository();
  int _selectedDayOffset = 0;
  late Map<String, CourtSlotCell> _cells;
  final Set<String> _selectedKeys = {'C1_19'};
  String? _conflictBannerMessage;

  static const List<String> _weekdayLabels = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  @override
  void initState() {
    super.initState();
    _loadSlotsForDay(0);
  }

  void _loadSlotsForDay(int offset) {
    setState(() {
      _selectedDayOffset = offset;
      _cells = _repo.getSampleSlotMatrix(dayOffset: offset);
      _selectedKeys.removeWhere((k) => !(_cells[k]?.isSelectable ?? false));
    });
  }

  void _toggleSlot(CourtSlotCell cell) {
    setState(() {
      _conflictBannerMessage = null;
      if (_selectedKeys.contains(cell.key)) {
        _selectedKeys.remove(cell.key);
      } else {
        _selectedKeys.add(cell.key);
      }
    });
  }

  int get _totalAmountVnd {
    int sum = 0;
    for (final k in _selectedKeys) {
      final cell = _cells[k];
      if (cell != null) sum += cell.priceVnd;
    }
    return sum;
  }

  /// Mo phong va xu ly loi 409 SLOT_ALREADY_BOOKED theo 01-kien-truc.md va FE-23:
  /// Danh dau o dang chon dau tien thanh da co nguoi dat, hien thong bao loi va tai lai luoi.
  void _simulate409Conflict() {
    if (_selectedKeys.isEmpty) return;
    final conflictKey = _selectedKeys.first;
    final current = _cells[conflictKey];
    setState(() {
      if (current != null) {
        _cells[conflictKey] = CourtSlotCell(
          courtId: current.courtId,
          courtName: current.courtName,
          hour: current.hour,
          priceVnd: current.priceVnd,
          status: CourtBookingStatus.maintenanceOrOccupied,
          bookedByNote: 'Vừa đặt',
        );
      }
      _selectedKeys.remove(conflictKey);
      _conflictBannerMessage =
          '409 SLOT_ALREADY_BOOKED: ${AppStrings.errSlotTaken} Lưới lịch trống đã được cập nhật lại.';
    });
  }

  void _proceedToCheckout() {
    if (_selectedKeys.isEmpty) return;

    final baseDate = DateTime(2026, 10, 27);
    final chosenDate = baseDate.add(Duration(days: _selectedDayOffset));

    final slotItems = _selectedKeys.map((k) {
      final cell = _cells[k]!;
      return BookingSlotItem(
        courtId: cell.courtId,
        courtName: cell.courtName,
        hour: cell.hour,
        priceVnd: cell.priceVnd,
      );
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingCheckoutScreen(
          venue: widget.venue,
          playDate: chosenDate,
          selectedSlots: slotItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final baseDate = DateTime(2026, 10, 27);

    return Scaffold(
      appBar: AppBar(
        title: Text('C-05 Chọn khung giờ: ${widget.venue.summary.name}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          // 1. Dai chon 14 ngay tiep theo (03-danh-sach-man-hinh.md)
          Text(
            'Chọn ngày thi đấu (14 ngày tới)',
            style: textTheme.titleMedium,
          ),
          SizedBox(height: t.space2),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              separatorBuilder: (_, _) => SizedBox(width: t.space2),
              itemBuilder: (ctx, i) {
                final date = baseDate.add(Duration(days: i));
                final isSelected = _selectedDayOffset == i;
                final weekday = _weekdayLabels[(date.weekday - 1) % 7];
                final dayMonth =
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

                return InkWell(
                  borderRadius: BorderRadius.circular(t.radiusControl),
                  onTap: () => _loadSlotsForDay(i),
                  child: Container(
                    width: 76,
                    padding: EdgeInsets.all(t.space2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? t.statusActive.background
                          : t.surfaceCard,
                      borderRadius: BorderRadius.circular(t.radiusControl),
                      border: Border.all(
                        color: isSelected ? t.actionPrimary : t.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          i == 0 ? 'Hôm nay' : weekday,
                          style: textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? t.statusActive.foreground
                                : t.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: t.space1),
                        Text(
                          dayMonth,
                          style: textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? t.statusActive.foreground
                                : t.textPrimary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: t.space4),

          // 2. Canh bao khi gap loi 409 Trùng giờ (SLOT_ALREADY_BOOKED)
          if (_conflictBannerMessage != null) ...[
            Container(
              padding: EdgeInsets.all(t.space4),
              decoration: BoxDecoration(
                color: t.statusCancelled.background,
                borderRadius: BorderRadius.circular(t.radiusControl),
                border: Border.all(color: t.statusCancelled.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: t.statusCancelled.foreground,
                  ),
                  SizedBox(width: t.space3),
                  Expanded(
                    child: Text(
                      _conflictBannerMessage!,
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

          // 3. Luoi SlotGrid san con x gio
          Container(
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle),
            ),
            child: SlotGrid(
              courtNames: FakeVenueRepository.sampleCourtNames,
              hours: FakeVenueRepository.sampleHours,
              cells: _cells,
              selectedKeys: _selectedKeys,
              onToggleSlot: _toggleSlot,
            ),
          ),
          SizedBox(height: t.space4),

          // Nut mo phong ma loi 409 theo yeu cau FE-23
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'Giả lập lỗi 409 trùng giờ (Test tự tải lại lưới)',
              leadingIcon: Icons.sync_problem_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: _selectedKeys.isNotEmpty ? _simulate409Conflict : null,
            ),
          ),
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
                    'Tổng cộng: ${_selectedKeys.length} giờ đã chọn',
                    style: textTheme.bodyMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  PriceText(
                    amountVnd: _totalAmountVnd,
                    isHero: true,
                  ),
                ],
              ),
              AppButton(
                label: 'Tiếp tục (${_selectedKeys.length}h)',
                variant: AppButtonVariant.primary,
                onPressed: _selectedKeys.isNotEmpty ? _proceedToCheckout : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
