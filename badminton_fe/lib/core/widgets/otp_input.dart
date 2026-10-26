import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../theme/app_tokens.dart';
import 'app_button.dart';

/// Component OtpInput 6 o theo 02-design-system.md va 01-kien-truc.md:
/// - 6 o so, ho tro dan ma (paste), dem nguoc giay, nut Gui lai ma
/// - Xu ly trang thai khoa khi nhap sai qua so lan (OTP_TOO_MANY_ATTEMPTS)
class OtpInput extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final VoidCallback? onResend;
  final bool isLocked;
  final String? errorText;
  final int secondsRemaining;

  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onResend,
    this.isLocked = false,
    this.errorText,
    this.secondsRemaining = 45,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Ho tro dan ma 6 chu so
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        _focusNodes[5].unfocus();
        widget.onCompleted(digits.substring(0, 6));
      }
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((e) => e.text).join();
    if (code.length == 6) {
      widget.onCompleted(code);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: t.minTapTarget,
              height: t.minTapTarget + t.space1,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                enabled: !widget.isLocked,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: textTheme.titleLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: widget.isLocked ? t.surfaceMuted : t.surfaceCard,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(t.radiusControl),
                    borderSide: BorderSide(
                      color: widget.errorText != null
                          ? t.actionDanger
                          : t.borderSubtle,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(t.radiusControl),
                    borderSide: BorderSide(color: t.actionPrimary, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(t.radiusControl),
                    borderSide: BorderSide(color: t.borderSubtle),
                  ),
                ),
                onChanged: (val) => _onDigitChanged(index, val),
              ),
            );
          }),
        ),
        if (widget.isLocked) ...[
          SizedBox(height: t.space2),
          Text(
            AppStrings.errOtpTooMany,
            style: textTheme.bodyMedium?.copyWith(color: t.actionDanger),
          ),
        ] else if (widget.errorText != null) ...[
          SizedBox(height: t.space2),
          Text(
            widget.errorText!,
            style: textTheme.bodyMedium?.copyWith(color: t.actionDanger),
          ),
        ],
        SizedBox(height: t.space3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.secondsRemaining > 0 && !widget.isLocked
                  ? 'Mã hiệu lực còn ${widget.secondsRemaining}s'
                  : 'Bạn chưa nhận được mã?',
              style: textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            AppButton(
              label: AppStrings.actionResendOtp,
              variant: AppButtonVariant.text,
              onPressed: (widget.secondsRemaining == 0 || widget.isLocked)
                  ? widget.onResend
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
