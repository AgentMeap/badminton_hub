import 'package:flutter/material.dart';
import 'app_tokens.dart';

/// Cau hinh ThemeData Material 3 cho Light & Dark mode theo 02-design-system.md.
/// - Mau chu dao: #1B8A5A (xanh la mat san)
/// - Font: Be Vietnam Pro (fallback Roboto/system)
/// - Scale chu: headlineSmall 24/SemiBold, titleLarge 20/SemiBold, titleMedium 16/Medium,
///   bodyLarge 16/Regular, bodyMedium 14/Regular, labelLarge 14/SemiBold, labelSmall 11/Medium.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Be Vietnam Pro';

  static TextTheme _buildTextTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.18,
        letterSpacing: -0.5,
        color: primaryText,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: primaryText,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primaryText,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: primaryText,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primaryText,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: secondaryText,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: primaryText,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.2,
        color: secondaryText,
      ),
    );
  }

  static ThemeData light() => _fromTokens(AppTokens.light, Brightness.light);

  static ThemeData dark() => _fromTokens(AppTokens.dark, Brightness.dark);

  static ThemeData _fromTokens(AppTokens t, Brightness brightness) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B8A5A),
      brightness: brightness,
    ).copyWith(
      primary: t.actionPrimary,
      onPrimary: t.onActionPrimary,
      secondary: t.actionSecondary,
      onSecondary: t.onActionSecondary,
      error: t.actionDanger,
      onError: t.onActionDanger,
      surface: t.surfaceCard,
      onSurface: t.textPrimary,
      outline: t.borderSubtle,
    );

    final textTheme = _buildTextTheme(t.textPrimary, t.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: t.surfacePrimary,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[t],
      appBarTheme: AppBarTheme(
        backgroundColor: t.surfaceCard,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        shape: Border(bottom: BorderSide(color: t.borderSubtle, width: 1)),
      ),
      cardTheme: CardThemeData(
        color: t.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusCard),
          side: BorderSide(color: t.borderSubtle, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(t.radiusSheet),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.surfaceCard,
        indicatorColor: t.statusActive.background,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelSmall!.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? t.actionPrimary : t.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? t.actionPrimary : t.textSecondary,
            size: 24,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: t.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
