// editors.dart

import 'package:flutter/material.dart';

class EditorButton extends StatelessWidget {
  final String label;
  final IconData? icon; // Ajoute ce paramètre
  final VoidCallback onTap;

  const EditorButton({
    super.key,
    required this.label,
    this.icon, // Rend-le optionnel
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 18),
            ),
    );
  }
}