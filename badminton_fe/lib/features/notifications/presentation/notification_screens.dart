import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../customer/booking/data/customer_booking_models.dart';
import '../../customer/booking/presentation/booking_detail_screen.dart';
import '../../owner/onboarding/presentation/owner_onboarding_screens.dart';
import '../../owner/venue_manage/presentation/owner_venue_screens.dart';

/// Phan loai data.type cua thong bao FCM theo docs/04-luong-dieu-huong.md (muc 6).
enum NotificationDataType {
  booking('BOOKING', 'Lịch đặt sân', Icons.calendar_today_rounded),
  refund('REFUND', 'Hoàn tiền', Icons.currency_exchange_rounded),
  ownerApplication('OWNER_APPLICATION', 'Hồ sơ chủ sân', Icons.verified_user_outlined),
  venueReview('VENUE_REVIEW', 'Duyệt cơ sở sân', Icons.stadium_outlined),
  announcement('ANNOUNCEMENT', 'Thông báo hệ thống', Icons.campaign_outlined);

  final String rawType;
  final String label;
  final IconData icon;
  const NotificationDataType(this.rawType, this.label, this.icon);
}

/// Model mot ban ghi thong bao tren S-08.
class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final NotificationDataType type;
  final String? targetId;
  final bool isRead;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.type,
    this.targetId,
    this.isRead = false,
  });

  AppNotificationItem copyWith({bool? isRead}) {
    return AppNotificationItem(
      id: id,
      title: title,
      body: body,
      timeAgo: timeAgo,
      type: type,
      targetId: targetId,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Store quan ly FCM Token, danh sach thong bao (S-08) va cai dat nhac lich (S-09).
class FakeNotificationStore extends ChangeNotifier {
  static final FakeNotificationStore instance = FakeNotificationStore._internal();

  FakeNotificationStore._internal();

  String fcmDeviceToken = 'fcm_andro_2026_badminton_99812a7c4e';
  bool isFcmSyncedWithBackend = true;

  // Cai dat nhac lich S-09
  bool enablePlayReminder = true;
  int reminderMinutesBefore = 120; // Mac dinh nhac truoc 120 phut (2 gio)
  bool enableBookingStatusPush = true;
  bool enablePromoPush = false;

  final List<AppNotificationItem> _items = [
    const AppNotificationItem(
      id: 'NOTI-01',
      title: 'Đặt sân thành công (BM-2026-0891)',
      body:
          'Thanh toán PayOS VietQR đã được xác nhận. Sân Cầu Lông Hỏa Châu - Sân 1 (18:00 - 20:00). Chạm để mở mã QR check-in.',
      timeAgo: '5 phút trước',
      type: NotificationDataType.booking,
      targetId: 'BK-001',
      isRead: false,
    ),
    const AppNotificationItem(
      id: 'NOTI-02',
      title: 'Nhắc lịch thi đấu sắp diễn ra',
      body:
          'Còn 2 giờ nữa đến giờ chơi của bạn tại CLB Cầu Lông Đào Duy Anh (17:00 - 18:00). Đừng quên mang theo mã QR.',
      timeAgo: '1 giờ trước',
      type: NotificationDataType.booking,
      targetId: 'BK-002',
      isRead: false,
    ),
    const AppNotificationItem(
      id: 'NOTI-03',
      title: 'Đã hoàn tiền cọc 100% (75.000đ)',
      body:
          'Yêu cầu hủy lịch BM-2026-0520 tại Nhà Thi Đấu Rạch Miễu trước 24h đã được xử lý hoàn tiền về tài khoản ngân hàng.',
      timeAgo: '1 ngày trước',
      type: NotificationDataType.refund,
      targetId: 'BK-004',
      isRead: false,
    ),
    const AppNotificationItem(
      id: 'NOTI-04',
      title: 'Cơ sở sân đã được Admin phê duyệt',
      body:
          'Chúc mừng! Cơ sở sân của bạn đã được kiểm duyệt tọa độ GPS và hiển thị công khai trên bản đồ tìm kiếm C-01.',
      timeAgo: '2 ngày trước',
      type: NotificationDataType.venueReview,
      isRead: true,
    ),
    const AppNotificationItem(
      id: 'NOTI-05',
      title: 'Bảo trì nâng cấp cổng PayOS VietQR 24/7',
      body:
          'Hệ thống vừa nâng cấp đường truyền đối soát tự động PayOS giúp xác nhận vé đặt sân chỉ trong 1 - 3 giây sau khi chuyển khoản.',
      timeAgo: '3 ngày trước',
      type: NotificationDataType.announcement,
      isRead: true,
    ),
  ];

  List<AppNotificationItem> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((e) => !e.isRead).length;

  void markAsRead(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1 && !_items[idx].isRead) {
      _items[idx] = _items[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void simulateIncomingPush(NotificationDataType type) {
    final nowId = 'NOTI-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    AppNotificationItem newItem;
    switch (type) {
      case NotificationDataType.booking:
        newItem = AppNotificationItem(
          id: nowId,
          title: '[FCM Push] Lượt đặt mới được xác nhận',
          body: 'Đơn BM-2026-0891 tại Sân Cầu Lông Hỏa Châu đã sẵn sàng check-in.',
          timeAgo: 'Vừa xong',
          type: NotificationDataType.booking,
          targetId: 'BK-001',
          isRead: false,
        );
        break;
      case NotificationDataType.refund:
        newItem = AppNotificationItem(
          id: nowId,
          title: '[FCM Push] Cập nhật trạng thái hoàn tiền',
          body: 'Khoản hoàn cọc 75.000đ đã được chuyển về tài khoản MBBank của bạn.',
          timeAgo: 'Vừa xong',
          type: NotificationDataType.refund,
          targetId: 'BK-004',
          isRead: false,
        );
        break;
      case NotificationDataType.ownerApplication:
        newItem = AppNotificationItem(
          id: nowId,
          title: '[FCM Push] Hồ sơ đăng ký Chủ sân đã duyệt',
          body: 'Hồ sơ pháp lý của bạn đã được Admin phê duyệt. Chạm để xem trạng thái.',
          timeAgo: 'Vừa xong',
          type: NotificationDataType.ownerApplication,
          isRead: false,
        );
        break;
      case NotificationDataType.venueReview:
        newItem = AppNotificationItem(
          id: nowId,
          title: '[FCM Push] Kết quả duyệt cơ sở sân',
          body: 'Admin đã duyệt cơ sở sân của bạn lên bản đồ C-01.',
          timeAgo: 'Vừa xong',
          type: NotificationDataType.venueReview,
          isRead: false,
        );
        break;
      case NotificationDataType.announcement:
        newItem = AppNotificationItem(
          id: nowId,
          title: '[FCM Push] Ưu đãi đặt sân cầu lông cuối tuần',
          body: 'Nhập mã BADMINTON10 giảm ngay 10% cho mọi khung giờ sáng Thứ 7 và Chủ Nhật.',
          timeAgo: 'Vừa xong',
          type: NotificationDataType.announcement,
          isRead: false,
        );
        break;
    }
    _items.insert(0, newItem);
    notifyListeners();
  }
}

/// FE-40 & FE-41: Man hinh S-08 Trung tam thong bao:
/// - Hien thi badge so luong chua doc
/// - Bo loc theo phan loai (Tat ca / Chua doc / Lich dat / Hoan tien / He thong)
/// - Xu ly cham thong bao dieu huong theo data.type (04-luong-dieu-huong.md muc 6)
/// - Mo man hinh Cai dat nhac lich S-09 (FE-42)
class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  final FakeNotificationStore _store = FakeNotificationStore.instance;
  String _selectedFilter = 'ALL';
  String? _expandedAnnouncementId;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  List<AppNotificationItem> get _filteredItems {
    return _store.items.where((item) {
      if (_selectedFilter == 'UNREAD') return !item.isRead;
      if (_selectedFilter == 'BOOKING') {
        return item.type == NotificationDataType.booking;
      }
      if (_selectedFilter == 'REFUND') {
        return item.type == NotificationDataType.refund;
      }
      if (_selectedFilter == 'SYSTEM') {
        return item.type == NotificationDataType.announcement ||
            item.type == NotificationDataType.ownerApplication ||
            item.type == NotificationDataType.venueReview;
      }
      return true;
    }).toList();
  }

  /// FE-40: Dieu huong khi cham thong bao theo data.type (docs/04-luong-dieu-huong.md muc 6)
  void _handleNotificationTap(AppNotificationItem item) {
    _store.markAsRead(item.id);

    switch (item.type) {
      case NotificationDataType.booking:
        final bookingId =
            item.targetId ?? FakeCustomerBookingRepository.instance.getBookingsByTab(0).first.id;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingDetailScreen(bookingId: bookingId),
          ),
        );
        break;

      case NotificationDataType.refund:
        _showRefundDetailDialog(item);
        break;

      case NotificationDataType.ownerApplication:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (ctx) => OwnerApplicationStatusScreen(
              onEnterOwnerShell: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
        break;

      case NotificationDataType.venueReview:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('O-04 & O-05 Cơ sở sân của tôi')),
              body: const OwnerVenueListView(),
            ),
          ),
        );
        break;

      case NotificationDataType.announcement:
        setState(() {
          _expandedAnnouncementId =
              _expandedAnnouncementId == item.id ? null : item.id;
        });
        break;
    }
  }

  void _showRefundDetailDialog(AppNotificationItem item) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusCard),
        ),
        title: Text('C-16 Chi tiết hoàn tiền', style: textTheme.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusChip(
              status: CourtBookingStatus.completedOrCheckedIn,
              customLabel: 'Đã hoàn tiền thành công',
            ),
            SizedBox(height: t.space3),
            Text(item.title, style: textTheme.titleSmall),
            SizedBox(height: t.space2),
            Text(item.body, style: textTheme.bodyMedium),
            SizedBox(height: t.space3),
            Text(
              'Phương thức nhận: Chuyển khoản ngược qua PayOS VietQR',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Xem đơn đã hủy (C-10)',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              Navigator.of(ctx).pop();
              if (item.targetId != null) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BookingDetailScreen(bookingId: item.targetId!),
                  ),
                );
              }
            },
          ),
          AppButton(
            label: 'Đóng',
            variant: AppButtonVariant.primary,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _openReminderSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('S-08 Thông báo'),
            SizedBox(width: t.space2),
            if (_store.unreadCount > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: t.space2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: t.actionDanger,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${_store.unreadCount} mới',
                  style: textTheme.labelSmall?.copyWith(
                    color: t.onActionDanger,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đánh dấu đã đọc tất cả',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: _store.unreadCount > 0 ? _store.markAllAsRead : null,
          ),
          IconButton(
            tooltip: 'S-09 Cài đặt nhắc lịch',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openReminderSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh trang thai FCM Token & Mo phong Push (FE-40)
          Container(
            padding: EdgeInsets.all(t.space3),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              border: Border(bottom: BorderSide(color: t.borderSubtle)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'FCM Device Token: ${_store.fcmDeviceToken}',
                        style: textTheme.labelSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: t.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusChip(
                      status: CourtBookingStatus.activeConfirmed,
                      customLabel:
                          'Nhắc lịch: trước ${_store.reminderMinutesBefore}p',
                    ),
                  ],
                ),
                SizedBox(height: t.space2),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'Tất cả (${_store.items.length})'),
                      SizedBox(width: t.space2),
                      _buildFilterChip('UNREAD', 'Chưa đọc (${_store.unreadCount})'),
                      SizedBox(width: t.space2),
                      _buildFilterChip('BOOKING', 'Lịch đặt sân'),
                      SizedBox(width: t.space2),
                      _buildFilterChip('REFUND', 'Hoàn tiền'),
                      SizedBox(width: t.space2),
                      _buildFilterChip('SYSTEM', 'Hệ thống & Duyệt'),
                    ],
                  ),
                ),
                SizedBox(height: t.space2),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AppButton(
                        label: 'Test Push BOOKING -> C-10',
                        leadingIcon: Icons.notifications_active_outlined,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _store.simulateIncomingPush(
                          NotificationDataType.booking,
                        ),
                      ),
                      SizedBox(width: t.space2),
                      AppButton(
                        label: 'Test Push REFUND -> C-16',
                        leadingIcon: Icons.currency_exchange_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _store.simulateIncomingPush(
                          NotificationDataType.refund,
                        ),
                      ),
                      SizedBox(width: t.space2),
                      AppButton(
                        label: 'Cài đặt nhắc lịch (S-09)',
                        leadingIcon: Icons.alarm_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: _openReminderSettings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sach thong bao
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: 'Không có thông báo nào',
                    description:
                        'Bạn đã đọc hết tất cả thông báo trong danh mục này.',
                    actionLabel: 'Xem tất cả thông báo',
                    onAction: () => setState(() => _selectedFilter = 'ALL'),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(t.space4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => SizedBox(height: t.space3),
                    itemBuilder: (ctx, index) {
                      final item = filtered[index];
                      final isExpanded = _expandedAnnouncementId == item.id;

                      return InkWell(
                        onTap: () => _handleNotificationTap(item),
                        borderRadius: BorderRadius.circular(t.radiusCard),
                        child: Container(
                          padding: EdgeInsets.all(t.space4),
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? t.surfaceCard
                                : t.statusActive.background,
                            borderRadius: BorderRadius.circular(t.radiusCard),
                            border: Border.all(
                              color: item.isRead
                                  ? t.borderSubtle
                                  : t.statusActive.border,
                              width: item.isRead ? 1.0 : 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: item.isRead
                                          ? t.surfaceMuted
                                          : t.actionPrimary,
                                      borderRadius: BorderRadius.circular(
                                        t.radiusControl,
                                      ),
                                    ),
                                    child: Icon(
                                      item.type.icon,
                                      size: 18,
                                      color: item.isRead
                                          ? t.textSecondary
                                          : t.onActionPrimary,
                                    ),
                                  ),
                                  SizedBox(width: t.space3),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${item.type.label} (${item.type.rawType})',
                                              style:
                                                  textTheme.labelSmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: item.isRead
                                                    ? t.textSecondary
                                                    : t.statusActive.foreground,
                                              ),
                                            ),
                                            Text(
                                              item.timeAgo,
                                              style: textTheme.labelSmall,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          item.title,
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: item.isRead
                                                ? FontWeight.w600
                                                : FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!item.isRead) ...[
                                    SizedBox(width: t.space2),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: t.actionPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: t.space2),
                              Text(
                                item.body,
                                maxLines: isExpanded ? 10 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium,
                              ),
                              if (isExpanded &&
                                  item.type ==
                                      NotificationDataType.announcement) ...[
                                SizedBox(height: t.space3),
                                Container(
                                  padding: EdgeInsets.all(t.space3),
                                  decoration: BoxDecoration(
                                    color: t.surfaceMuted,
                                    borderRadius: BorderRadius.circular(
                                      t.radiusControl,
                                    ),
                                  ),
                                  child: Text(
                                    'Chi tiết thông báo hệ thống: Áp dụng trên toàn bộ cơ sở sân tại TP.HCM. Mọi thắc mắc vui lòng liên hệ Hotline 1900 6868.',
                                    style: textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final t = context.tokens;
    final selected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = key),
      selectedColor: t.statusActive.background,
      backgroundColor: t.surfaceMuted,
      labelStyle: TextStyle(
        color: selected ? t.statusActive.foreground : t.textPrimary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

/// FE-42: Man hinh S-09 Cai dat nhac lich & Thong bao
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final FakeNotificationStore _store = FakeNotificationStore.instance;

  static const List<Map<String, dynamic>> _reminderOptions = [
    {'minutes': 30, 'label': 'Trước 30 phút'},
    {'minutes': 60, 'label': 'Trước 1 giờ'},
    {'minutes': 120, 'label': 'Trước 2 giờ (Khuyến nghị)'},
    {'minutes': 1440, 'label': 'Trước 24 giờ (1 ngày)'},
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('S-09 Cài đặt nhắc lịch & Thông báo'),
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
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
                  'Nhắc lịch thi đấu tự động',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.space1),
                Text(
                  'Hệ thống sẽ gửi thông báo đẩy (FCM Push) trước giờ ra sân để bạn chuẩn bị vợt và di chuyển đúng giờ.',
                  style: textTheme.bodySmall,
                ),
                SizedBox(height: t.space3),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bật nhắc lịch trước giờ chơi'),
                  subtitle: const Text('Tự động nhắc cho mọi lượt đặt Đã xác nhận'),
                  value: _store.enablePlayReminder,
                  onChanged: (val) {
                    setState(() => _store.enablePlayReminder = val);
                  },
                ),
                if (_store.enablePlayReminder) ...[
                  const Divider(),
                  SizedBox(height: t.space2),
                  Text(
                    'Thời điểm gửi thông báo nhắc lịch:',
                    style: textTheme.titleSmall,
                  ),
                  SizedBox(height: t.space2),
                  ..._reminderOptions.map((opt) {
                    final mins = opt['minutes'] as int;
                    final label = opt['label'] as String;
                    final isSelected = _store.reminderMinutesBefore == mins;

                    return Padding(
                      padding: EdgeInsets.only(bottom: t.space2),
                      child: InkWell(
                        onTap: () {
                          setState(() => _store.reminderMinutesBefore = mins);
                        },
                        borderRadius: BorderRadius.circular(t.radiusControl),
                        child: Container(
                          padding: EdgeInsets.all(t.space3),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? t.statusActive.background
                                : t.surfaceMuted,
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
                                child: Text(
                                  label,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? t.statusActive.foreground
                                        : t.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Các loại thông báo khác',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Biến động đơn đặt sân & Thanh toán PayOS'),
                  subtitle: const Text(
                    'Xác nhận đặt cọc, hoàn tiền và thông báo thay đổi sân con',
                  ),
                  value: _store.enableBookingStatusPush,
                  onChanged: (val) {
                    setState(() => _store.enableBookingStatusPush = val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Khuyến mãi & Mã giảm giá mới'),
                  subtitle: const Text(
                    'Nhận mã ưu đãi giờ thấp điểm từ các sân gần vị trí của bạn',
                  ),
                  value: _store.enablePromoPush,
                  onChanged: (val) {
                    setState(() => _store.enablePromoPush = val);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: t.space6),
          AppButton(
            label: 'Lưu cài đặt nhắc lịch',
            leadingIcon: Icons.check_rounded,
            variant: AppButtonVariant.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã lưu cài đặt: Nhắc lịch trước ${_store.reminderMinutesBefore} phút.',
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
