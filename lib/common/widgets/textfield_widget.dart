import 'package:flutter/material.dart';

import '../../utils/color_constants.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final double widthFactor;

  const TextFieldWidget({
    super.key,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.controller,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        width: screenWidth * widthFactor,
        child: obscureText
            ? _PasswordField(
                label: label,
                controller: controller,
                validator: validator,
              )
            : TextFormField(
                controller: controller,
                validator: validator,
                decoration: _inputDecoration(label),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Color(0xFF595959),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      filled: true,
      fillColor: ColorCodes.textformfeildcolor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDFCCC0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDFCCC0)),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const _PasswordField({
    required this.label,
    this.validator,
    this.controller,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() => setState(() => _obscureText = !_obscureText);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(
          color: Color(0xFF595959),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFFF0EAE6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDFCCC0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDFCCC0)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: _toggleVisibility,
        ),
      ),
    );
  }
}
