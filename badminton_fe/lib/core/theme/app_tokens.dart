import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// 6 nhom trang thai thong nhat cho chip, o lich, timeline theo 02-design-system.md (muc 1).
enum CourtBookingStatus {
  /// Trong / Hoat dong / Da xac nhan (ACTIVE, CONFIRMED)
  activeConfirmed,

  /// Cho thanh toan, xac nhan, duyet (PENDING_*)
  pending,

  /// Bao tri / Da co nguoi dat (MAINTENANCE, BOOKED)
  maintenanceOrOccupied,

  /// Tam ngung / Da huy / That bai (SUSPENDED, CANCELLED)
  cancelledOrSuspended,

  /// Nhap / Da qua gio / Vang mat (DRAFT, EXPIRED, NO_SHOW)
  draftOrExpired,

  /// Da check-in / Hoan thanh (CHECKED_IN, COMPLETED)
  completedOrCheckedIn,
}

/// Cap mau nen va chu (kem vien tinh te) dat chuan do tuong phan WCAG 2.2 AA (>= 4.5:1).
@immutable
class StatusColorPair {
  final Color background;
  final Color foreground;
  final Color border;

  const StatusColorPair({
    required this.background,
    required this.foreground,
    required this.border,
  });

  static StatusColorPair lerp(StatusColorPair a, StatusColorPair b, double t) {
    return StatusColorPair(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      border: Color.lerp(a.border, b.border, t)!,
    );
  }
}

/// He thong Design Tokens kieu ThemeExtension theo frameworks/adapters/flutter.md
/// va docs/02-design-system.md.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  // Colors by intent
  final Color actionPrimary;
  final Color onActionPrimary;
  final Color actionSecondary;
  final Color onActionSecondary;
  final Color actionDanger;
  final Color onActionDanger;
  final Color surfacePrimary;
  final Color surfaceCard;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderSubtle;

  // 6 cap mau trang thai (02-design-system.md)
  final StatusColorPair statusActive;
  final StatusColorPair statusPending;
  final StatusColorPair statusMaintenance;
  final StatusColorPair statusCancelled;
  final StatusColorPair statusDraft;
  final StatusColorPair statusCompleted;

  // Spacing boi so cua 4: 4, 8, 12, 16, 24, 32
  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double space6;
  final double space8;

  // Border radius: Nut/Input 12, Card 16, BottomSheet 24
  final double radiusControl;
  final double radiusCard;
  final double radiusSheet;

  // Vung cham toi thieu 48x48dp (WCAG 2.5.8 & Material 3)
  final double minTapTarget;

  const AppTokens({
    required this.actionPrimary,
    required this.onActionPrimary,
    required this.actionSecondary,
    required this.onActionSecondary,
    required this.actionDanger,
    required this.onActionDanger,
    required this.surfacePrimary,
    required this.surfaceCard,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderSubtle,
    required this.statusActive,
    required this.statusPending,
    required this.statusMaintenance,
    required this.statusCancelled,
    required this.statusDraft,
    required this.statusCompleted,
    this.space1 = 4.0,
    this.space2 = 8.0,
    this.space3 = 12.0,
    this.space4 = 16.0,
    this.space6 = 24.0,
    this.space8 = 32.0,
    this.radiusControl = 12.0,
    this.radiusCard = 16.0,
    this.radiusSheet = 24.0,
    this.minTapTarget = 48.0,
  });

  /// Bang token che do Sang (Light Mode) voi do tuong phan WCAG 2.2 AA da kiem dinh.
  static const AppTokens light = AppTokens(
    actionPrimary: Color(0xFF188254), // Seed #1B8A5A tinh chinh dat 4.76:1 tren nen trang
    onActionPrimary: Color(0xFFFFFFFF),
    actionSecondary: Color(0xFFF4A62A),
    onActionSecondary: Color(0xFF1A1C19),
    actionDanger: Color(0xFFD93025),
    onActionDanger: Color(0xFFFFFFFF),
    surfacePrimary: Color(0xFFF7F9F6),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEF2EC),
    textPrimary: Color(0xFF151B18),
    textSecondary: Color(0xFF4A5550),
    borderSubtle: Color(0xFFD8E0DB),
    statusActive: StatusColorPair(
      background: Color(0xFFE2EFDA),
      foreground: Color(0xFF256B29), // 5.14:1
      border: Color(0xFFB8D8A8),
    ),
    statusPending: StatusColorPair(
      background: Color(0xFFFFF2CC),
      foreground: Color(0xFF7D6200), // 5.05:1
      border: Color(0xFFE6CE80),
    ),
    statusMaintenance: StatusColorPair(
      background: Color(0xFFFCE4D6),
      foreground: Color(0xFF9E4D00), // 4.92:1
      border: Color(0xFFF0B896),
    ),
    statusCancelled: StatusColorPair(
      background: Color(0xFFF8CBAD),
      foreground: Color(0xFF9E1F18), // 5.25:1
      border: Color(0xFFE59888),
    ),
    statusDraft: StatusColorPair(
      background: Color(0xFFEDEDED),
      foreground: Color(0xFF5C5C5C), // 5.50:1
      border: Color(0xFFD0D0D0),
    ),
    statusCompleted: StatusColorPair(
      background: Color(0xFFDDEBF7),
      foreground: Color(0xFF1F4E78), // 7.15:1
      border: Color(0xFFAECBE5),
    ),
  );

  /// Bang token che do Toi (Dark Mode) dong bo tu mot nguon duy nhat.
  static const AppTokens dark = AppTokens(
    actionPrimary: Color(0xFF29A36E),
    onActionPrimary: Color(0xFF062114),
    actionSecondary: Color(0xFFF6B64B),
    onActionSecondary: Color(0xFF231700),
    actionDanger: Color(0xFFFF6B61),
    onActionDanger: Color(0xFF2D0402),
    surfacePrimary: Color(0xFF121212),
    surfaceCard: Color(0xFF1C211E),
    surfaceMuted: Color(0xFF252C28),
    textPrimary: Color(0xFFECF2EE),
    textSecondary: Color(0xFFA6B3AC),
    borderSubtle: Color(0xFF313B35),
    statusActive: StatusColorPair(
      background: Color(0xFF15331B),
      foreground: Color(0xFF9BE6A0),
      border: Color(0xFF275B31),
    ),
    statusPending: StatusColorPair(
      background: Color(0xFF332908),
      foreground: Color(0xFFFFDF7A),
      border: Color(0xFF665214),
    ),
    statusMaintenance: StatusColorPair(
      background: Color(0xFF382010),
      foreground: Color(0xFFFFB785),
      border: Color(0xFF6B3E20),
    ),
    statusCancelled: StatusColorPair(
      background: Color(0xFF3B1412),
      foreground: Color(0xFFFFB3AC),
      border: Color(0xFF702824),
    ),
    statusDraft: StatusColorPair(
      background: Color(0xFF262626),
      foreground: Color(0xFFC7C7C7),
      border: Color(0xFF454545),
    ),
    statusCompleted: StatusColorPair(
      background: Color(0xFF12283B),
      foreground: Color(0xFF9CD0FF),
      border: Color(0xFF244D70),
    ),
  );

  StatusColorPair pairForStatus(CourtBookingStatus status) {
    switch (status) {
      case CourtBookingStatus.activeConfirmed:
        return statusActive;
      case CourtBookingStatus.pending:
        return statusPending;
      case CourtBookingStatus.maintenanceOrOccupied:
        return statusMaintenance;
      case CourtBookingStatus.cancelledOrSuspended:
        return statusCancelled;
      case CourtBookingStatus.draftOrExpired:
        return statusDraft;
      case CourtBookingStatus.completedOrCheckedIn:
        return statusCompleted;
    }
  }

  @override
  AppTokens copyWith({
    Color? actionPrimary,
    Color? onActionPrimary,
    Color? actionSecondary,
    Color? onActionSecondary,
    Color? actionDanger,
    Color? onActionDanger,
    Color? surfacePrimary,
    Color? surfaceCard,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? borderSubtle,
    StatusColorPair? statusActive,
    StatusColorPair? statusPending,
    StatusColorPair? statusMaintenance,
    StatusColorPair? statusCancelled,
    StatusColorPair? statusDraft,
    StatusColorPair? statusCompleted,
  }) {
    return AppTokens(
      actionPrimary: actionPrimary ?? this.actionPrimary,
      onActionPrimary: onActionPrimary ?? this.onActionPrimary,
      actionSecondary: actionSecondary ?? this.actionSecondary,
      onActionSecondary: onActionSecondary ?? this.onActionSecondary,
      actionDanger: actionDanger ?? this.actionDanger,
      onActionDanger: onActionDanger ?? this.onActionDanger,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      statusActive: statusActive ?? this.statusActive,
      statusPending: statusPending ?? this.statusPending,
      statusMaintenance: statusMaintenance ?? this.statusMaintenance,
      statusCancelled: statusCancelled ?? this.statusCancelled,
      statusDraft: statusDraft ?? this.statusDraft,
      statusCompleted: statusCompleted ?? this.statusCompleted,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      onActionPrimary: Color.lerp(onActionPrimary, other.onActionPrimary, t)!,
      actionSecondary: Color.lerp(actionSecondary, other.actionSecondary, t)!,
      onActionSecondary:
          Color.lerp(onActionSecondary, other.onActionSecondary, t)!,
      actionDanger: Color.lerp(actionDanger, other.actionDanger, t)!,
      onActionDanger: Color.lerp(onActionDanger, other.onActionDanger, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      statusActive: StatusColorPair.lerp(statusActive, other.statusActive, t),
      statusPending:
          StatusColorPair.lerp(statusPending, other.statusPending, t),
      statusMaintenance:
          StatusColorPair.lerp(statusMaintenance, other.statusMaintenance, t),
      statusCancelled:
          StatusColorPair.lerp(statusCancelled, other.statusCancelled, t),
      statusDraft: StatusColorPair.lerp(statusDraft, other.statusDraft, t),
      statusCompleted:
          StatusColorPair.lerp(statusCompleted, other.statusCompleted, t),
      space1: lerpDouble(space1, other.space1, t)!,
      space2: lerpDouble(space2, other.space2, t)!,
      space3: lerpDouble(space3, other.space3, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      space6: lerpDouble(space6, other.space6, t)!,
      space8: lerpDouble(space8, other.space8, t)!,
      radiusControl: lerpDouble(radiusControl, other.radiusControl, t)!,
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t)!,
      radiusSheet: lerpDouble(radiusSheet, other.radiusSheet, t)!,
      minTapTarget: lerpDouble(minTapTarget, other.minTapTarget, t)!,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.light;
}
