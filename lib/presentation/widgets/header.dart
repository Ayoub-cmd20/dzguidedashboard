import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

class GlobalHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSettingsTap;

  const GlobalHeader({super.key, required this.title, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          // Small Logo for context
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Returning to Overview...'), duration: Duration(milliseconds: 500)),
              );
            },
            child: Image.asset(
              'assets/logo.png',
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/logo.jpeg',
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  LucideIcons.compass,
                  color: AppColors.dzGreen,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Search Bar
          Flexible(
            flex: 4,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for: $value')),
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          // Notifications
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have 3 new notifications')),
              );
            },
            icon: Stack(
              children: [
                const Icon(LucideIcons.bell, color: AppColors.textSecondary, size: 24),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.algerianRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Profile
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              } else if (value == 'settings') {
                if (onSettingsTap != null) onSettingsTap!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action: $value')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(LucideIcons.user, size: 18),
                  title: Text('My Profile'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(LucideIcons.settings, size: 18),
                  title: Text('Account Settings'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(LucideIcons.logOut, size: 18, color: AppColors.algerianRed),
                  title: Text('Logout', style: TextStyle(color: AppColors.algerianRed)),
                  dense: true,
                ),
              ),
            ],
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.dzGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Admin DZ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                    Text(
                      'Super Admin',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
