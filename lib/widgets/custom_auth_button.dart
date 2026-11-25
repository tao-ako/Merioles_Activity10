import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomAuthButton extends StatelessWidget {
  const CustomAuthButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.buttonBackground,
          foregroundColor: AppTheme.purple,
          disabledBackgroundColor: AppTheme.buttonBackground,
          disabledForegroundColor: AppTheme.purple,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
