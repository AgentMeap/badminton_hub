import 'package:flutter/material.dart';

import '../../features/admin/presentation/admin_approval_screens.dart';
import '../../features/auth/presentation/auth_flow_screens.dart';
import '../../features/customer/booking/presentation/my_bookings_screen.dart';
import '../../features/customer/chat_ai/presentation/customer_ai_chat_screen.dart';
import '../../features/customer/home_map/presentation/customer_explore_screen.dart';
import '../../features/customer/profile/presentation/customer_account_screen.dart';
import '../../features/notifications/presentation/notification_screens.dart';
import '../../features/owner/operations/presentation/owner_operations_screens.dart';
import '../../features/owner/venue_manage/presentation/owner_venue_screens.dart';
import '../l10n/app_strings.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/price_text.dart';
import '../widgets/status_chip.dart';

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

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(
          onLoginSuccess: (role) {
            Navigator.of(context).popUntil((r) => r.isFirst);
            _switchRole(role);
          },
          onOpenOwnerStatus: () {
            Navigator.of(context).popUntil((r) => r.isFirst);
            _switchRole(UserRole.owner);
          },
        ),
      ),
    );
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Shell: ${_currentRole.label} (${_currentRole.basePath})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Man hinh hep (dien thoai): chi hien icon de nhuong cho tieu de
          if (MediaQuery.sizeOf(context).width < 600)
            IconButton(
              tooltip: 'Đăng nhập (S-02)',
              constraints: BoxConstraints(
                minWidth: t.minTapTarget,
                minHeight: t.minTapTarget,
              ),
              onPressed: _openLogin,
              icon: const Icon(Icons.login_rounded),
            )
          else
            AppButton(
              label: 'Đăng nhập (S-02)',
              leadingIcon: Icons.login_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: _openLogin,
            ),
          SizedBox(width: t.space1),
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
        return CustomerShellView(
          tabIndex: _tabIndex,
          onSelectTab: (idx) => setState(() => _tabIndex = idx),
          onSwitchRole: _switchRole,
        );
      case UserRole.owner:
        return OwnerShellView(tabIndex: _tabIndex);
      case UserRole.admin:
        return AdminShellView(tabIndex: _tabIndex);
    }
  }
}

/// Shell giao dien cua CUSTOMER (C-01, C-09, C-13, S-08, C-14).
class CustomerShellView extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int>? onSelectTab;
  final ValueChanged<UserRole>? onSwitchRole;

  const CustomerShellView({
    super.key,
    required this.tabIndex,
    this.onSelectTab,
    this.onSwitchRole,
  });

  @override
  Widget build(BuildContext context) {
    switch (tabIndex) {
      case 0:
        return const CustomerExploreScreen();
      case 1:
        return MyBookingsScreen(
          onExploreTap: () => onSelectTab?.call(0),
        );
      case 2:
        return const CustomerAiChatScreen();
      case 3:
        return const NotificationsCenterScreen();
      case 4:
      default:
        return CustomerAccountScreen(
          onSwitchRole: onSwitchRole,
        );
    }
  }
}

/// Shell giao dien cua COURT OWNER (O-03 Hom nay, O-10 Timeline, O-04 Co so san, S-08 Thong bao).
class OwnerShellView extends StatelessWidget {
  final int tabIndex;
  const OwnerShellView({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 0) {
      return const OwnerOperationsTodayScreen();
    }
    if (tabIndex == 1) {
      return const OwnerVenueListView();
    }
    if (tabIndex == 3) {
      return const NotificationsCenterScreen();
    }
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
                status: CourtBookingStatus.completedOrCheckedIn,
                customLabel: 'O-14 Báo cáo doanh thu & Đối soát PayOS',
              ),
              SizedBox(height: t.space3),
              Text('Tổng doanh thu tháng 10/2026', style: textTheme.bodyMedium),
              SizedBox(height: t.space1),
              const PriceText(amountVnd: 42850000, isHero: true),
              SizedBox(height: t.space3),
              Text(
                'Phí nền tảng (5%): 2.142.500đ | Thực nhận về MBBank: 40.707.500đ',
                style: textTheme.bodySmall,
              ),
            ],
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
    if (tabIndex == 1) {
      return const AdminApprovalCenterView();
    }
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
              Wrap(
                alignment: WrapAlignment.end,
                spacing: t.space2,
                runSpacing: t.space2,
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
