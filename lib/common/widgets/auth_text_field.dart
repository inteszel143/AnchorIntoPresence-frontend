import 'package:flutter/material.dart';
import '../../utils/fonts.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField(
      {super.key,
      required this.label,
      required this.controller,
      this.widthFactor = 1,
      this.compact = false,
      this.keyboardType,
      this.obscureText = false,
      this.validator});
  final String label;
  final TextEditingController controller;
  final double widthFactor;
  final bool compact;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  State<AuthTextField> createState() => AuthTextFieldState();
}

class AuthTextFieldState extends State<AuthTextField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator,
      builder: (fieldState) {
        final hasError = fieldState.hasError;
        final colorScheme = Theme.of(context).colorScheme;
        final enabledBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        );
        final errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.controller,
              onChanged: fieldState.didChange,
              obscureText: widget.obscureText && !_visible,
              autocorrect: false,
              enableSuggestions: !widget.obscureText,
              keyboardType: widget.keyboardType ??
                  (widget.obscureText
                      ? TextInputType.text
                      : TextInputType.emailAddress),
              textInputAction: widget.obscureText
                  ? TextInputAction.done
                  : TextInputAction.next,
              autofillHints: [
                widget.obscureText
                    ? AutofillHints.password
                    : widget.keyboardType == TextInputType.name
                        ? AutofillHints.name
                        : AutofillHints.email
              ],
              style: TextStyle(
                fontFamily: Fonts.body,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                constraints:
                    widget.compact ? const BoxConstraints(minHeight: 48) : null,
                hintText: widget.label,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 18, vertical: widget.compact ? 12 : 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: hasError ? errorBorder : enabledBorder,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasError ? colorScheme.error : colorScheme.primary,
                    width: 2,
                  ),
                ),
                suffixIcon: widget.obscureText
                    ? IconButton(
                        tooltip: _visible ? 'Hide password' : 'Show password',
                        onPressed: () => setState(() => _visible = !_visible),
                        icon: Icon(
                          _visible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 21,
                        ),
                      )
                    : null,
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Text(
                fieldState.errorText!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.error,
                  fontFamily: Fonts.body,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
