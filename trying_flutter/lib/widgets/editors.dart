import 'package:flutter/material.dart';

class EditorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const EditorButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
