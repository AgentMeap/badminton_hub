import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// O nhap lieu dung chung theo 02-design-system.md:
/// - Label dat phia tren o nhap, khoang cach 4dp (space1)
/// - Bo goc 12dp (radiusControl), vung cham >= 48dp
/// - Ho tro goi y (hint), bao loi (errorText), an/hien mat khau (isPassword)
class AppTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final bool isPassword;
  final bool enabled;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.errorText,
    this.helperText,
    this.controller,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final hasError =
        widget.errorText != null && widget.errorText!.trim().isNotEmpty;

    final borderRadius = BorderRadius.circular(t.radiusControl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: textTheme.labelLarge?.copyWith(color: t.textPrimary),
        ),
        SizedBox(height: t.space1),
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: textTheme.bodyMedium,
            helperText: widget.helperText,
            helperStyle: textTheme.labelSmall,
            errorText: hasError ? widget.errorText : null,
            errorMaxLines: 2,
            filled: true,
            fillColor: widget.enabled ? t.surfaceCard : t.surfaceMuted,
            contentPadding: EdgeInsets.symmetric(
              horizontal: t.space4,
              vertical: t.space3,
            ),
            constraints: BoxConstraints(minHeight: t.minTapTarget),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: t.textSecondary, size: 20)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                    constraints: BoxConstraints(
                      minWidth: t.minTapTarget,
                      minHeight: t.minTapTarget,
                    ),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: t.textSecondary,
                      size: 20,
                    ),
                    onPressed: widget.enabled
                        ? () => setState(() => _obscure = !_obscure)
                        : null,
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: t.borderSubtle, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: t.actionPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: t.actionDanger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: t.actionDanger, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: t.borderSubtle, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
