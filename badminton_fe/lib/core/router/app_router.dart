import 'package:flutter/material.dart';

import '../../features/customer/venue/data/fake_venue_repository.dart';
import '../l10n/app_strings.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/async_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/otp_input.dart';
import '../widgets/price_text.dart';
import '../widgets/slot_grid.dart';
import '../widgets/status_chip.dart';
import '../widgets/venue_card.dart';

/// 3 vai tro tach biet theo 01-kien-truc.md: CUSTOMER / OWNER / ADMIN.
enum UserRole {
  customer('/customer', AppStrings.roleCustomer),
  owner('/owner', AppStrings.roleOwner),
  admin('/admin', AppStrings.roleAdmin);

  final String basePath;
  final String label;
  const UserRole(this.basePath, this.label);
}

/// Bo chan duong dan theo role (redirect guard trong 01-kien-truc.md muc 3):
/// Customer go duong dan /owner/... hoac /admin/... se bi dua ve /customer.
class AppRouteGuard {
  AppRouteGuard._();

  static String resolveAllowedPath({
    required UserRole currentRole,
    required String requestedPath,
  }) {
    if (requestedPath.startsWith('/owner') && currentRole != UserRole.owner) {
      return currentRole.basePath;
    }
    if (requestedPath.startsWith('/admin') && currentRole != UserRole.admin) {
      return currentRole.basePath;
    }
    if (requestedPath.startsWith('/customer') &&
        currentRole != UserRole.customer) {
      return currentRole.basePath;
    }
    return requestedPath;
  }
}

/// Khung dieu huong 3 Shell giao dien theo 01-kien-truc.md:
/// - CUSTOMER: CustomerShell (Kham pha, Lich dat, Chat AI, Thong bao, Tai khoan)
/// - OWNER: OwnerShell (Hom nay, Co so san, Doanh thu, Thong bao, Tai khoan)
/// - ADMIN: AdminShell (Tong quan, Duyet, Tai khoan, Giao dich, Cau hinh)
/// - Cham 5 lan vao bieu tuong san o AppBar de mo khoa nhanh che do Admin.
class AppRoleShellHost extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const AppRoleShellHost({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<AppRoleShellHost> createState() => _AppRoleShellHostState();
}

class _AppRoleShellHostState extends State<AppRoleShellHost> {
  UserRole _currentRole = UserRole.customer;
  int _tabIndex = 0;
  int _logoTapCount = 0;
  bool _adminUnlocked = false;

  void _switchRole(UserRole role) {
    setState(() {
      _currentRole = role;
      _tabIndex = 0;
    });
  }

  void _onLogoTap() {
    _logoTapCount += 1;
    if (_logoTapCount >= 5 && !_adminUnlocked) {
      setState(() {
        _adminUnlocked = true;
        _currentRole = UserRole.admin;
        _tabIndex = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã mở khóa chế độ Quản trị (Admin Shell).'),
        ),
      );
    }
  }

  List<NavigationDestination> _destinationsForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: AppStrings.navExplore,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: AppStrings.navMyBookings,
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: AppStrings.navAiChat,
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: AppStrings.navNotifications,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: AppStrings.navAccount,
          ),
        ];
      case UserRole.owner:
        return const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: AppStrings.navToday,
          ),
          NavigationDestination(
            icon: Icon(Icons.stadium_outlined),
            selectedIcon: Icon(Icons.stadium_rounded),
            label: AppStrings.navVenues,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: AppStrings.navRevenue,
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: AppStrings.navNotifications,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: AppStrings.navAccount,
          ),
        ];
      case UserRole.admin:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: AppStrings.navOverview,
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: AppStrings.navApprovals,
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts_rounded),
            label: AppStrings.navUsers,
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: AppStrings.navTransactions,
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: AppStrings.navSettings,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleRoles = _adminUnlocked
        ? UserRole.values
        : [UserRole.customer, UserRole.owner, UserRole.admin];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: t.space4,
        title: GestureDetector(
          onTap: _onLogoTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.actionPrimary,
                  borderRadius: BorderRadius.circular(t.radiusControl),
                ),
                child: Icon(
                  Icons.sports_tennis_rounded,
                  size: 20,
                  color: t.onActionPrimary,
                ),
              ),
              SizedBox(width: t.space2),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Badminton Court',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Shell: ${_currentRole.label} (${_currentRole.basePath})',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Chuyển sang giao diện Sáng' : 'Chuyển sang giao diện Tối',
            constraints: BoxConstraints(
              minWidth: t.minTapTarget,
              minHeight: t.minTapTarget,
            ),
            onPressed: widget.onToggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          SizedBox(width: t.space2),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: t.space4,
              vertical: t.space2,
            ),
            decoration: BoxDecoration(
              color: t.surfaceMuted,
              border: Border(top: BorderSide(color: t.borderSubtle, width: 1)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'Vai trò demo:',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  SizedBox(width: t.space2),
                  ...visibleRoles.map((role) {
                    final selected = _currentRole == role;
                    return Padding(
                      padding: EdgeInsets.only(right: t.space2),
                      child: ChoiceChip(
                        label: Text(role.label),
                        selected: selected,
                        onSelected: (_) => _switchRole(role),
                        selectedColor: t.statusActive.background,
                        backgroundColor: t.surfaceCard,
                        labelStyle:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: selected
                                      ? t.statusActive.foreground
                                      : t.textPrimary,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                        side: BorderSide(
                          color: selected
                              ? t.statusActive.border
                              : t.borderSubtle,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildShellBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (idx) => setState(() => _tabIndex = idx),
        destinations: _destinationsForRole(_currentRole),
      ),
    );
  }

  Widget _buildShellBody() {
    switch (_currentRole) {
      case UserRole.customer:
        return CustomerShellView(tabIndex: _tabIndex);
      case UserRole.owner:
        return OwnerShellView(tabIndex: _tabIndex);
      case UserRole.admin:
        return AdminShellView(tabIndex: _tabIndex);
    }
  }
}

/// Shell giao dien cua CUSTOMER (C-01, C-05, Design System Harness).
class CustomerShellView extends StatefulWidget {
  final int tabIndex;
  const CustomerShellView({super.key, required this.tabIndex});

  @override
  State<CustomerShellView> createState() => _CustomerShellViewState();
}

class _CustomerShellViewState extends State<CustomerShellView> {
  final FakeVenueRepository _repo = const FakeVenueRepository();
  late final Map<String, CourtSlotCell> _slots;
  final Set<String> _selectedSlotKeys = {'C1_19', 'C2_18'};
  AsyncStatus _demoAsyncStatus = AsyncStatus.data;
  bool _showEmptyDemo = false;

  @override
  void initState() {
    super.initState();
    _slots = _repo.getSampleSlotMatrix();
  }

  int get _selectedTotalVnd {
    int sum = 0;
    for (final key in _selectedSlotKeys) {
      final cell = _slots[key];
      if (cell != null) sum += cell.priceVnd;
    }
    return sum;
  }

  void _toggleSlot(CourtSlotCell cell) {
    setState(() {
      if (_selectedSlotKeys.contains(cell.key)) {
        _selectedSlotKeys.remove(cell.key);
      } else {
        _selectedSlotKeys.add(cell.key);
      }
    });
  }

  AsyncState<List<VenueSummaryItem>> _buildCurrentAsyncState() {
    switch (_demoAsyncStatus) {
      case AsyncStatus.loading:
        return const AsyncState.loading();
      case AsyncStatus.error:
        return const AsyncState.error(AppStrings.errSlotTaken);
      case AsyncStatus.data:
        return AsyncState.data(
          _showEmptyDemo ? const [] : _repo.getSampleVenues(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    if (widget.tabIndex == 1) {
      return _buildSlotBookingTab(context);
    }
    if (widget.tabIndex == 4) {
      return _buildComponentShowcaseTab(context);
    }

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        // Hero Focal Point: Tieu de lon >= 2.5x body + Tong tien tam tinh
        Container(
          padding: EdgeInsets.all(t.space6),
          decoration: BoxDecoration(
            color: t.surfaceCard,
            borderRadius: BorderRadius.circular(t.radiusCard),
            border: Border.all(color: t.borderSubtle, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusChip(
                status: CourtBookingStatus.activeConfirmed,
                customLabel: 'C-01 Khám phá sân gần bạn',
              ),
              SizedBox(height: t.space3),
              Text(
                'Đặt sân cầu lông trong 30 giây',
                style: textTheme.displaySmall,
              ),
              SizedBox(height: t.space2),
              Text(
                'Chọn cơ sở sân đạt chuẩn thảm PVC, xem giờ trống theo thời gian thực và nhận mã QR check-in ngay.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: t.space4),
              // Bo chuyen thu 4 trang thai AsyncView (Data / Loading / Empty / Error)
              Wrap(
                spacing: t.space2,
                runSpacing: t.space2,
                children: [
                  _StateFilterButton(
                    label: 'Có dữ liệu (Data)',
                    active: _demoAsyncStatus == AsyncStatus.data &&
                        !_showEmptyDemo,
                    onTap: () => setState(() {
                      _demoAsyncStatus = AsyncStatus.data;
                      _showEmptyDemo = false;
                    }),
                  ),
                  _StateFilterButton(
                    label: 'Đang tải (Loading)',
                    active: _demoAsyncStatus == AsyncStatus.loading,
                    onTap: () => setState(() {
                      _demoAsyncStatus = AsyncStatus.loading;
                    }),
                  ),
                  _StateFilterButton(
                    label: 'Trống (Empty)',
                    active: _demoAsyncStatus == AsyncStatus.data &&
                        _showEmptyDemo,
                    onTap: () => setState(() {
                      _demoAsyncStatus = AsyncStatus.data;
                      _showEmptyDemo = true;
                    }),
                  ),
                  _StateFilterButton(
                    label: 'Lỗi 409 (Error)',
                    active: _demoAsyncStatus == AsyncStatus.error,
                    onTap: () => setState(() {
                      _demoAsyncStatus = AsyncStatus.error;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: t.space6),
        AsyncView<List<VenueSummaryItem>>(
          state: _buildCurrentAsyncState(),
          isEmpty: (list) => list.isEmpty,
          emptyTitle: 'Không tìm thấy sân phù hợp',
          emptyDescription:
              'Bạn hãy mở rộng bán kính tìm kiếm hoặc chọn khung giờ khác.',
          onRetry: () => setState(() {
            _demoAsyncStatus = AsyncStatus.data;
            _showEmptyDemo = false;
          }),
          builder: (ctx, venues) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sân đề xuất quanh vị trí của bạn (${venues.length})',
                style: textTheme.titleLarge,
              ),
              SizedBox(height: t.space3),
              ...venues.map(
                (v) => Padding(
                  padding: EdgeInsets.only(bottom: t.space4),
                  child: VenueCard(
                    venue: v,
                    onTap: () {},
                    onBookQuick: v.availableCourtCount > 0 ? () {} : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlotBookingTab(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        Text(
          'C-05 Chọn khung giờ (SlotGrid)',
          style: textTheme.headlineSmall,
        ),
        SizedBox(height: t.space1),
        Text(
          'Chạm vào các ô màu xanh (Còn trống) để chọn hoặc bỏ chọn khung giờ đặt sân.',
          style: textTheme.bodyMedium,
        ),
        SizedBox(height: t.space4),
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
            cells: _slots,
            selectedKeys: _selectedSlotKeys,
            onToggleSlot: _toggleSlot,
          ),
        ),
        SizedBox(height: t.space6),
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
                  Text(
                    'Đã chọn ${_selectedSlotKeys.length} khung giờ',
                    style: textTheme.bodyMedium,
                  ),
                  PriceText(
                    amountVnd: _selectedTotalVnd,
                    isHero: true,
                  ),
                ],
              ),
              AppButton(
                label: AppStrings.actionConfirmPayment,
                onPressed: _selectedSlotKeys.isEmpty ? null : () {},
                variant: AppButtonVariant.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComponentShowcaseTab(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        Text(
          'Sprint 0 Component Kit (FE-03 & FE-04)',
          style: textTheme.headlineSmall,
        ),
        SizedBox(height: t.space4),
        const AppTextField(
          label: 'Số điện thoại hoặc Email',
          hintText: 'Nhập email đăng ký tài khoản',
          prefixIcon: Icons.mail_outline_rounded,
        ),
        SizedBox(height: t.space3),
        const AppTextField(
          label: 'Mật khẩu',
          hintText: 'Nhập tối thiểu 8 ký tự',
          isPassword: true,
          prefixIcon: Icons.lock_outline_rounded,
        ),
        SizedBox(height: t.space6),
        Text('Mã xác thực OTP 6 số (S-04)', style: textTheme.titleMedium),
        SizedBox(height: t.space2),
        OtpInput(
          onCompleted: (_) {},
          onResend: () {},
        ),
        SizedBox(height: t.space6),
        Text(
          'Các biến thể AppButton & Token-by-Intent',
          style: textTheme.titleMedium,
        ),
        SizedBox(height: t.space3),
        Wrap(
          spacing: t.space2,
          runSpacing: t.space2,
          children: [
            AppButton(
              label: AppStrings.actionBookNow,
              onPressed: () {},
              variant: AppButtonVariant.primary,
            ),
            AppButton(
              label: 'Đang giữ chỗ...',
              onPressed: () {},
              loading: true,
              variant: AppButtonVariant.primary,
            ),
            AppButton(
              label: AppStrings.actionFilter,
              onPressed: () {},
              variant: AppButtonVariant.secondary,
            ),
            AppButton(
              label: AppStrings.actionCancelBooking,
              leadingIcon: Icons.delete_outline_rounded,
              variant: AppButtonVariant.danger,
              onPressed: () {
                ConfirmDialog.show(
                  context,
                  title: 'Xác nhận hủy lượt đặt sân?',
                  message:
                      'Thao tác này không thể hoàn tác. Tiền hoàn sẽ được tính theo chính sách hủy của sân.',
                  confirmLabel: AppStrings.actionCancelBooking,
                  isDestructive: true,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Shell giao dien cua COURT OWNER (O-03 Hom nay, O-10 Timeline, Doanh thu).
class OwnerShellView extends StatelessWidget {
  final int tabIndex;
  const OwnerShellView({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final repo = const FakeVenueRepository();

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        Container(
          padding: EdgeInsets.all(t.space6),
          decoration: BoxDecoration(
            color: t.surfaceCard,
            borderRadius: BorderRadius.circular(t.radiusCard),
            border: Border.all(color: t.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusChip(
                status: CourtBookingStatus.completedOrCheckedIn,
                customLabel: 'O-03 Vận hành hôm nay',
              ),
              SizedBox(height: t.space3),
              Text('Doanh thu tạm tính hôm nay', style: textTheme.bodyMedium),
              SizedBox(height: t.space1),
              const PriceText(amountVnd: 6850000, isHero: true),
              SizedBox(height: t.space4),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Quét QR Check-in (O-13)',
                      leadingIcon: Icons.qr_code_scanner_rounded,
                      onPressed: () {},
                      variant: AppButtonVariant.primary,
                    ),
                  ),
                  SizedBox(width: t.space2),
                  Expanded(
                    child: AppButton(
                      label: 'Đặt thủ công (O-12)',
                      leadingIcon: Icons.add_circle_outline_rounded,
                      onPressed: () {},
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: t.space6),
        Text(
          'O-10 Lưới lịch sân theo thời gian thực',
          style: textTheme.titleLarge,
        ),
        SizedBox(height: t.space3),
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
            cells: repo.getSampleSlotMatrix(),
            selectedKeys: const {},
            onToggleSlot: (_) {},
          ),
        ),
      ],
    );
  }
}

/// Shell giao dien cua ADMIN (A-01 Tong quan, A-02/A-03 Duyet ho so & co so san).
class AdminShellView extends StatelessWidget {
  final int tabIndex;
  const AdminShellView({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        Container(
          padding: EdgeInsets.all(t.space6),
          decoration: BoxDecoration(
            color: t.surfaceCard,
            borderRadius: BorderRadius.circular(t.radiusCard),
            border: Border.all(color: t.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusChip(
                status: CourtBookingStatus.pending,
                customLabel: 'A-01 & A-03 Cần duyệt: 3 hồ sơ mới',
              ),
              SizedBox(height: t.space3),
              Text('Tổng giá trị giao dịch toàn sàn', style: textTheme.bodyMedium),
              SizedBox(height: t.space1),
              const PriceText(amountVnd: 148500000, isHero: true),
            ],
          ),
        ),
        SizedBox(height: t.space6),
        Text('Danh sách cơ sở sân chờ duyệt (A-03)', style: textTheme.titleLarge),
        SizedBox(height: t.space3),
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
                      'Cơ sở Cầu Lông Bình Thạnh Sport',
                      style: textTheme.titleMedium,
                    ),
                  ),
                  const StatusChip(
                    status: CourtBookingStatus.pending,
                    customLabel: 'Chờ duyệt',
                  ),
                ],
              ),
              SizedBox(height: t.space2),
              Text(
                'Chủ sân: Nguyễn Văn Minh · 6 sân thảm tiêu chuẩn · Đã ghim tọa độ GPS',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: t.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Yêu cầu chỉnh sửa',
                    variant: AppButtonVariant.danger,
                    onPressed: () {
                      ConfirmDialog.show(
                        context,
                        title: 'Từ chối hồ sơ cơ sở sân?',
                        message:
                            'Chủ sân sẽ nhận được thông báo đẩy kèm lý do cần bổ sung giấy phép hoặc ảnh thực tế.',
                        confirmLabel: 'Từ chối duyệt',
                        isDestructive: true,
                      );
                    },
                  ),
                  SizedBox(width: t.space2),
                  AppButton(
                    label: 'Phê duyệt lên bản đồ',
                    variant: AppButtonVariant.primary,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StateFilterButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _StateFilterButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      borderRadius: BorderRadius.circular(t.radiusControl),
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: t.minTapTarget),
        padding: EdgeInsets.symmetric(
          horizontal: t.space3,
          vertical: t.space2,
        ),
        decoration: BoxDecoration(
          color: active ? t.statusActive.background : t.surfaceMuted,
          borderRadius: BorderRadius.circular(t.radiusControl),
          border: Border.all(
            color: active ? t.actionPrimary : t.borderSubtle,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: active ? t.statusActive.foreground : t.textSecondary,
            ),
            SizedBox(width: t.space1),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: active ? t.statusActive.foreground : t.textPrimary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
