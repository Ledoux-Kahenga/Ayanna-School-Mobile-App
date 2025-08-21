import 'package:ayanna_school/theme/ayanna_theme.dart';
import 'package:flutter/material.dart';
import '../ayanna_theme.dart';

class AyannaLogo extends StatelessWidget {
  final double size;
  const AyannaLogo({this.size = 120, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AyannaColors.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AyannaColors.orange.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.school, size: size * 0.6, color: AyannaColors.white),
      ),
    );
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AyannaColors.darkGrey),
          filled: true,
          fillColor: AyannaColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AyannaColors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AyannaColors.orange, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AyannaColors.lightGrey,
              width: 2,
            ),
          ),
        ),
        style: const TextStyle(color: AyannaColors.darkGrey),
      ),
    );
  }
}

class AyannaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
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
          backgroundColor: filled ? AyannaColors.orange : AyannaColors.white,
          foregroundColor: filled ? AyannaColors.white : AyannaColors.orange,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: filled ? 2 : 0,
          side: filled
              ? null
              : const BorderSide(color: AyannaColors.orange, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(48),
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

class AyannaSchoolIcon extends StatelessWidget {
  final double size;
  final Color color;
  const AyannaSchoolIcon({
    this.size = 56,
    this.color = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.school, size: size, color: color);
  }
}
