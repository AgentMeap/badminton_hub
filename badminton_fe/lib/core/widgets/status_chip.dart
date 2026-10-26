import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Nhan trang thai dung chung theo 02-design-system.md:
/// - Nhan enum CourtBookingStatus, tu dong lay cap mau & icon tuong ung
/// - Khong bao gio dung mau lam tin hieu duy nhat: luon kem icon va chu ro rang
class StatusChip extends StatelessWidget {
  final CourtBookingStatus status;
  final String? customLabel;

  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  static String defaultLabelFor(CourtBookingStatus status) {
    switch (status) {
      case CourtBookingStatus.activeConfirmed:
        return 'Trống / Hoạt động';
      case CourtBookingStatus.pending:
        return 'Chờ xác nhận';
      case CourtBookingStatus.maintenanceOrOccupied:
        return 'Đã đặt / Bảo trì';
      case CourtBookingStatus.cancelledOrSuspended:
        return 'Đã hủy';
      case CourtBookingStatus.draftOrExpired:
        return 'Quá giờ / Nháp';
      case CourtBookingStatus.completedOrCheckedIn:
        return 'Đã check-in';
    }
  }

  static IconData iconFor(CourtBookingStatus status) {
    switch (status) {
      case CourtBookingStatus.activeConfirmed:
        return Icons.check_circle_outline;
      case CourtBookingStatus.pending:
        return Icons.schedule_outlined;
      case CourtBookingStatus.maintenanceOrOccupied:
        return Icons.lock_clock_outlined;
      case CourtBookingStatus.cancelledOrSuspended:
        return Icons.cancel_outlined;
      case CourtBookingStatus.draftOrExpired:
        return Icons.history_outlined;
      case CourtBookingStatus.completedOrCheckedIn:
        return Icons.verified_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pair = t.pairForStatus(status);
    final label = customLabel ?? defaultLabelFor(status);

    return Semantics(
      label: 'Trạng thái: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.space3,
          vertical: t.space1,
        ),
        decoration: BoxDecoration(
          color: pair.background,
          borderRadius: BorderRadius.circular(t.radiusControl),
          border: Border.all(color: pair.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconFor(status), size: 14, color: pair.foreground),
            SizedBox(width: t.space1),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: pair.foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
