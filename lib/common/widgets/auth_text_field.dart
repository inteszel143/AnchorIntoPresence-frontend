import 'package:flutter/material.dart';
import '../../utils/fonts.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField(
      {super.key,
      required this.label,
      required this.controller,
      this.widthFactor = 1,
      this.keyboardType,
      this.obscureText = false,
      this.validator});
  final String label;
  final TextEditingController controller;
  final double widthFactor;
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
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.obscureText && !_visible,
      autocorrect: false,
      enableSuggestions: !widget.obscureText,
      keyboardType: widget.keyboardType ??
          (widget.obscureText
              ? TextInputType.text
              : TextInputType.emailAddress),
      textInputAction:
          widget.obscureText ? TextInputAction.done : TextInputAction.next,
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
          color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: widget.label,
        errorMaxLines: 3,
        hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outline)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2)),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _visible ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                    _visible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 21),
              )
            : null,
      ),
    );
  }
}
