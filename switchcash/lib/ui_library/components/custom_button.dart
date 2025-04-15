import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true), // Efek timbul saat tombol ditekan
      onTapUp: (_) => setState(() => isPressed = false), // Kembali normal setelah dilepas
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        constraints: const BoxConstraints(minWidth: 150), 
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPressed
              ? [BoxShadow(color: const Color.fromARGB(255, 26, 25, 25).withOpacity(0.3), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Color.fromARGB(255, 245, 240, 240),
                letterSpacing: 1.2, 
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
