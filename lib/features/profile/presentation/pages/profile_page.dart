import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text(AppStrings.profile),
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRoutes.login);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Re-check auth so profile stays visible (user is still logged in)
            context.read<AuthBloc>().add(const AuthCheckRequested());
          }
        },
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const SizedBox.shrink();
          }

          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // User Info Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      UserAvatar(
                        imageUrl: user.photoUrl,
                        initials: user.initials,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName ?? 'User',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement edit profile
                          },
                          icon: const FaIcon(FontAwesomeIcons.pen, size: 18),
                          label: const Text(AppStrings.editProfile),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Settings Section
                _buildSection(
                  title: AppStrings.settings,
                  children: [
                    _SettingsTile(
                      icon: FontAwesomeIcons.bell,
                      title: AppStrings.notifications,
                      onTap: () {
                        // TODO: Notifications settings
                      },
                    ),
                    _SettingsTile(
                      icon: FontAwesomeIcons.shieldHalved,
                      title: 'Privacy',
                      onTap: () {
                        // TODO: Privacy settings
                      },
                    ),
                    _SettingsTile(
                      icon: FontAwesomeIcons.language,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {
                        // TODO: Language settings
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Support Section
                _buildSection(
                  title: 'Support',
                  children: [
                    _SettingsTile(
                      icon: FontAwesomeIcons.circleQuestion,
                      title: AppStrings.helpSupport,
                      onTap: () {
                        // TODO: Help & Support
                      },
                    ),
                    _SettingsTile(
                      icon: FontAwesomeIcons.fileLines,
                      title: AppStrings.termsOfService,
                      onTap: () => _launchUrl('https://example.com/terms'),
                    ),
                    _SettingsTile(
                      icon: FontAwesomeIcons.userShield,
                      title: AppStrings.privacyPolicy,
                      onTap: () => _launchUrl('https://example.com/privacy'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Logout
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
                    label: const Text(AppStrings.logout),
                  ),
                ),
                const SizedBox(height: 16),
                // Delete account
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextButton.icon(
                    onPressed: () => _showDeleteAccountDialog(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                    ),
                    icon: const FaIcon(FontAwesomeIcons.trashCan, size: 18),
                    label: const Text(AppStrings.deleteAccount),
                  ),
                ),
                const SizedBox(height: 24),
                // App Version
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteAccountConfirmTitle),
        content: const Text(AppStrings.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text(AppStrings.deleteAccountConfirmButton),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              FaIcon(
                icon,
                size: 22,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 20,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
