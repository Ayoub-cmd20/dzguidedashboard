import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/theme/theme_bloc.dart';
import '../../logic/blocs/theme/theme_event.dart';
import '../../logic/blocs/theme/theme_state.dart';
import '../../logic/blocs/settings/settings_bloc.dart';
import '../../logic/blocs/settings/settings_event.dart';
import '../../logic/blocs/settings/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildAdminProfile(context),
                  const SizedBox(height: 32),
                  _buildSettingsSection(
                    context: context,
                    title: 'System Preferences',
                    children: [
                      _buildSettingTile(
                        context: context,
                        icon: LucideIcons.languages,
                        title: 'Language',
                        subtitle: 'Choose your preferred language',
                        trailing: DropdownButton<String>(
                          value: settingsState.languageName,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              context.read<SettingsBloc>().add(ChangeLanguage(newValue));
                            }
                          },
                          items: ['English', 'French', 'Arabic']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(),
                      _buildSettingTile(
                        context: context,
                        icon: LucideIcons.moon,
                        title: 'Dark Mode',
                        subtitle: 'Toggle dashboard appearance',
                        trailing: Switch(
                          value: themeState.isDarkMode,
                          activeThumbColor: AppColors.dzGreen,
                          onChanged: (val) => context.read<ThemeBloc>().add(ToggleGlobalTheme(val)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    context: context,
                    title: 'Notifications',
                    children: [
                      _buildSettingTile(
                        context: context,
                        icon: LucideIcons.mail,
                        title: 'Email Notifications',
                        subtitle: 'Receive daily summary of inquiries',
                        trailing: Switch(
                          value: true,
                          activeThumbColor: AppColors.dzGreen,
                          onChanged: (val) {},
                        ),
                      ),
                      const Divider(),
                      _buildSettingTile(
                        context: context,
                        icon: LucideIcons.bellRing,
                        title: 'Push Notifications',
                        subtitle: 'Get real-time alerts for new bookings',
                        trailing: Switch(
                          value: true,
                          activeThumbColor: AppColors.dzGreen,
                          onChanged: (val) {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    context: context,
                    title: 'Security',
                    children: [
                      _buildSettingTile(
                        context: context,
                        icon: LucideIcons.lock,
                        title: 'Change Password',
                        subtitle: 'Last changed 3 months ago',
                        onTap: () {},
                      ),
                      const Divider(),
                      _buildSettingTile(
                        context: context,
                        icon: LucideIcons.shieldCheck,
                        title: 'Two-Factor Authentication',
                        subtitle: 'Add an extra layer of security',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  const Center(
                    child: Text(
                      'DZ Guide Dashboard v1.0.0',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Manage your account and application preferences',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAdminProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Admin+DZ&background=006633&color=fff'),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin DZ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Text(
                  'admin@dzguide.com',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dzGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Super Administrator',
                    style: TextStyle(color: AppColors.dzGreen, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({required BuildContext context, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.dzGreen, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 18),
      onTap: onTap,
    );
  }
}
