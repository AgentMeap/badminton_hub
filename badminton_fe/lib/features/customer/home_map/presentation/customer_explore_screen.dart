import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/venue_card.dart';
import '../../booking/presentation/slot_selection_screen.dart';
import '../../venue/data/fake_venue_repository.dart';
import '../../venue/presentation/venue_detail_screen.dart';

/// FE-20 & FE-21: Man hinh C-01 Kham pha san (Ban do + Marker + Card tom tat + Chuyen danh sach + Ban kinh 2/5/10 km + Quyen vi tri)
/// ket hop C-02 Bo loc & Sap xep (Bottom Sheet).
class CustomerExploreScreen extends StatefulWidget {
  const CustomerExploreScreen({super.key});

  @override
  State<CustomerExploreScreen> createState() => _CustomerExploreScreenState();
}

class _CustomerExploreScreenState extends State<CustomerExploreScreen> {
  final FakeVenueRepository _repo = const FakeVenueRepository();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _manualLocationCtrl =
      TextEditingController(text: '268 Lý Thường Kiệt, Quận 10, TP.HCM');

  VenueFilterCriteria _criteria = const VenueFilterCriteria(radiusKm: 5.0);
  bool _isMapView = true;
  bool _locationPermissionDenied = false;
  String? _selectedVenueId = 'venue-01';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _manualLocationCtrl.dispose();
    super.dispose();
  }

  void _openVenueDetail(VenueDetailModel detail) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VenueDetailScreen(venue: detail),
      ),
    );
  }

  void _openSlotSelection(VenueDetailModel detail) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SlotSelectionScreen(venue: detail),
      ),
    );
  }

  Future<void> _openFilterBottomSheet() async {
    final updated = await showModalBottomSheet<VenueFilterCriteria>(
      context: context,
      isScrollControlled: true,
      builder: (_) => VenueFilterBottomSheet(initialCriteria: _criteria),
    );
    if (updated != null) {
      setState(() => _criteria = updated);
    }
  }

  void _relaxFilters() {
    setState(() {
      _searchCtrl.clear();
      _criteria = const VenueFilterCriteria(
        radiusKm: 10.0,
        selectedDistrict: 'Tất cả',
        maxPriceVnd: 220000,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final results = _repo.filterVenues(_criteria);

    VenueDetailModel? selectedDetail;
    for (final item in results) {
      if (item.summary.id == _selectedVenueId) {
        selectedDetail = item;
        break;
      }
    }
    if (selectedDetail == null && results.isNotEmpty) {
      selectedDetail = results.first;
    }

    return Column(
      children: [
        // Thanh tim kiem + Chip ban kinh 2/5/10 km + Nut Bo loc (C-02) + Chuyen Map/List
        Container(
          padding: EdgeInsets.all(t.space4),
          decoration: BoxDecoration(
            color: t.surfaceCard,
            border: Border(bottom: BorderSide(color: t.borderSubtle, width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'C-01 Tìm sân cầu lông theo tên hoặc đường',
                      hintText: 'Ví dụ: Phú Thọ, Hoàng Hoa Thám, Sư Vạn Hạnh...',
                      controller: _searchCtrl,
                      prefixIcon: Icons.search_rounded,
                      onChanged: (val) => setState(
                        () => _criteria = _criteria.copyWith(searchQuery: val),
                      ),
                    ),
                  ),
                  SizedBox(width: t.space2),
                  AppButton(
                    label: 'Bộ lọc (C-02)',
                    leadingIcon: Icons.tune_rounded,
                    variant: AppButtonVariant.secondary,
                    onPressed: _openFilterBottomSheet,
                  ),
                ],
              ),
              SizedBox(height: t.space3),

              // Neu bi tu choi quyen vi tri -> hien o nhap dia chi thu cong (03-danh-sach-man-hinh.md)
              if (_locationPermissionDenied) ...[
                Container(
                  padding: EdgeInsets.all(t.space3),
                  decoration: BoxDecoration(
                    color: t.statusPending.background,
                    borderRadius: BorderRadius.circular(t.radiusControl),
                    border: Border.all(color: t.statusPending.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_disabled_rounded,
                            size: 18,
                            color: t.statusPending.foreground,
                          ),
                          SizedBox(width: t.space2),
                          Expanded(
                            child: Text(
                              'Quyền vị trí đang tắt. Bạn hãy nhập địa chỉ để tìm sân gần đó:',
                              style: textTheme.labelSmall?.copyWith(
                                color: t.statusPending.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: t.space2),
                      AppTextField(
                        label: 'Địa chỉ hiện tại của bạn',
                        controller: _manualLocationCtrl,
                        prefixIcon: Icons.edit_location_alt_outlined,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: t.space3),
              ],

              // Chip ban kinh (2 / 5 / 10 km) + Chuyen Map/List + Gia lap quyen vi tri
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...[2.0, 5.0, 10.0].map((r) {
                      final selected = _criteria.radiusKm == r;
                      return Padding(
                        padding: EdgeInsets.only(right: t.space2),
                        child: ChoiceChip(
                          label: Text('Bán kính ${r.toInt()} km'),
                          selected: selected,
                          onSelected: (_) => setState(
                            () => _criteria = _criteria.copyWith(radiusKm: r),
                          ),
                        ),
                      );
                    }),
                    Padding(
                      padding: EdgeInsets.only(right: t.space2),
                      child: FilterChip(
                        label: Text(
                          _locationPermissionDenied
                              ? 'Bật lại GPS'
                              : 'Giả lập từ chối GPS',
                        ),
                        selected: _locationPermissionDenied,
                        onSelected: (val) => setState(
                          () => _locationPermissionDenied = val,
                        ),
                      ),
                    ),
                    AppButton(
                      label: _isMapView
                          ? 'Xem Danh sách (${results.length})'
                          : 'Xem Bản đồ (${results.length})',
                      leadingIcon: _isMapView
                          ? Icons.view_list_outlined
                          : Icons.map_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          setState(() => _isMapView = !_isMapView),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Noi dung chinh: Ban do C-01 hoac Danh sach + EmptyState khi bo loc rong
        Expanded(
          child: results.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Không có sân nào khớp bộ lọc hiện tại',
                  description:
                      'Bạn đang lọc bán kính ${_criteria.radiusKm.toInt()} km tại ${_criteria.selectedDistrict}. Hãy nới rộng bán kính hoặc xóa bớt điều kiện tiện ích.',
                  actionLabel: 'Nới rộng bộ lọc ngay',
                  onAction: _relaxFilters,
                )
              : (_isMapView
                  ? _buildInteractiveMapCanvas(
                      context,
                      results,
                      selectedDetail!,
                    )
                  : _buildVenueListView(context, results)),
        ),
      ],
    );
  }

  Widget _buildInteractiveMapCanvas(
    BuildContext context,
    List<VenueDetailModel> venues,
    VenueDetailModel selectedDetail,
  ) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        // Nen ban do khu vuc voi cac marker san co the cham
        Container(
          width: double.infinity,
          height: double.infinity,
          color: t.surfaceMuted,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return Stack(
                children: [
                  // Vong tron ban kinh mo phong quanh vi tri nguoi choi
                  Center(
                    child: Container(
                      width: constraints.maxWidth * 0.72,
                      height: constraints.maxWidth * 0.72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.actionPrimary.withValues(alpha: 0.06),
                        border: Border.all(
                          color: t.actionPrimary.withValues(alpha: 0.30),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  // Cham vi tri hien tai cua nguoi choi
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: t.space2,
                        vertical: t.space1,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceCard,
                        borderRadius: BorderRadius.circular(t.radiusControl),
                        border: Border.all(color: t.actionPrimary, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            size: 16,
                            color: t.actionPrimary,
                          ),
                          SizedBox(width: t.space1),
                          Text(
                            'Vị trí của bạn',
                            style: textTheme.labelSmall?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Cac marker san cau long tren ban do
                  ...venues.map((v) {
                    final isSelected = v.summary.id == selectedDetail.summary.id;
                    final left = (constraints.maxWidth - 130) * v.mapX;
                    final top = (constraints.maxHeight - 220) * v.mapY;

                    return Positioned(
                      left: left.clamp(12.0, constraints.maxWidth - 132.0),
                      top: top.clamp(12.0, constraints.maxHeight - 220.0),
                      child: Semantics(
                        button: true,
                        selected: isSelected,
                        label:
                            'Marker ${v.summary.name}, giá từ ${AppFormatters.currencyVnd(v.summary.minPricePerHour)}',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(t.radiusControl),
                          onTap: () => setState(
                            () => _selectedVenueId = v.summary.id,
                          ),
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: t.minTapTarget,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: t.space3,
                              vertical: t.space2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? t.actionPrimary
                                  : t.surfaceCard,
                              borderRadius:
                                  BorderRadius.circular(t.radiusControl),
                              border: Border.all(
                                color: isSelected
                                    ? t.onActionPrimary
                                    : t.actionPrimary,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sports_tennis_rounded,
                                  size: 16,
                                  color: isSelected
                                      ? t.onActionPrimary
                                      : t.actionPrimary,
                                ),
                                SizedBox(width: t.space1),
                                Text(
                                  '${v.summary.minPricePerHour ~/ 1000}k/h',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: isSelected
                                        ? t.onActionPrimary
                                        : t.textPrimary,
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
              );
            },
          ),
        ),

        // Nut "Vi tri cua toi" goc phai tren ban do
        Positioned(
          top: t.space4,
          right: t.space4,
          child: AppButton(
            label: 'Vị trí của tôi',
            leadingIcon: Icons.my_location_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã căn tâm bản đồ về vị trí GPS hiện tại.'),
                ),
              );
            },
          ),
        ),

        // Card tom tat san o day man hinh khi cham Marker (C-01 -> C-03 / C-05)
        Positioned(
          left: t.space4,
          right: t.space4,
          bottom: t.space4,
          child: Container(
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusChip(
                      status: selectedDetail.summary.status,
                      customLabel: selectedDetail.summary.availableCourtCount > 0
                          ? 'Còn ${selectedDetail.summary.availableCourtCount} sân trống'
                          : 'Hết giờ trống',
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: t.actionSecondary,
                        ),
                        SizedBox(width: t.space1),
                        Text(
                          '${selectedDetail.summary.rating} (${selectedDetail.summary.reviewCount}) · ${selectedDetail.summary.distanceKm} km',
                          style: textTheme.labelLarge?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: t.space2),
                Text(
                  selectedDetail.summary.name,
                  style: textTheme.titleLarge,
                ),
                SizedBox(height: t.space1),
                Text(
                  selectedDetail.summary.address,
                  style: textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: t.space3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giá từ', style: textTheme.labelSmall),
                        PriceText(
                          amountVnd: selectedDetail.summary.minPricePerHour,
                          suffix: '/giờ',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AppButton(
                          label: 'Chi tiết (C-03)',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _openVenueDetail(selectedDetail),
                        ),
                        SizedBox(width: t.space2),
                        AppButton(
                          label: 'Chọn giờ (C-05)',
                          variant: AppButtonVariant.primary,
                          onPressed: selectedDetail
                                      .summary.availableCourtCount >
                                  0
                              ? () => _openSlotSelection(selectedDetail)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueListView(
    BuildContext context,
    List<VenueDetailModel> venues,
  ) {
    final t = context.tokens;
    return ListView.separated(
      padding: EdgeInsets.all(t.space4),
      itemCount: venues.length,
      separatorBuilder: (_, _) => SizedBox(height: t.space4),
      itemBuilder: (ctx, i) {
        final v = venues[i];
        return VenueCard(
          venue: v.summary,
          onTap: () => _openVenueDetail(v),
          onBookQuick: v.summary.availableCourtCount > 0
              ? () => _openSlotSelection(v)
              : null,
        );
      },
    );
  }
}

/// FE-21: Man hinh C-02 Bo loc & Sap xep (Bottom Sheet).
class VenueFilterBottomSheet extends StatefulWidget {
  final VenueFilterCriteria initialCriteria;

  const VenueFilterBottomSheet({
    super.key,
    required this.initialCriteria,
  });

  @override
  State<VenueFilterBottomSheet> createState() => _VenueFilterBottomSheetState();
}

class _VenueFilterBottomSheetState extends State<VenueFilterBottomSheet> {
  late String _district;
  late double _radiusKm;
  late double _maxPrice;
  late Set<String> _amenities;
  late VenueSortOption _sortBy;

  @override
  void initState() {
    super.initState();
    _district = widget.initialCriteria.selectedDistrict;
    _radiusKm = widget.initialCriteria.radiusKm;
    _maxPrice = widget.initialCriteria.maxPriceVnd;
    _amenities = Set.of(widget.initialCriteria.requiredAmenities);
    _sortBy = widget.initialCriteria.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(t.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'C-02 Bộ lọc & Sắp xếp sân',
                  style: textTheme.headlineSmall,
                ),
                AppButton(
                  label: 'Đặt lại mặc định',
                  variant: AppButtonVariant.text,
                  onPressed: () {
                    setState(() {
                      _district = 'Tất cả';
                      _radiusKm = 5.0;
                      _maxPrice = 220000;
                      _amenities.clear();
                      _sortBy = VenueSortOption.nearest;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: t.space4),

            // 1. Sap xep theo
            Text('Sắp xếp kết quả theo', style: textTheme.titleMedium),
            SizedBox(height: t.space2),
            Wrap(
              spacing: t.space2,
              runSpacing: t.space2,
              children: VenueSortOption.values.map((opt) {
                return ChoiceChip(
                  label: Text(opt.label),
                  selected: _sortBy == opt,
                  onSelected: (_) => setState(() => _sortBy = opt),
                );
              }).toList(),
            ),
            SizedBox(height: t.space4),

            // 2. Khu vuc Quan / Huyen
            Text('Khu vực', style: textTheme.titleMedium),
            SizedBox(height: t.space2),
            Wrap(
              spacing: t.space2,
              runSpacing: t.space2,
              children: FakeVenueRepository.districts.map((d) {
                return ChoiceChip(
                  label: Text(d),
                  selected: _district == d,
                  onSelected: (_) => setState(() => _district = d),
                );
              }).toList(),
            ),
            SizedBox(height: t.space4),

            // 3. Khoang gia moi gio (Slider)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mức giá tối đa mỗi giờ', style: textTheme.titleMedium),
                PriceText(amountVnd: _maxPrice.toInt(), suffix: '/giờ'),
              ],
            ),
            Slider(
              value: _maxPrice,
              min: 100000,
              max: 220000,
              divisions: 12,
              activeColor: t.actionPrimary,
              onChanged: (val) => setState(() => _maxPrice = val),
            ),
            SizedBox(height: t.space3),

            // 4. Tien ich bat buoc
            Text('Tiện ích tại sân', style: textTheme.titleMedium),
            SizedBox(height: t.space2),
            Wrap(
              spacing: t.space2,
              runSpacing: t.space2,
              children: FakeVenueRepository.filterableAmenities.map((a) {
                final selected = _amenities.contains(a);
                return FilterChip(
                  label: Text(a),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _amenities.add(a);
                      } else {
                        _amenities.remove(a);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: t.space6),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: AppStrings.actionClose,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: AppButton(
                    label: 'Áp dụng bộ lọc',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(context).pop(
                        widget.initialCriteria.copyWith(
                          selectedDistrict: _district,
                          radiusKm: _radiusKm,
                          maxPriceVnd: _maxPrice,
                          requiredAmenities: _amenities,
                          sortBy: _sortBy,
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
    );
  }
}
