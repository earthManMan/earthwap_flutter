import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';

class ApplyButton extends StatelessWidget {
  final VoidCallback onApply;

  const ApplyButton({
    super.key,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorStyles.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: onApply,
        child: const Text(
          '적용',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }
}
