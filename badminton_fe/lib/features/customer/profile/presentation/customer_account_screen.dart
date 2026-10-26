import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../notifications/presentation/notification_screens.dart';

/// FE-33: Man hinh C-14 Tai khoan Customer:
/// - Avatar, ten, email, so dien thoai, badge hoi vien
/// - Menu danh sach chuc nang:
///   + C-15 Sua ho so
///   + S-07 Doi mat khau
///   + S-09 Cai dat thong bao & nhac lich
///   + C-16 Hoan tien & khieu nai
///   + Lich su giao dich & hoa don
///   + Tro giup & Trung tam ho tro
///   + Dang xuat (kem ConfirmDialog)
class CustomerAccountScreen extends StatelessWidget {
  final VoidCallback? onLogout;
  final ValueChanged<UserRole>? onSwitchRole;

  const CustomerAccountScreen({
    super.key,
    this.onLogout,
    this.onSwitchRole,
  });

  void _showFeaturePreview(BuildContext context, String title, String description) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusCard),
        ),
        title: Text(title, style: textTheme.titleMedium),
        content: Text(description, style: textTheme.bodyMedium),
        actions: [
          AppButton(
            label: 'Đóng',
            variant: AppButtonVariant.primary,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Đăng xuất tài khoản',
        message: 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng Badminton Court không?',
        confirmLabel: 'Đăng xuất',
        cancelLabel: 'Ở lại',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(ctx).pop();
          if (onLogout != null) {
            onLogout!();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã đăng xuất tài khoản thành công.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: t.surfaceMuted,
      appBar: AppBar(
        title: const Text('C-14 Tài khoản Customer'),
      ),
      body: ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          // 1. Profile Hero Card
          Container(
            padding: EdgeInsets.all(t.space4),
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: t.actionPrimary,
                  child: Text(
                    'NV',
                    style: textTheme.titleLarge?.copyWith(
                      color: t.onActionPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: t.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Nguyễn Văn A',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: t.space2),
                          const StatusChip(
                            status: CourtBookingStatus.activeConfirmed,
                            customLabel: 'Hội viên Bạc',
                          ),
                        ],
                      ),
                      SizedBox(height: t.space1),
                      Text(
                        'nguyenvana@gmail.com',
                        style: textTheme.bodySmall,
                      ),
                      SizedBox(height: t.space1),
                      Text(
                        'SĐT: 090 123 4567',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 2. Menu Chuc nang
          Container(
            decoration: BoxDecoration(
              color: t.surfaceCard,
              borderRadius: BorderRadius.circular(t.radiusCard),
              border: Border.all(color: t.borderSubtle),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: 'Chỉnh sửa hồ sơ cá nhân (C-15)',
                  subtitle: 'Cập nhật họ tên, ảnh đại diện, số điện thoại',
                  onTap: () => _showFeaturePreview(
                    context,
                    'C-15 Chỉnh sửa hồ sơ',
                    'Cho phép cập nhật ảnh đại diện dưới 5 MB, họ tên và số điện thoại. Email chỉ xem để bảo mật.',
                  ),
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: 'Đổi mật khẩu (S-07)',
                  subtitle: 'Cập nhật mật khẩu định kỳ để bảo vệ tài khoản',
                  onTap: () => _showFeaturePreview(
                    context,
                    'S-07 Đổi mật khẩu',
                    'Nhập mật khẩu hiện tại và thiết lập mật khẩu mới đạt chuẩn tối thiểu 8 ký tự kèm chữ hoa, số và ký tự đặc biệt.',
                  ),
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Cài đặt thông báo & Nhắc lịch (S-09)',
                  subtitle: 'Nhắc lịch trước 2 giờ, thông báo khuyến mãi',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.currency_exchange_rounded,
                  title: 'Hoàn tiền & Khiếu nại (C-16)',
                  subtitle: 'Theo dõi yêu cầu hoàn tiền và khiếu nại lên Admin',
                  onTap: () => _showFeaturePreview(
                    context,
                    'C-16 Hoàn tiền & Khiếu nại',
                    'Xem danh sách các yêu cầu hoàn cọc từ việc hủy sân hợp lệ và gửi yêu cầu khiếu nại nếu chủ sân không mở cửa.',
                  ),
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Lịch sử giao dịch & Hóa đơn',
                  subtitle: 'Xem toàn bộ giao dịch PayOS và biên nhận điện tử',
                  onTap: () => _showFeaturePreview(
                    context,
                    'Lịch sử giao dịch',
                    'Tra cứu lịch sử thanh toán PayOS VietQR, tải hóa đơn VAT điện tử hợp lệ.',
                  ),
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.headset_mic_outlined,
                  title: 'Hỗ trợ khách hàng: Hotline 1900 6868',
                  subtitle: 'Hỗ trợ kỹ thuật và giải quyết tranh chấp 24/7',
                  onTap: () => _showFeaturePreview(
                    context,
                    'Trung tâm trợ giúp',
                    'Liên hệ đường dây nóng 1900 6868 hoặc gửi email hỗ trợ đến support@badmintonhub.vn.',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: t.space4),

          // 3. Che do dev chuyen doi vai tro nhanh
          if (onSwitchRole != null) ...[
            Container(
              padding: EdgeInsets.all(t.space3),
              decoration: BoxDecoration(
                color: t.surfaceCard,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(color: t.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chuyển đổi vai trò (Môi trường phát triển)', style: textTheme.labelMedium),
                  SizedBox(height: t.space2),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Chủ sân (Owner)',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => onSwitchRole!(UserRole.owner),
                        ),
                      ),
                      SizedBox(width: t.space2),
                      Expanded(
                        child: AppButton(
                          label: 'Quản trị (Admin)',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => onSwitchRole!(UserRole.admin),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: t.space4),
          ],

          // 4. Dang xuat
          AppButton(
            label: 'Đăng xuất tài khoản',
            leadingIcon: Icons.logout_rounded,
            variant: AppButtonVariant.danger,
            onPressed: () => _confirmLogout(context),
          ),
          SizedBox(height: t.space6),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: t.actionPrimary),
      title: Text(title, style: textTheme.titleSmall),
      subtitle: Text(subtitle, style: textTheme.bodySmall),
      trailing: Icon(Icons.chevron_right_rounded, color: t.textSecondary),
      onTap: onTap,
    );
  }
}
