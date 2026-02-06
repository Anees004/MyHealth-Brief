import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// User avatar widget with initials fallback
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryTealLight.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildInitials(),
                  errorWidget: (context, url, error) => _buildInitials(),
                )
              : _buildInitials(),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primaryTeal,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
