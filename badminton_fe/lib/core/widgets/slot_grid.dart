import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';
import 'status_chip.dart';

/// Du lieu 1 o khung gio tren luoi SlotGrid (dung o man C-05 va O-10).
@immutable
class CourtSlotCell {
  final String courtId;
  final String courtName;
  final int hour;
  final int priceVnd;
  final CourtBookingStatus status;
  final String? bookedByNote;

  const CourtSlotCell({
    required this.courtId,
    required this.courtName,
    required this.hour,
    required this.priceVnd,
    required this.status,
    this.bookedByNote,
  });

  String get key => '${courtId}_$hour';
  bool get isSelectable => status == CourtBookingStatus.activeConfirmed;
}

/// Luoi san con x khung gio dung chung cho Customer (C-05) va Owner (O-10)
/// theo 02-design-system.md:
/// - Moi o dat vung cham toi thieu >= 48dp
/// - Khong chi dung mau: moi o co bieu tuong + gia hoac nhan trang thai ro rang
class SlotGrid extends StatelessWidget {
  final List<String> courtNames;
  final List<int> hours;
  final Map<String, CourtSlotCell> cells;
  final Set<String> selectedKeys;
  final ValueChanged<CourtSlotCell> onToggleSlot;

  const SlotGrid({
    super.key,
    required this.courtNames,
    required this.hours,
    required this.cells,
    required this.selectedKeys,
    required this.onToggleSlot,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chu thich trang thai (Legend) kem icon + chu
        Wrap(
          spacing: t.space2,
          runSpacing: t.space2,
          children: const [
            StatusChip(
              status: CourtBookingStatus.activeConfirmed,
              customLabel: 'Còn trống',
            ),
            StatusChip(
              status: CourtBookingStatus.pending,
              customLabel: 'Đang giữ chỗ',
            ),
            StatusChip(
              status: CourtBookingStatus.maintenanceOrOccupied,
              customLabel: 'Đã đặt / Bảo trì',
            ),
            StatusChip(
              status: CourtBookingStatus.completedOrCheckedIn,
              customLabel: 'Đang chọn',
            ),
          ],
        ),
        SizedBox(height: t.space4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hang tieu de khung gio
              Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: Text(
                      'Sân / Giờ',
                      style: textTheme.labelLarge,
                    ),
                  ),
                  ...hours.map(
                    (h) => Container(
                      width: 108,
                      padding: EdgeInsets.symmetric(
                        horizontal: t.space2,
                        vertical: t.space2,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${h.toString().padLeft(2, '0')}:00',
                        style: textTheme.labelLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: t.space1),
              // Cac hang san con
              ...List.generate(courtNames.length, (courtIdx) {
                final courtId = 'C${courtIdx + 1}';
                final courtName = courtNames[courtIdx];
                return Padding(
                  padding: EdgeInsets.only(bottom: t.space2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Text(
                          courtName,
                          style: textTheme.titleMedium,
                        ),
                      ),
                      ...hours.map((h) {
                        final key = '${courtId}_$h';
                        final cell = cells[key];
                        if (cell == null) {
                          return const SizedBox(width: 108, height: 56);
                        }
                        final isSelected = selectedKeys.contains(key);
                        final effectiveStatus = isSelected
                            ? CourtBookingStatus.completedOrCheckedIn
                            : cell.status;
                        final pair = t.pairForStatus(effectiveStatus);

                        return Padding(
                          padding: EdgeInsets.only(right: t.space2),
                          child: Semantics(
                            button: cell.isSelectable,
                            selected: isSelected,
                            label:
                                '$courtName khung giờ ${AppFormatters.timeSlotRange(h)}, ${StatusChip.defaultLabelFor(effectiveStatus)}',
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(t.radiusControl),
                              onTap: cell.isSelectable
                                  ? () => onToggleSlot(cell)
                                  : null,
                              child: Container(
                                width: 100,
                                constraints: BoxConstraints(
                                  minHeight: t.minTapTarget + t.space2,
                                ),
                                padding: EdgeInsets.all(t.space2),
                                decoration: BoxDecoration(
                                  color: pair.background,
                                  borderRadius:
                                      BorderRadius.circular(t.radiusControl),
                                  border: Border.all(
                                    color: isSelected
                                        ? t.actionPrimary
                                        : pair.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : StatusChip.iconFor(cell.status),
                                          size: 14,
                                          color: pair.foreground,
                                        ),
                                        SizedBox(width: t.space1),
                                        Flexible(
                                          child: Text(
                                            isSelected
                                                ? 'Đã chọn'
                                                : (cell.isSelectable
                                                    ? 'Trống'
                                                    : (cell.bookedByNote ??
                                                        'Đã đặt')),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: textTheme.labelSmall
                                                ?.copyWith(
                                              color: pair.foreground,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: t.space1),
                                    Text(
                                      '${(cell.priceVnd ~/ 1000)}k',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: pair.foreground,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
