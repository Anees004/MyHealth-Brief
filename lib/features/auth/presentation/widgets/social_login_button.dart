import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Social login button (Google, Apple)
class SocialLoginButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.white,
    this.textColor = AppColors.textPrimary,
  });

  /// Google sign in button
  factory SocialLoginButton.google({VoidCallback? onPressed}) {
    return SocialLoginButton(
      label: AppStrings.continueWithGoogle,
      icon: Image.network(
        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) => const FaIcon(
          FontAwesomeIcons.google,
          size: 24,
          color: Colors.red,
        ),
      ),
      onPressed: onPressed,
      backgroundColor: AppColors.white,
      textColor: AppColors.textPrimary,
    );
  }

  /// Apple sign in button
  factory SocialLoginButton.apple({VoidCallback? onPressed}) {
    return SocialLoginButton(
      label: AppStrings.continueWithApple,
      icon: const FaIcon(
        FontAwesomeIcons.apple,
        size: 24,
        color: AppColors.white,
      ),
      onPressed: onPressed,
      backgroundColor: AppColors.textPrimary,
      textColor: AppColors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: backgroundColor == AppColors.white
                ? AppColors.divider
                : backgroundColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
