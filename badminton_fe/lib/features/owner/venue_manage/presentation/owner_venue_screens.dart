import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../onboarding/presentation/owner_onboarding_screens.dart';
import '../data/owner_venue_models.dart';

/// FE-16: Man hinh O-04 Danh sach co so san cua toi + dieu huong sang O-05, O-06, O-07, O-08.
class OwnerVenueListView extends StatefulWidget {
  const OwnerVenueListView({super.key});

  @override
  State<OwnerVenueListView> createState() => _OwnerVenueListViewState();
}

class _OwnerVenueListViewState extends State<OwnerVenueListView> {
  final List<OwnerVenueRecord> _venues =
      List.of(OwnerVenueRecord.initialSampleVenues());

  void _openCreateOrEdit({OwnerVenueRecord? existing, int? index}) async {
    final updated = await Navigator.of(context).push<OwnerVenueRecord>(
      MaterialPageRoute<OwnerVenueRecord>(
        builder: (_) => OwnerVenueFormScreen(initialVenue: existing),
      ),
    );
    if (updated != null) {
      setState(() {
        if (index != null) {
          _venues[index] = updated;
        } else {
          _venues.insert(0, updated);
        }
      });
    }
  }

  void _openPinMap(int index) async {
    final venue = _venues[index];
    final updated = await Navigator.of(context).push<OwnerVenueRecord>(
      MaterialPageRoute<OwnerVenueRecord>(
        builder: (_) => OwnerPinLocationScreen(venue: venue),
      ),
    );
    if (updated != null) {
      setState(() => _venues[index] = updated);
    }
  }

  void _openSubCourts(int index) async {
    final venue = _venues[index];
    final updated = await Navigator.of(context).push<OwnerVenueRecord>(
      MaterialPageRoute<OwnerVenueRecord>(
        builder: (_) => OwnerSubCourtsScreen(venue: venue),
      ),
    );
    if (updated != null) {
      setState(() => _venues[index] = updated);
    }
  }

  void _openPricingHours(OwnerVenueRecord venue) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OwnerPricingHoursScreen(venueName: venue.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        // Header + Nut them co so (O-05) & Xem ho so chu san (O-02)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('O-04 Cơ sở sân của tôi', style: textTheme.headlineSmall),
                  SizedBox(height: t.space1),
                  Text(
                    'Quản lý thông tin, ghim bản đồ, sân con và bảng giá cho từng cơ sở.',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(width: t.space3),
            AppButton(
              label: 'Thêm cơ sở (O-05)',
              leadingIcon: Icons.add_rounded,
              onPressed: () => _openCreateOrEdit(),
            ),
          ],
        ),
        SizedBox(height: t.space3),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            label: 'Xem trạng thái hồ sơ Chủ sân (O-02)',
            leadingIcon: Icons.verified_user_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OwnerApplicationStatusScreen(
                    onEnterOwnerShell: () {},
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: t.space4),
        ...List.generate(_venues.length, (idx) {
          final v = _venues[idx];
          final activeCourts =
              v.courts.where((c) => !c.isMaintenance).length;
          return Padding(
            padding: EdgeInsets.only(bottom: t.space4),
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
                      StatusChip(
                        status: v.status,
                        customLabel: v.statusLabel,
                      ),
                      Text(
                        'Đặt cọc: ${v.depositPercent}% · Ảnh: ${v.photos.length}/10',
                        style: textTheme.labelSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.space3),
                  Text(v.name, style: textTheme.titleLarge),
                  SizedBox(height: t.space1),
                  Text(v.address, style: textTheme.bodyMedium),
                  SizedBox(height: t.space2),
                  Text(
                    'Tọa độ GPS: ${v.latitude.toStringAsFixed(5)}, ${v.longitude.toStringAsFixed(5)} · Sân hoạt động: $activeCourts/${v.courts.length}',
                    style: textTheme.labelSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(height: t.space4),
                  const Divider(),
                  SizedBox(height: t.space3),
                  Wrap(
                    spacing: t.space2,
                    runSpacing: t.space2,
                    children: [
                      AppButton(
                        label: 'Sửa cơ sở (O-05)',
                        leadingIcon: Icons.edit_outlined,
                        variant: AppButtonVariant.secondary,
                        onPressed: () =>
                            _openCreateOrEdit(existing: v, index: idx),
                      ),
                      AppButton(
                        label: 'Ghim vị trí (O-06)',
                        leadingIcon: Icons.location_on_outlined,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _openPinMap(idx),
                      ),
                      AppButton(
                        label: 'Sân con (${v.courts.length}) (O-07)',
                        leadingIcon: Icons.grid_view_outlined,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _openSubCourts(idx),
                      ),
                      AppButton(
                        label: 'Bảng giá & Giờ mở (O-08)',
                        leadingIcon: Icons.schedule_outlined,
                        variant: AppButtonVariant.primary,
                        onPressed: () => _openPricingHours(v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// FE-16: Man hinh O-05 Tao / Sua co so san (Ten, dia chi, mo ta, toi da 10 anh sap xep duoc, tien ich, % coc, Gui duyet).
class OwnerVenueFormScreen extends StatefulWidget {
  final OwnerVenueRecord? initialVenue;

  const OwnerVenueFormScreen({super.key, this.initialVenue});

  @override
  State<OwnerVenueFormScreen> createState() => _OwnerVenueFormScreenState();
}

class _OwnerVenueFormScreenState extends State<OwnerVenueFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _descCtrl;
  late int _depositPercent;
  late List<String> _photos;
  late Set<String> _selectedAmenities;

  @override
  void initState() {
    super.initState();
    final v = widget.initialVenue;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _addrCtrl = TextEditingController(text: v?.address ?? '');
    _descCtrl = TextEditingController(text: v?.description ?? '');
    _depositPercent = v?.depositPercent ?? 30;
    _photos = List.of(v?.photos ?? ['anh_san_chinh_01.jpg']);
    _selectedAmenities = Set.of(
      v?.amenities ?? ['Giữ xe máy miễn phí', 'Wifi tốc độ cao'],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmitForReview =>
      _nameCtrl.text.trim().length >= 3 &&
      _addrCtrl.text.trim().length >= 5 &&
      _photos.isNotEmpty &&
      _selectedAmenities.isNotEmpty;

  void _addPhoto() {
    if (_photos.length >= 10) return;
    setState(() {
      _photos.add('anh_san_cau_long_0${_photos.length + 1}.jpg');
    });
  }

  void _movePhoto(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _photos.length) return;
    setState(() {
      final item = _photos.removeAt(index);
      _photos.insert(target, item);
    });
  }

  void _saveVenue({required bool submitForApproval}) {
    final base = widget.initialVenue;
    final record = OwnerVenueRecord(
      id: base?.id ?? 'ov-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim().isEmpty
          ? 'Cơ sở sân mới'
          : _nameCtrl.text.trim(),
      address: _addrCtrl.text.trim().isEmpty
          ? 'Chưa cập nhật địa chỉ'
          : _addrCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      latitude: base?.latitude ?? 10.776889,
      longitude: base?.longitude ?? 106.700806,
      depositPercent: _depositPercent,
      photos: _photos,
      amenities: _selectedAmenities.toList(),
      status: submitForApproval
          ? CourtBookingStatus.pending
          : CourtBookingStatus.draftOrExpired,
      statusLabel: submitForApproval ? 'Chờ duyệt' : 'Nháp',
      courts: base?.courts ??
          const [
            OwnerSubCourt(id: 'c1', name: 'Sân 01'),
            OwnerSubCourt(id: 'c2', name: 'Sân 02'),
          ],
    );
    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialVenue == null
              ? 'O-05 Tạo cơ sở sân mới'
              : 'O-05 Chỉnh sửa cơ sở sân',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(t.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Tên cơ sở sân cầu lông',
                  hintText: 'Ví dụ: Sân Cầu Lông Phú Thọ Arena',
                  controller: _nameCtrl,
                  prefixIcon: Icons.stadium_outlined,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: t.space4),
                AppTextField(
                  label: 'Địa chỉ chi tiết',
                  hintText: 'Số nhà, đường, phường/xã, quận/huyện',
                  controller: _addrCtrl,
                  prefixIcon: Icons.place_outlined,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: t.space4),
                AppTextField(
                  label: 'Mô tả mặt sân & ánh sáng',
                  hintText: 'Thảm PVC, độ cao trần, hệ thống đèn LED chống chói...',
                  controller: _descCtrl,
                  prefixIcon: Icons.notes_rounded,
                ),
                SizedBox(height: t.space6),

                // % Tien coc khi dat san
                Text(
                  'Tỷ lệ đặt cọc yêu cầu khi giữ chỗ',
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: t.space2),
                Wrap(
                  spacing: t.space2,
                  runSpacing: t.space2,
                  children: [0, 30, 50, 100].map((pct) {
                    final selected = _depositPercent == pct;
                    return ChoiceChip(
                      label: Text(pct == 0 ? 'Không cọc (0%)' : 'Cọc $pct%'),
                      selected: selected,
                      onSelected: (_) => setState(() => _depositPercent = pct),
                    );
                  }).toList(),
                ),
                SizedBox(height: t.space6),

                // Tien ich san (Chip)
                Text(
                  'Tiện ích tại sân (${_selectedAmenities.length} đã chọn)',
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: t.space2),
                Wrap(
                  spacing: t.space2,
                  runSpacing: t.space2,
                  children: OwnerVenueRecord.availableAmenities.map((amenity) {
                    final selected = _selectedAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity),
                      selected: selected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedAmenities.add(amenity);
                          } else {
                            _selectedAmenities.remove(amenity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: t.space6),

                // Danh sach anh (toi da 10 anh, sap xep thu tu)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ảnh thực tế cơ sở (${_photos.length}/10)',
                      style: textTheme.titleMedium,
                    ),
                    AppButton(
                      label: 'Thêm ảnh',
                      leadingIcon: Icons.add_photo_alternate_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: _photos.length < 10 ? _addPhoto : null,
                    ),
                  ],
                ),
                SizedBox(height: t.space2),
                ...List.generate(_photos.length, (i) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: t.space2),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: t.space3,
                        vertical: t.space2,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceCard,
                        borderRadius: BorderRadius.circular(t.radiusControl),
                        border: Border.all(color: t.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.image_outlined, color: t.actionPrimary),
                          SizedBox(width: t.space2),
                          Expanded(
                            child: Text(
                              'Ảnh #${i + 1}: ${_photos[i]}',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Đưa lên trên',
                            onPressed: i > 0 ? () => _movePhoto(i, -1) : null,
                            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                          ),
                          IconButton(
                            tooltip: 'Đưa xuống dưới',
                            onPressed: i < _photos.length - 1
                                ? () => _movePhoto(i, 1)
                                : null,
                            icon:
                                const Icon(Icons.arrow_downward_rounded, size: 18),
                          ),
                          IconButton(
                            tooltip: 'Xóa ảnh',
                            onPressed: _photos.length > 1
                                ? () => setState(() => _photos.removeAt(i))
                                : null,
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: t.actionDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: t.space6),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Lưu bản nháp',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _saveVenue(submitForApproval: false),
                      ),
                    ),
                    SizedBox(width: t.space3),
                    Expanded(
                      child: AppButton(
                        label: 'Gửi Admin duyệt',
                        variant: AppButtonVariant.primary,
                        onPressed: _canSubmitForReview
                            ? () => _saveVenue(submitForApproval: true)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// FE-17: Man hinh O-06 Ghim vi tri tren ban do (keo marker + geocode tu dia chi).
class OwnerPinLocationScreen extends StatefulWidget {
  final OwnerVenueRecord venue;

  const OwnerPinLocationScreen({super.key, required this.venue});

  @override
  State<OwnerPinLocationScreen> createState() => _OwnerPinLocationScreenState();
}

class _OwnerPinLocationScreenState extends State<OwnerPinLocationScreen> {
  late final TextEditingController _addressCtrl;
  late double _lat;
  late double _lng;
  Offset _markerOffset = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    _addressCtrl = TextEditingController(text: widget.venue.address);
    _lat = widget.venue.latitude;
    _lng = widget.venue.longitude;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  void _geocodeAddress() {
    setState(() {
      _lat = 10.776889 + (_addressCtrl.text.length % 7) * 0.0012;
      _lng = 106.700806 + (_addressCtrl.text.length % 5) * 0.0015;
      _markerOffset = Offset.zero;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã định vị tọa độ theo địa chỉ nhập (GET /public/geocode).'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('O-06 Ghim vị trí cơ sở trên bản đồ')),
      body: Padding(
        padding: EdgeInsets.all(t.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Tìm tọa độ từ địa chỉ (Geocode)',
                    controller: _addressCtrl,
                    prefixIcon: Icons.search_rounded,
                  ),
                ),
                SizedBox(width: t.space2),
                AppButton(
                  label: 'Định vị',
                  variant: AppButtonVariant.secondary,
                  onPressed: _geocodeAddress,
                ),
              ],
            ),
            SizedBox(height: t.space4),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _markerOffset += details.delta;
                    _lat -= details.delta.dy * 0.00005;
                    _lng += details.delta.dx * 0.00005;
                  });
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: t.surfaceMuted,
                    borderRadius: BorderRadius.circular(t.radiusCard),
                    border: Border.all(color: t.borderSubtle),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Luoi ban do mo phong truc quan
                      Padding(
                        padding: EdgeInsets.all(t.space4),
                        child: Text(
                          'Kéo thả tâm ghim trên vùng bản đồ này để tinh chỉnh chính xác vị trí cổng vào sân cầu lông.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                      Transform.translate(
                        offset: _markerOffset,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: t.space3,
                                vertical: t.space1,
                              ),
                              decoration: BoxDecoration(
                                color: t.actionPrimary,
                                borderRadius:
                                    BorderRadius.circular(t.radiusControl),
                              ),
                              child: Text(
                                widget.venue.name,
                                style: textTheme.labelSmall?.copyWith(
                                  color: t.onActionPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on_rounded,
                              size: 44,
                              color: t.actionDanger,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: t.space4),
            Container(
              padding: EdgeInsets.all(t.space4),
              decoration: BoxDecoration(
                color: t.surfaceCard,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(color: t.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tọa độ ghim hiện tại', style: textTheme.labelSmall),
                      Text(
                        'Lat: ${_lat.toStringAsFixed(6)} · Lng: ${_lng.toStringAsFixed(6)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  AppButton(
                    label: 'Xác nhận tọa độ',
                    onPressed: () {
                      Navigator.of(context).pop(
                        widget.venue.copyWith(
                          address: _addressCtrl.text.trim(),
                          latitude: _lat,
                          longitude: _lng,
                        ),
                      );
                    },
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

/// FE-18: Man hinh O-07 Quan ly San con (them, doi ten, cong tac Hoat dong / Bao tri co canh bao luot dat tuong lai).
class OwnerSubCourtsScreen extends StatefulWidget {
  final OwnerVenueRecord venue;

  const OwnerSubCourtsScreen({super.key, required this.venue});

  @override
  State<OwnerSubCourtsScreen> createState() => _OwnerSubCourtsScreenState();
}

class _OwnerSubCourtsScreenState extends State<OwnerSubCourtsScreen> {
  late List<OwnerSubCourt> _courts;
  final TextEditingController _newCourtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _courts = List.of(widget.venue.courts);
  }

  @override
  void dispose() {
    _newCourtCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleCourtStatus(int index, bool setActive) async {
    final court = _courts[index];
    final targetMaintenance = !setActive;

    // Neu chuyen sang Bao tri ma con luot dat tuong lai -> bat ConfirmDialog canh bao (O-07)
    if (targetMaintenance && court.futureBookingsCount > 0) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Chuyển ${court.name} sang Bảo trì?',
        message:
            'Sân này đang có ${court.futureBookingsCount} lượt đặt trong tương lai. Nếu tạm ngưng hoạt động, bạn cần chuyển sân hoặc hoàn tiền cho khách.',
        confirmLabel: 'Xác nhận bảo trì',
        isDestructive: true,
      );
      if (confirmed != true) return;
    }

    setState(() {
      _courts[index] = court.copyWith(isMaintenance: targetMaintenance);
    });
  }

  void _addCourt() {
    final name = _newCourtCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _courts.add(
        OwnerSubCourt(
          id: 'c-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
        ),
      );
      _newCourtCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('O-07 Sân con: ${widget.venue.name}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(t.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Thêm sân con mới',
                    hintText: 'Ví dụ: Sân 05 (Thảm tiêu chuẩn)',
                    controller: _newCourtCtrl,
                    prefixIcon: Icons.add_box_outlined,
                  ),
                ),
                SizedBox(width: t.space2),
                AppButton(
                  label: 'Thêm sân',
                  onPressed: _addCourt,
                ),
              ],
            ),
            SizedBox(height: t.space6),
            Expanded(
              child: ListView.separated(
                itemCount: _courts.length,
                separatorBuilder: (_, _) => SizedBox(height: t.space3),
                itemBuilder: (ctx, i) {
                  final c = _courts[i];
                  return Container(
                    padding: EdgeInsets.all(t.space4),
                    decoration: BoxDecoration(
                      color: t.surfaceCard,
                      borderRadius: BorderRadius.circular(t.radiusCard),
                      border: Border.all(color: t.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: textTheme.titleMedium),
                              SizedBox(height: t.space1),
                              Row(
                                children: [
                                  StatusChip(
                                    status: c.isMaintenance
                                        ? CourtBookingStatus
                                            .maintenanceOrOccupied
                                        : CourtBookingStatus.activeConfirmed,
                                    customLabel: c.isMaintenance
                                        ? 'Đang bảo trì'
                                        : 'Đang hoạt động',
                                  ),
                                  SizedBox(width: t.space2),
                                  Text(
                                    'Lượt đặt sắp tới: ${c.futureBookingsCount}',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: !c.isMaintenance,
                          activeTrackColor: t.actionPrimary,
                          onChanged: (val) => _toggleCourtStatus(i, val),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: t.space4),
            AppButton(
              label: 'Lưu danh sách sân con',
              expandWidth: true,
              onPressed: () {
                Navigator.of(context).pop(
                  widget.venue.copyWith(courts: _courts),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// FE-18: Man hinh O-08 Bang gia (Ngay thuong / Cuoi tuan, bao loi chong lan ngay khi nhap) & Gio mo cua 7 ngay.
class OwnerPricingHoursScreen extends StatefulWidget {
  final String venueName;

  const OwnerPricingHoursScreen({super.key, required this.venueName});

  @override
  State<OwnerPricingHoursScreen> createState() =>
      _OwnerPricingHoursScreenState();
}

class _OwnerPricingHoursScreenState extends State<OwnerPricingHoursScreen> {
  bool _weekendTab = false;

  final List<VenuePriceRule> _weekdayRules = [
    const VenuePriceRule(
      id: 'w1',
      isWeekend: false,
      startHour: 5,
      endHour: 17,
      pricePerHourVnd: 100000,
    ),
    const VenuePriceRule(
      id: 'w2',
      isWeekend: false,
      startHour: 17,
      endHour: 22,
      pricePerHourVnd: 140000,
    ),
  ];

  final List<VenuePriceRule> _weekendRules = [
    const VenuePriceRule(
      id: 'we1',
      isWeekend: true,
      startHour: 5,
      endHour: 22,
      pricePerHourVnd: 150000,
    ),
  ];

  final List<OperatingDaySchedule> _days = [
    const OperatingDaySchedule(dayName: 'Thứ Hai'),
    const OperatingDaySchedule(dayName: 'Thứ Ba'),
    const OperatingDaySchedule(dayName: 'Thứ Tư'),
    const OperatingDaySchedule(dayName: 'Thứ Năm'),
    const OperatingDaySchedule(dayName: 'Thứ Sáu'),
    const OperatingDaySchedule(dayName: 'Thứ Bảy'),
    const OperatingDaySchedule(dayName: 'Chủ Nhật'),
  ];

  List<VenuePriceRule> get _activeRules =>
      _weekendTab ? _weekendRules : _weekdayRules;

  void _simulateOverlap() {
    setState(() {
      if (_weekendTab) {
        _weekendRules.add(
          const VenuePriceRule(
            id: 'we-overlap',
            isWeekend: true,
            startHour: 18,
            endHour: 21,
            pricePerHourVnd: 170000,
          ),
        );
      } else {
        _weekdayRules[1] = _weekdayRules[1].copyWith(startHour: 15);
      }
    });
  }

  void _fixOverlap() {
    setState(() {
      if (_weekendTab && _weekendRules.length > 1) {
        _weekendRules.removeLast();
      } else {
        _weekdayRules[0] =
            _weekdayRules[0].copyWith(startHour: 5, endHour: 17);
        _weekdayRules[1] =
            _weekdayRules[1].copyWith(startHour: 17, endHour: 22);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final overlapError = VenuePriceRule.findOverlapError(_activeRules);

    return Scaffold(
      appBar: AppBar(title: Text('O-08 Bảng giá & Giờ mở: ${widget.venueName}')),
      body: ListView(
        padding: EdgeInsets.all(t.space6),
        children: [
          // Chuyen tab Ngay thuong / Cuoi tuan
          Row(
            children: [
              ChoiceChip(
                label: const Text('Ngày thường (Thứ 2 - Thứ 6)'),
                selected: !_weekendTab,
                onSelected: (_) => setState(() => _weekendTab = false),
              ),
              SizedBox(width: t.space2),
              ChoiceChip(
                label: const Text('Cuối tuần (Thứ 7 - CN)'),
                selected: _weekendTab,
                onSelected: (_) => setState(() => _weekendTab = true),
              ),
            ],
          ),
          SizedBox(height: t.space4),

          // Canh bao chong lan khung gio ngay khi nhap (O-08)
          if (overlapError != null) ...[
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
                    Icons.error_outline_rounded,
                    color: t.statusCancelled.foreground,
                  ),
                  SizedBox(width: t.space3),
                  Expanded(
                    child: Text(
                      overlapError,
                      style: textTheme.bodyMedium?.copyWith(
                        color: t.statusCancelled.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AppButton(
                    label: 'Tự sửa mốc giờ',
                    variant: AppButtonVariant.secondary,
                    onPressed: _fixOverlap,
                  ),
                ],
              ),
            ),
            SizedBox(height: t.space4),
          ],

          ...List.generate(_activeRules.length, (i) {
            final rule = _activeRules[i];
            return Padding(
              padding: EdgeInsets.only(bottom: t.space3),
              child: Container(
                padding: EdgeInsets.all(t.space4),
                decoration: BoxDecoration(
                  color: t.surfaceCard,
                  borderRadius: BorderRadius.circular(t.radiusCard),
                  border: Border.all(color: t.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khung giờ #${i + 1}: ${rule.startHour.toString().padLeft(2, '0')}:00 đến ${rule.endHour.toString().padLeft(2, '0')}:00',
                          style: textTheme.titleMedium?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        SizedBox(height: t.space1),
                        PriceText(
                          amountVnd: rule.pricePerHourVnd,
                          suffix: '/giờ',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Lùi giờ bắt đầu 1 tiếng',
                          onPressed: rule.startHour > 5
                              ? () => setState(() {
                                    _activeRules[i] = rule.copyWith(
                                      startHour: rule.startHour - 1,
                                    );
                                  })
                              : null,
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                        ),
                        IconButton(
                          tooltip: 'Tăng giờ bắt đầu 1 tiếng',
                          onPressed: rule.startHour < 22
                              ? () => setState(() {
                                    _activeRules[i] = rule.copyWith(
                                      startHour: rule.startHour + 1,
                                    );
                                  })
                              : null,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'Thử nhập khung giờ chồng lấn (Test báo lỗi O-08)',
              variant: AppButtonVariant.secondary,
              onPressed: _simulateOverlap,
            ),
          ),

          SizedBox(height: t.space6),
          Text('Giờ mở cửa 7 ngày trong tuần', style: textTheme.titleLarge),
          SizedBox(height: t.space3),

          ...List.generate(_days.length, (idx) {
            final d = _days[idx];
            return Padding(
              padding: EdgeInsets.only(bottom: t.space2),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: t.space4,
                  vertical: t.space2,
                ),
                decoration: BoxDecoration(
                  color: t.surfaceCard,
                  borderRadius: BorderRadius.circular(t.radiusControl),
                  border: Border.all(color: t.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d.dayName, style: textTheme.titleMedium),
                    Text(
                      d.isClosed
                          ? 'Nghỉ đóng cửa'
                          : '${d.openHour.toString().padLeft(2, '0')}:00 - ${d.closeHour.toString().padLeft(2, '0')}:00',
                      style: textTheme.bodyMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Switch(
                      value: !d.isClosed,
                      activeTrackColor: t.actionPrimary,
                      onChanged: (open) {
                        setState(() {
                          _days[idx] = d.copyWith(isClosed: !open);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: t.space6),
          AppButton(
            label: 'Lưu bảng giá & giờ mở cửa',
            expandWidth: true,
            onPressed: overlapError == null
                ? () => Navigator.of(context).pop()
                : null,
          ),
        ],
      ),
    );
  }
}
