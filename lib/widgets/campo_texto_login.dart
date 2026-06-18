import 'package:flutter/material.dart';

class CampoTextoLogin extends StatelessWidget {
  const CampoTextoLogin({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);
    const borderBeige = Color(0xFFE2D3C2);
    const softGreen = Color(0xFF6D8B74);

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: coffeeBrown),
        hintStyle: TextStyle(color: coffeeBrown.withValues(alpha: 0.45)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: softGreen, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB94A48)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB94A48), width: 1.4),
        ),
      ),
    );
  }
}
