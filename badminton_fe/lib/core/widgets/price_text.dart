import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../utils/formatters.dart';

/// Hien thi gia tien VND (vi du: 140.000đ) voi FontFeature.tabularFigures()
/// de cac con so luon thang cot tren bang gia va danh sach san (02-design-system.md).
class PriceText extends StatelessWidget {
  final int amountVnd;
  final String? suffix;
  final TextStyle? style;
  final bool isHero;

  const PriceText({
    super.key,
    required this.amountVnd,
    this.suffix,
    this.style,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final baseStyle = style ??
        (isHero
            ? textTheme.headlineSmall?.copyWith(
                color: t.actionPrimary,
                fontWeight: FontWeight.w700,
              )
            : textTheme.titleMedium?.copyWith(
                color: t.actionPrimary,
                fontWeight: FontWeight.w600,
              ));

    final formatted = AppFormatters.currencyVnd(amountVnd);
    final fullText = suffix != null ? '$formatted$suffix' : formatted;

    return Text(
      fullText,
      style: baseStyle?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
