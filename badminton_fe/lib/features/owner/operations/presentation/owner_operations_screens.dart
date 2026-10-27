import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/status_chip.dart';

/// Model mot luot dat san hien thi tren O-03 (Hom nay), O-10 (Timeline) va O-11 (Chi tiet Owner).
class OwnerCourtBookingItem {
  final String id;
  final String bookingCode;
  final String customerName;
  final String customerPhone;
  final String courtId;
  final String courtName;
  final int startHour;
  final int durationHours;
  final int totalAmountVnd;
  final int paidAmountVnd;
  final CourtBookingStatus status;
  final String paymentMethodLabel;
  final String? note;

  const OwnerCourtBookingItem({
    required this.id,
    required this.bookingCode,
    required this.customerName,
    required this.customerPhone,
    required this.courtId,
    required this.courtName,
    required this.startHour,
    this.durationHours = 1,
    required this.totalAmountVnd,
    required this.paidAmountVnd,
    required this.status,
    required this.paymentMethodLabel,
    this.note,
  });

  int get remainingAmountVnd =>
      (totalAmountVnd - paidAmountVnd).clamp(0, 999999999);

  String get timeRangeLabel {
    final s = startHour.toString().padLeft(2, '0');
    final e = (startHour + durationHours).toString().padLeft(2, '0');
    return '$s:00 - $e:00';
  }

  OwnerCourtBookingItem copyWith({
    CourtBookingStatus? status,
    int? paidAmountVnd,
    String? note,
  }) {
    return OwnerCourtBookingItem(
      id: id,
      bookingCode: bookingCode,
      customerName: customerName,
      customerPhone: customerPhone,
      courtId: courtId,
      courtName: courtName,
      startHour: startHour,
      durationHours: durationHours,
      totalAmountVnd: totalAmountVnd,
      paidAmountVnd: paidAmountVnd ?? this.paidAmountVnd,
      status: status ?? this.status,
      paymentMethodLabel: paymentMethodLabel,
      note: note ?? this.note,
    );
  }
}

/// Kho du lieu van hanh trong ngay cua Chu san (O-03, O-10, O-11, O-12, O-13).
class FakeOwnerOperationsStore extends ChangeNotifier {
  static final FakeOwnerOperationsStore instance =
      FakeOwnerOperationsStore._internal();

  FakeOwnerOperationsStore._internal();

  static const List<Map<String, String>> courts = [
    {'id': 'C1', 'name': 'Sân 1 (Thảm Yonex)'},
    {'id': 'C2', 'name': 'Sân 2 (Thảm Victor)'},
    {'id': 'C3', 'name': 'Sân 3 (Thảm Kumpoo)'},
    {'id': 'C4', 'name': 'Sân 4 (Tiêu chuẩn)'},
  ];

  static const List<int> operatingHours = [
    6, 7, 8, 9, 10, 11, 14, 15, 16, 17, 18, 19, 20, 21
  ];

  final List<OwnerCourtBookingItem> _bookings = [
    const OwnerCourtBookingItem(
      id: 'OB-101',
      bookingCode: 'BM-2026-0891',
      customerName: 'Nguyễn Văn A',
      customerPhone: '0901234567',
      courtId: 'C1',
      courtName: 'Sân 1 (Thảm Yonex)',
      startHour: 18,
      durationHours: 2,
      totalAmountVnd: 240000,
      paidAmountVnd: 240000,
      status: CourtBookingStatus.activeConfirmed,
      paymentMethodLabel: 'PayOS VietQR (Đã trả 100%)',
    ),
    const OwnerCourtBookingItem(
      id: 'OB-102',
      bookingCode: 'BM-2026-0942',
      customerName: 'Trần Minh Hoàng',
      customerPhone: '0988776655',
      courtId: 'C2',
      courtName: 'Sân 2 (Thảm Victor)',
      startHour: 17,
      durationHours: 1,
      totalAmountVnd: 120000,
      paidAmountVnd: 36000,
      status: CourtBookingStatus.pending,
      paymentMethodLabel: 'Đặt cọc 30% qua PayOS (Chờ xác nhận)',
    ),
    const OwnerCourtBookingItem(
      id: 'OB-103',
      bookingCode: 'BM-2026-0955',
      customerName: 'Lê Thị Thu Thủy',
      customerPhone: '0912345678',
      courtId: 'C3',
      courtName: 'Sân 3 (Thảm Kumpoo)',
      startHour: 19,
      durationHours: 1,
      totalAmountVnd: 120000,
      paidAmountVnd: 0,
      status: CourtBookingStatus.pending,
      paymentMethodLabel: 'Trả tiền mặt tại sân (Chờ chủ sân duyệt)',
    ),
    const OwnerCourtBookingItem(
      id: 'OB-104',
      bookingCode: 'BM-2026-0712',
      customerName: 'Phạm Quốc Bảo',
      customerPhone: '0933445566',
      courtId: 'C1',
      courtName: 'Sân 1 (Thảm Yonex)',
      startHour: 7,
      durationHours: 2,
      totalAmountVnd: 180000,
      paidAmountVnd: 180000,
      status: CourtBookingStatus.completedOrCheckedIn,
      paymentMethodLabel: 'Đã check-in lúc 06:55',
    ),
    const OwnerCourtBookingItem(
      id: 'OB-105',
      bookingCode: 'BM-2026-0604',
      customerName: 'Hoàng Gia Huy',
      customerPhone: '0977112233',
      courtId: 'C4',
      courtName: 'Sân 4 (Tiêu chuẩn)',
      startHour: 20,
      durationHours: 1,
      totalAmountVnd: 110000,
      paidAmountVnd: 0,
      status: CourtBookingStatus.cancelledOrSuspended,
      paymentMethodLabel: 'Khách hủy trước 24h',
      note: 'Hủy do mưa lớn',
    ),
  ];

  List<OwnerCourtBookingItem> get bookings => List.unmodifiable(_bookings);

  int get pendingCount =>
      _bookings.where((b) => b.status == CourtBookingStatus.pending).length;

  int get confirmedCount => _bookings
      .where((b) => b.status == CourtBookingStatus.activeConfirmed)
      .length;

  int get checkedInCount => _bookings
      .where((b) => b.status == CourtBookingStatus.completedOrCheckedIn)
      .length;

  int get cancelledCount => _bookings
      .where((b) => b.status == CourtBookingStatus.cancelledOrSuspended)
      .length;

  int get todayRevenueVnd {
    int sum = 0;
    for (final b in _bookings) {
      if (b.status != CourtBookingStatus.cancelledOrSuspended) {
        sum += b.paidAmountVnd;
      }
    }
    return sum;
  }

  OwnerCourtBookingItem? findSlotBooking(String courtId, int hour) {
    for (final b in _bookings) {
      if (b.status == CourtBookingStatus.cancelledOrSuspended) continue;
      if (b.courtId == courtId &&
          hour >= b.startHour &&
          hour < b.startHour + b.durationHours) {
        return b;
      }
    }
    return null;
  }

  OwnerCourtBookingItem? findByCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final b in _bookings) {
      if (b.bookingCode.toUpperCase() == normalized) return b;
    }
    return null;
  }

  void confirmBooking(String id) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: CourtBookingStatus.activeConfirmed,
      );
      notifyListeners();
    }
  }

  void rejectBooking(String id, String reason) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: CourtBookingStatus.cancelledOrSuspended,
        note: 'Từ chối: $reason',
      );
      notifyListeners();
    }
  }

  void markCheckedIn(String id, {bool collectRemainingCash = true}) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final current = _bookings[idx];
      _bookings[idx] = current.copyWith(
        status: CourtBookingStatus.completedOrCheckedIn,
        paidAmountVnd:
            collectRemainingCash ? current.totalAmountVnd : current.paidAmountVnd,
      );
      notifyListeners();
    }
  }

  void createManualBooking({
    required String courtId,
    required String courtName,
    required int hour,
    required String customerName,
    required String customerPhone,
    required int priceVnd,
    required bool paidCash,
  }) {
    final rand = DateTime.now().millisecondsSinceEpoch.toString().substring(9);
    final newBooking = OwnerCourtBookingItem(
      id: 'OB-M$rand',
      bookingCode: 'BM-2026-M$rand',
      customerName: customerName,
      customerPhone: customerPhone,
      courtId: courtId,
      courtName: courtName,
      startHour: hour,
      durationHours: 1,
      totalAmountVnd: priceVnd,
      paidAmountVnd: paidCash ? priceVnd : 0,
      status: CourtBookingStatus.activeConfirmed,
      paymentMethodLabel:
          paidCash ? 'Khách vãng lai (Đã thu tiền mặt)' : 'Khách vãng lai (Trả sau)',
    );
    _bookings.insert(0, newBooking);
    notifyListeners();
  }
}

/// FE-43: Man hinh O-03 Hom nay & O-10 Timeline dat san cua CourtOwner
/// Tich hop O-11 (Chi tiet luot dat Owner), O-12 (Dat thu cong) va O-13 (Quet QR Check-in).
class OwnerOperationsTodayScreen extends StatefulWidget {
  const OwnerOperationsTodayScreen({super.key});

  @override
  State<OwnerOperationsTodayScreen> createState() =>
      _OwnerOperationsTodayScreenState();
}

class _OwnerOperationsTodayScreenState
    extends State<OwnerOperationsTodayScreen> {
  final FakeOwnerOperationsStore _store = FakeOwnerOperationsStore.instance;
  bool _showTimelineMode = false; // false = O-03 Hom nay, true = O-10 Timeline 2D
  int _selectedDayOffset = 0;
  String _selectedCourtFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreUpdate);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreUpdate);
    super.dispose();
  }

  void _onStoreUpdate() {
    if (mounted) setState(() {});
  }

  void _openQrScanner() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OwnerQrCheckInScreen(),
      ),
    );
  }

  /// O-11: Chi tiet luot dat danh cho Chu san (Xac nhan / Tu choi / Check-in / Goi dien)
  void _openOwnerBookingDetailSheet(OwnerCourtBookingItem item) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final rejectReasonCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusSheet)),
      ),
      builder: (ctx) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'O-11 Chi tiết đơn: ${item.bookingCode}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    StatusChip(
                      status: item.status,
                      customLabel: _statusLabel(item.status),
                    ),
                  ],
                ),
                SizedBox(height: t.space3),
                Container(
                  padding: EdgeInsets.all(t.space3),
                  decoration: BoxDecoration(
                    color: t.surfaceMuted,
                    borderRadius: BorderRadius.circular(t.radiusControl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khách hàng: ${item.customerName}',
                                style: textTheme.titleSmall,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'SĐT: ${item.customerPhone}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                          AppButton(
                            label: 'Gọi khách',
                            leadingIcon: Icons.phone_outlined,
                            variant: AppButtonVariant.secondary,
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: item.customerPhone),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đang quay số gọi ${item.customerName} (${item.customerPhone})...',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        '${item.courtName} | Khung giờ: ${item.timeRangeLabel}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: t.space1),
                      Text(
                        'Hình thức: ${item.paymentMethodLabel}',
                        style: textTheme.bodySmall,
                      ),
                      SizedBox(height: t.space2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng tiền ca:', style: textTheme.bodySmall),
                          PriceText(amountVnd: item.totalAmountVnd),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Đã thu:', style: textTheme.bodySmall),
                          PriceText(amountVnd: item.paidAmountVnd),
                        ],
                      ),
                      if (item.remainingAmountVnd > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Còn phải thu tại quầy:',
                              style: textTheme.bodySmall?.copyWith(
                                color: t.statusCancelled.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            PriceText(amountVnd: item.remainingAmountVnd),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: t.space4),
                if (item.status == CourtBookingStatus.pending) ...[
                  AppTextField(
                    controller: rejectReasonCtrl,
                    label: 'Lý do từ chối (nếu từ chối đơn)',
                    hintText: 'Ví dụ: Sân đang bảo trì đột xuất đèn chiếu sáng...',
                  ),
                  SizedBox(height: t.space3),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Từ chối đơn',
                          variant: AppButtonVariant.danger,
                          onPressed: () {
                            final reason = rejectReasonCtrl.text.trim().isEmpty
                                ? 'Không đủ điều kiện phục vụ khung giờ này'
                                : rejectReasonCtrl.text.trim();
                            _store.rejectBooking(item.id, reason);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã từ chối đơn ${item.bookingCode}.',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: t.space3),
                      Expanded(
                        child: AppButton(
                          label: 'Xác nhận đơn',
                          leadingIcon: Icons.check_rounded,
                          variant: AppButtonVariant.primary,
                          onPressed: () {
                            _store.confirmBooking(item.id);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã xác nhận lịch đặt ${item.bookingCode} cho ${item.customerName}.',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ] else if (item.status == CourtBookingStatus.activeConfirmed) ...[
                  AppButton(
                    label: item.remainingAmountVnd > 0
                        ? 'Check-in & Xác nhận đã thu đủ ${AppFormatters.currencyVnd(item.remainingAmountVnd)}'
                        : 'Check-in nhận sân ngay',
                    leadingIcon: Icons.qr_code_scanner_rounded,
                    variant: AppButtonVariant.primary,
                    expandWidth: true,
                    onPressed: () {
                      _store.markCheckedIn(item.id);
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã check-in thành công cho khách ${item.customerName}!',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// O-12: Dat san thu cong cho khach vang lai tai quay
  void _openManualBookingDialog({
    String initialCourtId = 'C1',
    int initialHour = 16,
  }) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final nameCtrl = TextEditingController(text: 'Khách vãng lai');
    final phoneCtrl = TextEditingController(text: '0909888777');
    String selectedCourtId = initialCourtId;
    int selectedHour = initialHour;
    bool paidCash = true;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            final courtMap = FakeOwnerOperationsStore.courts.firstWhere(
              (c) => c['id'] == selectedCourtId,
              orElse: () => FakeOwnerOperationsStore.courts.first,
            );

            return AlertDialog(
              backgroundColor: t.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t.radiusCard),
              ),
              title: Text(
                'O-12 Đặt sân thủ công tại quầy',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chọn sân con:', style: textTheme.labelMedium),
                    SizedBox(height: t.space1),
                    Wrap(
                      spacing: t.space2,
                      runSpacing: t.space1,
                      children: FakeOwnerOperationsStore.courts.map((c) {
                        final selected = c['id'] == selectedCourtId;
                        return ChoiceChip(
                          label: Text(c['name']!),
                          selected: selected,
                          onSelected: (_) =>
                              setDlgState(() => selectedCourtId = c['id']!),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: t.space3),
                    Text(
                      'Khung giờ: ${AppFormatters.timeSlotRange(selectedHour)}',
                      style: textTheme.titleSmall,
                    ),
                    SizedBox(height: t.space3),
                    AppTextField(
                      controller: nameCtrl,
                      label: 'Tên khách hàng',
                      hintText: 'Nhập tên khách đặt trực tiếp',
                    ),
                    SizedBox(height: t.space3),
                    AppTextField(
                      controller: phoneCtrl,
                      label: 'Số điện thoại khách',
                      hintText: 'Nhập SĐT liên hệ',
                    ),
                    SizedBox(height: t.space2),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Đã thu tiền mặt (120.000đ)'),
                      value: paidCash,
                      onChanged: (val) => setDlgState(() => paidCash = val),
                    ),
                  ],
                ),
              ),
              actions: [
                AppButton(
                  label: 'Hủy',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                AppButton(
                  label: 'Tạo lượt đặt',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    _store.createManualBooking(
                      courtId: selectedCourtId,
                      courtName: courtMap['name']!,
                      hour: selectedHour,
                      customerName: nameCtrl.text.trim().isEmpty
                          ? 'Khách vãng lai'
                          : nameCtrl.text.trim(),
                      customerPhone: phoneCtrl.text.trim(),
                      priceVnd: 120000,
                      paidCash: paidCash,
                    );
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đã thêm lượt đặt thủ công lên Timeline O-10.',
                        ),
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

  String _statusLabel(CourtBookingStatus status) {
    switch (status) {
      case CourtBookingStatus.activeConfirmed:
        return 'Đã xác nhận';
      case CourtBookingStatus.pending:
        return 'Chờ xác nhận';
      case CourtBookingStatus.completedOrCheckedIn:
        return 'Đã check-in';
      case CourtBookingStatus.cancelledOrSuspended:
        return 'Đã hủy';
      case CourtBookingStatus.maintenanceOrOccupied:
        return 'Bảo trì';
      case CourtBookingStatus.draftOrExpired:
        return 'Hết hạn';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        // 1. Header Thong ke O-03 Hom nay + Nut Quet QR Check-in O-13
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
              Wrap(
                spacing: t.space2,
                runSpacing: t.space2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const StatusChip(
                    status: CourtBookingStatus.completedOrCheckedIn,
                    customLabel: 'O-03 Vận hành hôm nay (27/10/2026)',
                  ),
                  Text(
                    'Sân Cầu Lông Hỏa Châu',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: t.actionPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: t.space3),
              Text('Doanh thu đã thu hôm nay', style: textTheme.bodySmall),
              PriceText(amountVnd: _store.todayRevenueVnd, isHero: true),
              SizedBox(height: t.space3),
              AppButton(
                label: 'Quét QR Check-in (O-13)',
                leadingIcon: Icons.qr_code_scanner_rounded,
                variant: AppButtonVariant.primary,
                expandWidth: true,
                onPressed: _openQrScanner,
              ),
              SizedBox(height: t.space4),

              // 4 The dem trang thai trong ngay
              Wrap(
                spacing: t.space2,
                runSpacing: t.space2,
                children: [
                  _buildMetricBadge(
                    context,
                    label: 'Chờ duyệt',
                    count: _store.pendingCount,
                    pair: t.statusPending,
                  ),
                  _buildMetricBadge(
                    context,
                    label: 'Sắp tới',
                    count: _store.confirmedCount,
                    pair: t.statusActive,
                  ),
                  _buildMetricBadge(
                    context,
                    label: 'Đã check-in',
                    count: _store.checkedInCount,
                    pair: t.statusCompleted,
                  ),
                  _buildMetricBadge(
                    context,
                    label: 'Đã hủy',
                    count: _store.cancelledCount,
                    pair: t.statusCancelled,
                  ),
                ],
              ),
              SizedBox(height: t.space4),

              // Thanh chuyen doi giua O-03 Danh sach & O-10 Timeline 2D
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'O-03 Danh sách hôm nay',
                      leadingIcon: Icons.view_agenda_outlined,
                      variant: !_showTimelineMode
                          ? AppButtonVariant.primary
                          : AppButtonVariant.secondary,
                      onPressed: () => setState(() => _showTimelineMode = false),
                    ),
                  ),
                  SizedBox(width: t.space2),
                  Expanded(
                    child: AppButton(
                      label: 'O-10 Timeline đặt sân',
                      leadingIcon: Icons.grid_on_rounded,
                      variant: _showTimelineMode
                          ? AppButtonVariant.primary
                          : AppButtonVariant.secondary,
                      onPressed: () => setState(() => _showTimelineMode = true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: t.space2),
              AppButton(
                label: 'Đặt tại quầy (O-12)',
                leadingIcon: Icons.add_rounded,
                variant: AppButtonVariant.secondary,
                expandWidth: true,
                onPressed: () => _openManualBookingDialog(),
              ),
            ],
          ),
        ),
        SizedBox(height: t.space4),

        if (_showTimelineMode)
          _buildTimelineView(context)
        else
          _buildTodayListView(context),
      ],
    );
  }

  Widget _buildMetricBadge(
    BuildContext context, {
    required String label,
    required int count,
    required StatusColorPair pair,
  }) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.space3,
        vertical: t.space2,
      ),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(t.radiusControl),
        border: Border.all(color: pair.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: textTheme.titleMedium?.copyWith(
              color: pair.foreground,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(width: t.space2),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: pair.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// O-03: Danh sach luot cho xac nhan & luot sap toi trong ngay
  Widget _buildTodayListView(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    final pendingList = _store.bookings
        .where((b) => b.status == CourtBookingStatus.pending)
        .toList();
    final activeList = _store.bookings
        .where((b) => b.status != CourtBookingStatus.pending)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingList.isNotEmpty) ...[
          Text(
            'Lượt đặt chờ xác nhận (${pendingList.length})',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: t.space2),
          ...pendingList.map((b) => _buildBookingRowCard(context, b)),
          SizedBox(height: t.space4),
        ],
        Text(
          'Tất cả ca thi đấu hôm nay (${activeList.length})',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: t.space2),
        ...activeList.map((b) => _buildBookingRowCard(context, b)),
      ],
    );
  }

  Widget _buildBookingRowCard(BuildContext context, OwnerCourtBookingItem item) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: t.space3),
      child: InkWell(
        onTap: () => _openOwnerBookingDetailSheet(item),
        borderRadius: BorderRadius.circular(t.radiusCard),
        child: Container(
          padding: EdgeInsets.all(t.space4),
          decoration: BoxDecoration(
            color: t.surfaceCard,
            borderRadius: BorderRadius.circular(t.radiusCard),
            border: Border.all(
              color: item.status == CourtBookingStatus.pending
                  ? t.statusPending.border
                  : t.borderSubtle,
              width: item.status == CourtBookingStatus.pending ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.bookingCode} | ${item.courtName}',
                      style: textTheme.labelMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: t.space2),
                  StatusChip(
                    status: item.status,
                    customLabel: _statusLabel(item.status),
                  ),
                ],
              ),
              SizedBox(height: t.space2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.customerName} (${item.customerPhone})',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Giờ chơi: ${item.timeRangeLabel} | ${item.paymentMethodLabel}',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: t.space2),
                  PriceText(amountVnd: item.totalAmountVnd),
                ],
              ),
              if (item.status == CourtBookingStatus.pending) ...[
                SizedBox(height: t.space3),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Chi tiết / Từ chối',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _openOwnerBookingDetailSheet(item),
                      ),
                    ),
                    SizedBox(width: t.space2),
                    Expanded(
                      child: AppButton(
                        label: 'Xác nhận ngay',
                        leadingIcon: Icons.check_rounded,
                        variant: AppButtonVariant.primary,
                        onPressed: () => _store.confirmBooking(item.id),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// O-10: Timeline dat san (Truc gio ngang x San con doc, loc san con)
  Widget _buildTimelineView(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final baseDate = DateTime(2026, 10, 27);

    final visibleCourts = FakeOwnerOperationsStore.courts.where((c) {
      if (_selectedCourtFilter == 'ALL') return true;
      return c['id'] == _selectedCourtFilter;
    }).toList();

    return Container(
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
            'O-10 Timeline đặt sân (Trục giờ ngang x Sân con dọc)',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: t.space1),
          Text(
            'Chạm vào khối có khách để xem chi tiết O-11, chạm vào ô trống để Đặt thủ công O-12.',
            style: textTheme.bodySmall,
          ),
          SizedBox(height: t.space3),

          // Chon ngay va loc san con
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(5, (i) {
                  final d = baseDate.add(Duration(days: i));
                  final selected = _selectedDayOffset == i;
                  return Padding(
                    padding: EdgeInsets.only(right: t.space2),
                    child: ChoiceChip(
                      label: Text(
                        i == 0 ? 'Hôm nay (${AppFormatters.dateVn(d)})' : AppFormatters.dateVn(d),
                      ),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedDayOffset = i),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: t.space2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả sân con (4)'),
                  selected: _selectedCourtFilter == 'ALL',
                  onSelected: (_) => setState(() => _selectedCourtFilter = 'ALL'),
                ),
                SizedBox(width: t.space2),
                ...FakeOwnerOperationsStore.courts.map((c) {
                  final selected = _selectedCourtFilter == c['id'];
                  return Padding(
                    padding: EdgeInsets.only(right: t.space2),
                    child: ChoiceChip(
                      label: Text(c['name']!),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCourtFilter = c['id']!),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // Bang 2 chieu: Cot dau tien la San con, cac cot ngang la Khung gio
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header truc gio ngang
                Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        'Sân con \\ Giờ',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ...FakeOwnerOperationsStore.operatingHours.map((h) {
                      return Container(
                        width: 112,
                        padding: EdgeInsets.all(t.space2),
                        alignment: Alignment.center,
                        child: Text(
                          '${h.toString().padLeft(2, '0')}:00',
                          style: textTheme.labelSmall?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const Divider(),
                // Cac hang san con doc
                ...visibleCourts.map((court) {
                  final courtId = court['id']!;
                  final courtName = court['name']!;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: t.space1),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            courtName,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ...FakeOwnerOperationsStore.operatingHours.map((hour) {
                          final booking = _store.findSlotBooking(courtId, hour);
                          final isBooked = booking != null;
                          final pair = isBooked
                              ? t.pairForStatus(booking.status)
                              : t.statusDraft;

                          return Padding(
                            padding: const EdgeInsets.all(3),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(t.radiusControl),
                              onTap: () {
                                if (isBooked) {
                                  _openOwnerBookingDetailSheet(booking);
                                } else {
                                  _openManualBookingDialog(
                                    initialCourtId: courtId,
                                    initialHour: hour,
                                  );
                                }
                              },
                              child: Container(
                                width: 106,
                                height: 64,
                                padding: EdgeInsets.all(t.space2),
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? pair.background
                                      : t.surfaceMuted,
                                  borderRadius:
                                      BorderRadius.circular(t.radiusControl),
                                  border: Border.all(
                                    color:
                                        isBooked ? pair.border : t.borderSubtle,
                                    width: isBooked ? 1.5 : 1.0,
                                  ),
                                ),
                                child: isBooked
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            booking.customerName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                textTheme.labelSmall?.copyWith(
                                              color: pair.foreground,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            _statusLabel(booking.status),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                textTheme.labelSmall?.copyWith(
                                              fontSize: 10,
                                              color: pair.foreground,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Text(
                                          '+ Đặt quầy',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: t.textSecondary,
                                          ),
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
      ),
    );
  }
}

/// Kich ban ket qua quet ma QR tren O-13
enum QrCheckInResultType {
  validSuccess,
  wrongVenue,
  expiredOrWrongTime,
  alreadyUsed,
}

/// FE-44: Man hinh O-13 Quet QR Check-in danh cho CourtOwner:
/// - Khung camera quet QR + nhap ma ve thu cong
/// - Rung phan hoi (HapticFeedback) + hien thi ket qua Xanh / Do kem ly do cu the:
///   + Hop le (Xanh)
///   + Sai co so san (Do)
///   + Het han / Chua toi gio (Do)
///   + Da su dung check-in truoc do (Do)
class OwnerQrCheckInScreen extends StatefulWidget {
  const OwnerQrCheckInScreen({super.key});

  @override
  State<OwnerQrCheckInScreen> createState() => _OwnerQrCheckInScreenState();
}

class _OwnerQrCheckInScreenState extends State<OwnerQrCheckInScreen> {
  final TextEditingController _codeCtrl =
      TextEditingController(text: 'BM-2026-0891');
  QrCheckInResultType? _resultType;
  String _resultTitle = '';
  String _resultMessage = '';
  OwnerCourtBookingItem? _scannedBooking;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _triggerScanSimulation(QrCheckInResultType scenario) {
    HapticFeedback.mediumImpact();
    final store = FakeOwnerOperationsStore.instance;

    setState(() {
      _resultType = scenario;
      switch (scenario) {
        case QrCheckInResultType.validSuccess:
          final booking = store.findByCode(_codeCtrl.text) ?? store.bookings.first;
          store.markCheckedIn(booking.id);
          _scannedBooking = booking;
          _resultTitle = 'CHECK-IN HỢP LỆ (XÁC NHẬN VÀO SÂN)';
          _resultMessage =
              'Khách hàng: ${booking.customerName} (${booking.customerPhone})\n'
              'Vị trí: ${booking.courtName} | Giờ chơi: ${booking.timeRangeLabel}\n'
              'Thanh toán: ${booking.paymentMethodLabel}';
          break;

        case QrCheckInResultType.wrongVenue:
          _scannedBooking = null;
          _resultTitle = 'TỪ CHỐI: SAI CƠ SỞ SÂN';
          _resultMessage =
              'Mã QR này thuộc "Nhà Thi Đấu Rạch Miễu", không thuộc "Sân Cầu Lông Hỏa Châu". Vui lòng kiểm tra lại địa điểm đặt sân của khách.';
          break;

        case QrCheckInResultType.expiredOrWrongTime:
          _scannedBooking = null;
          _resultTitle = 'TỪ CHỐI: VÉ ĐÃ HẾT HẠN';
          _resultMessage =
              'Mã QR BM-2026-0710 có khung giờ thi đấu ngày 23/10/2026 (đã qua 4 ngày). Vé không còn hiệu lực sử dụng.';
          break;

        case QrCheckInResultType.alreadyUsed:
          _scannedBooking = null;
          _resultTitle = 'TỪ CHỐI: MÃ QR ĐÃ ĐƯỢC SỬ DỤNG';
          _resultMessage =
              'Lượt đặt này đã được quét check-in trước đó lúc 06:55 hôm nay. Không thể check-in trùng lặp.';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final isSuccess = _resultType == QrCheckInResultType.validSuccess;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('O-13 Quét mã QR Check-in'),
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          // 1. Khung ngam Camera Quet QR
          Container(
            height: 240,
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(
                color: _resultType == null
                    ? t.actionPrimary
                    : (isSuccess
                        ? t.statusActive.border
                        : t.statusCancelled.border),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white70,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(t.radiusControl),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: t.space3),
                Text(
                  'Đưa mã QR trên màn hình C-10 của khách vào khung ngắm',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 2. Nhap ma thu cong
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
                  'Hoặc nhập mã đặt sân thủ công:',
                  style: textTheme.titleSmall,
                ),
                SizedBox(height: t.space2),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _codeCtrl,
                        label: 'Mã đặt sân',
                        hintText: 'VD: BM-2026-0891',
                      ),
                    ),
                    SizedBox(width: t.space2),
                    AppButton(
                      label: 'Kiểm tra mã',
                      leadingIcon: Icons.verified_outlined,
                      variant: AppButtonVariant.primary,
                      onPressed: () => _triggerScanSimulation(
                        QrCheckInResultType.validSuccess,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 3. Bo mo phong 4 ket qua quet QR theo dac ta FE-44
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
                  'Mô phỏng kết quả quét Camera (Test 4 kịch bản O-13):',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.space3),
                Wrap(
                  spacing: t.space2,
                  runSpacing: t.space2,
                  children: [
                    AppButton(
                      label: '1. Vé hợp lệ (Xanh)',
                      leadingIcon: Icons.check_circle_outline_rounded,
                      variant: AppButtonVariant.primary,
                      onPressed: () => _triggerScanSimulation(
                        QrCheckInResultType.validSuccess,
                      ),
                    ),
                    AppButton(
                      label: '2. Sai cơ sở sân (Đỏ)',
                      leadingIcon: Icons.location_off_outlined,
                      variant: AppButtonVariant.danger,
                      onPressed: () => _triggerScanSimulation(
                        QrCheckInResultType.wrongVenue,
                      ),
                    ),
                    AppButton(
                      label: '3. Vé hết hạn (Đỏ)',
                      leadingIcon: Icons.history_toggle_off_rounded,
                      variant: AppButtonVariant.danger,
                      onPressed: () => _triggerScanSimulation(
                        QrCheckInResultType.expiredOrWrongTime,
                      ),
                    ),
                    AppButton(
                      label: '4. Mã đã dùng (Đỏ)',
                      leadingIcon: Icons.block_rounded,
                      variant: AppButtonVariant.danger,
                      onPressed: () => _triggerScanSimulation(
                        QrCheckInResultType.alreadyUsed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 4. Hien thi The Ket qua Xanh / Do
          if (_resultType != null)
            Container(
              padding: EdgeInsets.all(t.space4),
              decoration: BoxDecoration(
                color: isSuccess
                    ? t.statusActive.background
                    : t.statusCancelled.background,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(
                  color: isSuccess
                      ? t.statusActive.border
                      : t.statusCancelled.border,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSuccess
                            ? Icons.verified_rounded
                            : Icons.error_outline_rounded,
                        size: 28,
                        color: isSuccess
                            ? t.statusActive.foreground
                            : t.statusCancelled.foreground,
                      ),
                      SizedBox(width: t.space3),
                      Expanded(
                        child: Text(
                          _resultTitle,
                          style: textTheme.titleMedium?.copyWith(
                            color: isSuccess
                                ? t.statusActive.foreground
                                : t.statusCancelled.foreground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.space2),
                  Text(
                    _resultMessage,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isSuccess
                          ? t.statusActive.foreground
                          : t.statusCancelled.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isSuccess && _scannedBooking != null) ...[
                    SizedBox(height: t.space3),
                    const StatusChip(
                      status: CourtBookingStatus.completedOrCheckedIn,
                      customLabel: 'Trạng thái mới: CHECKED_IN',
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
