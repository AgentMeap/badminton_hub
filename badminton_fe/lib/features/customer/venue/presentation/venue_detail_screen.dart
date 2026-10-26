import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../booking/presentation/slot_selection_screen.dart';
import '../data/fake_venue_repository.dart';

/// FE-22: Man hinh C-03 Chi tiet san:
/// - Carousel anh 16:9 co chi bao trang
/// - Ten san, rating, dia chi + nut "Chi duong"
/// - Gio mo cua, bang gia theo khung gio, tien ich, chinh sach huy, FAQ thu gon
/// - Thanh co dinh o day man hinh voi gia tu + nut "Dat san ngay" sang C-05.
class VenueDetailScreen extends StatefulWidget {
  final VenueDetailModel venue;

  const VenueDetailScreen({
    super.key,
    required this.venue,
  });

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  int _photoIndex = 0;

  void _openDirections() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đang mở Google Maps chỉ đường tới: ${widget.venue.summary.address}',
        ),
      ),
    );
  }

  void _openSlotSelection() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SlotSelectionScreen(venue: widget.venue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final v = widget.venue;
    final photos = v.photoCaptions.isNotEmpty
        ? v.photoCaptions
        : const ['Sân cầu lông tiêu chuẩn thảm PVC'];

    return Scaffold(
      appBar: AppBar(
        title: Text('C-03 ${v.summary.name}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          // 1. Carousel anh san ty le 16:9
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(t.radiusCard),
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: photos.length,
                    onPageChanged: (idx) => setState(() => _photoIndex = idx),
                    itemBuilder: (ctx, i) {
                      return Container(
                        decoration: BoxDecoration(
                          color: t.surfaceMuted,
                          border: Border.all(color: t.borderSubtle),
                        ),
                        padding: EdgeInsets.all(t.space6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_tennis_rounded,
                              size: 48,
                              color: t.actionPrimary,
                            ),
                            SizedBox(height: t.space3),
                            Text(
                              photos[i],
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: t.space3,
                    left: t.space3,
                    child: StatusChip(
                      status: v.summary.status,
                      customLabel: v.summary.availableCourtCount > 0
                          ? 'Còn ${v.summary.availableCourtCount} sân trống'
                          : 'Hết sân trống',
                    ),
                  ),
                  Positioned(
                    bottom: t.space3,
                    right: t.space3,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: t.space3,
                        vertical: t.space1,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceCard,
                        borderRadius: BorderRadius.circular(t.radiusControl),
                        border: Border.all(color: t.borderSubtle),
                      ),
                      child: Text(
                        'Ảnh ${_photoIndex + 1}/${photos.length} (Vuốt ngang)',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: t.space4),

          // 2. Ten san, Rating, Dia chi + Nut Chi duong
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        v.summary.name,
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    SizedBox(width: t.space2),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: t.space3,
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
                            Icons.star_rounded,
                            size: 18,
                            color: t.actionSecondary,
                          ),
                          SizedBox(width: t.space1),
                          Text(
                            '${v.summary.rating} (${v.summary.reviewCount} đánh giá)',
                            style: textTheme.labelLarge?.copyWith(
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
                SizedBox(height: t.space2),
                Text(v.summary.address, style: textTheme.bodyMedium),
                SizedBox(height: t.space2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: t.actionPrimary,
                    ),
                    SizedBox(width: t.space2),
                    Expanded(
                      child: Text(
                        'Giờ mở cửa: ${v.openHoursText}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.space4),
                AppButton(
                  label:
                      '${AppStrings.actionDirections} (${v.summary.distanceKm} km)',
                  leadingIcon: Icons.directions_outlined,
                  variant: AppButtonVariant.secondary,
                  expandWidth: true,
                  onPressed: _openDirections,
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 3. Bang gia theo khung gio (PriceText tabularFigures)
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
                Text('Bảng giá thuê sân theo khung giờ', style: textTheme.titleLarge),
                SizedBox(height: t.space3),
                _PriceRow(
                  label: 'Ngày thường (05:00 - 17:00)',
                  amountVnd: v.weekdayMorningPrice,
                ),
                const Divider(),
                _PriceRow(
                  label: 'Giờ cao điểm tối (17:00 - 22:00)',
                  amountVnd: v.weekdayPeakPrice,
                ),
                const Divider(),
                _PriceRow(
                  label: 'Cuối tuần & Ngày lễ (Thứ 7 - CN)',
                  amountVnd: v.weekendPrice,
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 4. Tien ich tai san
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
                Text('Tiện ích tại cơ sở', style: textTheme.titleLarge),
                SizedBox(height: t.space3),
                Wrap(
                  spacing: t.space2,
                  runSpacing: t.space2,
                  children: v.amenities.map((a) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: t.space3,
                        vertical: t.space2,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceMuted,
                        borderRadius: BorderRadius.circular(t.radiusControl),
                        border: Border.all(color: t.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: t.actionPrimary,
                          ),
                          SizedBox(width: t.space1),
                          Text(a, style: textTheme.labelSmall?.copyWith(color: t.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 5. Chinh sach huy & hoan tien
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
                Text('Chính sách hủy & hoàn cọc', style: textTheme.titleLarge),
                SizedBox(height: t.space2),
                ...v.cancellationPolicies.map(
                  (rule) => Padding(
                    padding: EdgeInsets.only(bottom: t.space2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: t.textSecondary,
                        ),
                        SizedBox(width: t.space2),
                        Expanded(
                          child: Text(rule, style: textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. FAQ thu gon (ExpansionTile)
          if (v.faqs.isNotEmpty) ...[
            SizedBox(height: t.space4),
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
                  Text('Câu hỏi thường gặp (FAQ)', style: textTheme.titleLarge),
                  SizedBox(height: t.space2),
                  ...v.faqs.map(
                    (faq) => ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(faq.question, style: textTheme.titleMedium),
                      childrenPadding: EdgeInsets.only(bottom: t.space3),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(faq.answer, style: textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: t.space8),
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
                  Text('Giá thuê chỉ từ', style: textTheme.labelSmall),
                  PriceText(
                    amountVnd: v.summary.minPricePerHour,
                    suffix: '/giờ',
                    isHero: true,
                  ),
                ],
              ),
              AppButton(
                label: 'Chọn khung giờ (C-05)',
                leadingIcon: Icons.calendar_month_rounded,
                variant: AppButtonVariant.primary,
                onPressed: v.summary.availableCourtCount > 0
                    ? _openSlotSelection
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final int amountVnd;

  const _PriceRow({
    required this.label,
    required this.amountVnd,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          PriceText(amountVnd: amountVnd, suffix: '/giờ'),
        ],
      ),
    );
  }
}
