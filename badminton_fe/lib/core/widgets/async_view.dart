import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_tokens.dart';
import 'app_button.dart';
import 'empty_state.dart';

/// Trang thai bat dong bo tuong thich truc tiep voi AsyncValue cua Riverpod
/// de moi man hinh xu ly du 4 trang thai: loading / empty / error / data.
enum AsyncStatus { loading, data, error }

@immutable
class AsyncState<T> {
  final AsyncStatus status;
  final T? data;
  final String? errorMessage;

  const AsyncState._({
    required this.status,
    this.data,
    this.errorMessage,
  });

  const AsyncState.loading() : this._(status: AsyncStatus.loading);

  const AsyncState.data(T value)
      : this._(status: AsyncStatus.data, data: value);

  const AsyncState.error(String message)
      : this._(status: AsyncStatus.error, errorMessage: message);
}

/// Widget boc trang thai tai du lieu (02-design-system.md):
/// Dam bao moi man hinh deu co du: loading / error (nut thu lai) / empty / data.
class AsyncView<T> extends StatelessWidget {
  final AsyncState<T> state;
  final bool Function(T data)? isEmpty;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final String emptyTitle;
  final String emptyDescription;
  final IconData emptyIcon;

  const AsyncView({
    super.key,
    required this.state,
    required this.builder,
    this.isEmpty,
    this.onRetry,
    this.emptyTitle = AppStrings.emptyBookingsTitle,
    this.emptyDescription = AppStrings.emptyBookingsBody,
    this.emptyIcon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    switch (state.status) {
      case AsyncStatus.loading:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(t.space8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(t.actionPrimary),
                  ),
                ),
                SizedBox(height: t.space3),
                Text(
                  'Đang tải dữ liệu sân...',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );

      case AsyncStatus.error:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(t.space6),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: EdgeInsets.all(t.space6),
              decoration: BoxDecoration(
                color: t.surfaceCard,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(color: t.statusCancelled.border, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 36,
                    color: t.actionDanger,
                  ),
                  SizedBox(height: t.space3),
                  Text(
                    'Không thể tải dữ liệu',
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: t.space2),
                  Text(
                    state.errorMessage ??
                        'Đã xảy ra sự cố kết nối. Bạn hãy bấm Thử lại.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null) ...[
                    SizedBox(height: t.space4),
                    AppButton(
                      label: AppStrings.actionRetry,
                      leadingIcon: Icons.refresh_rounded,
                      onPressed: onRetry,
                      variant: AppButtonVariant.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );

      case AsyncStatus.data:
        final value = state.data;
        if (value == null || (isEmpty != null && isEmpty!(value))) {
          return EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            description: emptyDescription,
            actionLabel: onRetry != null ? 'Tải lại danh sách' : null,
            onAction: onRetry,
          );
        }
        return builder(context, value);
    }
  }
}
