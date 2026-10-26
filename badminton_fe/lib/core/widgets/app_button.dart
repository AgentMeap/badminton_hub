import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// 4 bien the theo 02-design-system.md: primary / secondary / text / danger.
enum AppButtonVariant { primary, secondary, text, danger }

/// Nut bam chuan Design System:
/// - Du cac trang thai: default, hover, focus, pressed, disabled, loading
/// - Loading giu nguyen mau nen theo y dinh (intent) va hien vong xoay, khong lam mo nhu disabled
/// - Vung cham toi thieu 48x48dp (WCAG 2.5.8)
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? leadingIcon;
  final bool expandWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.leadingIcon,
    this.expandWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isDisabled = onPressed == null && !loading;

    final Color bg;
    final Color fg;
    final BorderSide side;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = t.actionPrimary;
        fg = t.onActionPrimary;
        side = BorderSide.none;
      case AppButtonVariant.secondary:
        bg = t.surfaceCard;
        fg = t.textPrimary;
        side = BorderSide(color: t.borderSubtle, width: 1);
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = t.actionPrimary;
        side = BorderSide.none;
      case AppButtonVariant.danger:
        bg = t.actionDanger;
        fg = t.onActionDanger;
        side = BorderSide.none;
    }

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size(expandWidth ? double.infinity : t.minTapTarget, t.minTapTarget),
      ),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(horizontal: t.space4, vertical: t.space3),
      ),
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (isDisabled) return t.surfaceMuted;
        if (states.contains(WidgetState.pressed)) {
          return Color.alphaBlend(fg.withValues(alpha: 0.14), bg);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return Color.alphaBlend(fg.withValues(alpha: 0.08), bg);
        }
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (isDisabled) return t.textSecondary;
        return fg;
      }),
      overlayColor: WidgetStateProperty.all(fg.withValues(alpha: 0.10)),
      shape: WidgetStateProperty.resolveWith((states) {
        final hasFocus = states.contains(WidgetState.focused);
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusControl),
          side: hasFocus
              ? BorderSide(color: t.actionPrimary, width: 2)
              : (isDisabled
                  ? BorderSide(color: t.borderSubtle, width: 1)
                  : side),
        );
      }),
      textStyle: WidgetStateProperty.all(
        Theme.of(context).textTheme.labelLarge,
      ),
    );

    final Widget child = loading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              ),
              SizedBox(width: t.space2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18),
                SizedBox(width: t.space2),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: !isDisabled && !loading,
      label: loading ? '$label, đang xử lý' : label,
      child: FilledButton(
        onPressed: (isDisabled || loading) ? null : onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
