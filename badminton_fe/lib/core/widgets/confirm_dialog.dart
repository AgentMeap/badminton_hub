import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'app_button.dart';

/// Hop xac nhan cho thao tac quan trong hoac khong hoan tac duoc (02-design-system.md).
/// Tuan thu quy tac Token by Intent: neu isDestructive = true (vi du: Huy luot dat, Khoa tai khoan),
/// nut xac nhan bat buoc dung AppButtonVariant.danger (#D93025), khong bao gio dung mau primary.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Quay lại',
    this.isDestructive = true,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Quay lại',
    bool isDestructive = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: t.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusCard),
        side: BorderSide(color: t.borderSubtle, width: 1),
      ),
      title: Row(
        children: [
          Icon(
            isDestructive
                ? Icons.warning_amber_rounded
                : Icons.help_outline_rounded,
            color: isDestructive ? t.actionDanger : t.actionPrimary,
            size: 24,
          ),
          SizedBox(width: t.space2),
          Expanded(
            child: Text(title, style: textTheme.titleLarge),
          ),
        ],
      ),
      content: Text(message, style: textTheme.bodyMedium),
      actionsPadding: EdgeInsets.fromLTRB(
        t.space6,
        0,
        t.space6,
        t.space4,
      ),
      actions: [
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: confirmLabel,
          variant: isDestructive
              ? AppButtonVariant.danger
              : AppButtonVariant.primary,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}
