import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'app_button.dart';

/// Man hinh trang thai rong (EmptyState) theo 02-design-system.md va UX/UI Doctrine:
/// - So huu khong gian khung nhin (khong troi lo lung sat header)
/// - Gom icon minh hoa + tieu de ro rang + cau huong dan hanh dong + nut bam tuy chon
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(t.space8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: t.surfaceMuted,
                  borderRadius: BorderRadius.circular(t.radiusCard),
                  border: Border.all(color: t.borderSubtle, width: 1),
                ),
                child: Icon(icon, size: 32, color: t.actionPrimary),
              ),
              SizedBox(height: t.space4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              SizedBox(height: t.space2),
              Text(
                description,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: t.space6),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: AppButtonVariant.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
