import 'package:flutter/material.dart';
import '../ayanna_theme.dart';

class AyannaLogo extends StatelessWidget {
  final double size;
  const AyannaLogo({this.size = 120, super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/favicon.ico', width: size, height: size);
  }
}

class AyannaTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const AyannaTextField({
    required this.label,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class AyannaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool filled;

  const AyannaButton({
    required this.text,
    required this.onPressed,
    this.filled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? AyannaTheme.accent : Colors.transparent,
          foregroundColor: filled ? AyannaTheme.primary : AyannaTheme.primary,
          side: filled
              ? null
              : const BorderSide(color: AyannaTheme.primary, width: 2),
          elevation: filled ? 2 : 0,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
