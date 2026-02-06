import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Action card for Scan Report and Upload PDF
class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  /// Factory for Scan Report card
  factory ActionCard.scanReport({required VoidCallback onTap}) {
    return ActionCard(
      title: 'Scan Report',
      icon: FontAwesomeIcons.camera,
      backgroundColor: AppColors.scanCardBackground,
      iconColor: AppColors.primaryTeal,
      onTap: onTap,
    );
  }

  /// Factory for Upload PDF card
  factory ActionCard.uploadPdf({required VoidCallback onTap}) {
    return ActionCard(
      title: 'Upload PDF',
      icon: FontAwesomeIcons.fileArrowUp,
      backgroundColor: AppColors.uploadCardBackground,
      iconColor: AppColors.purpleGradientStart,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
