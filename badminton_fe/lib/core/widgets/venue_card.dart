import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'app_button.dart';
import 'price_text.dart';
import 'status_chip.dart';

/// Du lieu tom tat mot co so san cau long de hien thi tren VenueCard.
@immutable
class VenueSummaryItem {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final double rating;
  final int reviewCount;
  final int minPricePerHour;
  final int availableCourtCount;
  final CourtBookingStatus status;

  const VenueSummaryItem({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.reviewCount,
    required this.minPricePerHour,
    required this.availableCourtCount,
    this.status = CourtBookingStatus.activeConfirmed,
  });
}

/// The san cau long dung chung (02-design-system.md):
/// - Anh san ty le 16:9, bo goc the 16dp (radiusCard)
/// - Hien thi ten, khoang cach, danh gia, trang thai san trong, gia tu (PriceText)
class VenueCard extends StatelessWidget {
  final VenueSummaryItem venue;
  final VoidCallback onTap;
  final VoidCallback? onBookQuick;

  const VenueCard({
    super.key,
    required this.venue,
    required this.onTap,
    this.onBookQuick,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner ty le 16:9 theo 02-design-system.md
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: t.surfaceMuted,
                  border: Border(
                    bottom: BorderSide(color: t.borderSubtle, width: 1),
                  ),
                ),
                padding: EdgeInsets.all(t.space4),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_tennis_rounded,
                            size: 36,
                            color: t.actionPrimary,
                          ),
                          SizedBox(height: t.space1),
                          Text(
                            '${venue.availableCourtCount} sân thảm PVC tiêu chuẩn',
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: StatusChip(
                        status: venue.status,
                        customLabel: venue.availableCourtCount > 0
                            ? 'Còn ${venue.availableCourtCount} sân trống'
                            : 'Hết giờ trống',
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: t.space2,
                          vertical: t.space1,
                        ),
                        decoration: BoxDecoration(
                          color: t.surfaceCard,
                          borderRadius: BorderRadius.circular(t.radiusControl),
                          border: Border.all(color: t.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: t.actionSecondary,
                            ),
                            SizedBox(width: t.space1),
                            Text(
                              '${venue.rating.toStringAsFixed(1)} (${venue.reviewCount})',
                              style: textTheme.labelSmall?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(t.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: textTheme.titleLarge,
                        ),
                      ),
                      SizedBox(width: t.space2),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: t.space2,
                          vertical: t.space1,
                        ),
                        decoration: BoxDecoration(
                          color: t.surfaceMuted,
                          borderRadius: BorderRadius.circular(t.radiusControl),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.near_me_outlined,
                              size: 14,
                              color: t.textSecondary,
                            ),
                            SizedBox(width: t.space1),
                            Text(
                              '${venue.distanceKm.toStringAsFixed(1)} km',
                              style: textTheme.labelSmall?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.space1),
                  Text(
                    venue.address,
                    style: textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: t.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Giá thuê từ', style: textTheme.labelSmall),
                          PriceText(
                            amountVnd: venue.minPricePerHour,
                            suffix: '/giờ',
                          ),
                        ],
                      ),
                      if (onBookQuick != null)
                        AppButton(
                          label: 'Chọn khung giờ',
                          leadingIcon: Icons.calendar_today_outlined,
                          onPressed: onBookQuick,
                          variant: AppButtonVariant.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
