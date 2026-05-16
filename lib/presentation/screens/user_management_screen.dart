import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/blocs/users/users_bloc.dart';
import '../../logic/blocs/users/users_state.dart';
import '../widgets/loading_shimmer.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Management',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'Manage traveler profiles and Elite tier status',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, UsersState state) {
    if (state is UsersLoading) {
      return const LoadingShimmer(width: double.infinity, height: 600, borderRadius: 25);
    } else if (state is UsersLoaded) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1.5),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _buildTableHeader(),
                  ...state.users.map((user) => _buildTableRow(context, user)),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (state is UsersError) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        'Traveler',
        'Elite Tier',
        'Points Balance',
        'Joined Date',
        'Actions',
      ]
          .map((text) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ))
          .toList(),
    );
  }

  TableRow _buildTableRow(BuildContext context, Map<String, dynamic> user) {
    Color tierColor;
    switch (user['tier']) {
      case 'Platinum':
        tierColor = AppColors.elitePurple;
        break;
      case 'Gold':
        tierColor = const Color(0xFFFFD700);
        break;
      default:
        tierColor = Colors.blueGrey;
    }

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: NetworkImage(user['avatar']),
                onBackgroundImageError: (e, s) => const Icon(LucideIcons.user, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(user['email'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user['tier'],
              style: TextStyle(color: tierColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${user['points']} pts', style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(user['joined']),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(LucideIcons.eye, size: 18, color: AppColors.dzGreen),
                onPressed: () => _showUserDetails(context, user),
                tooltip: 'View Profile',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(LucideIcons.edit2, size: 18, color: AppColors.elitePurple),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit profile for ${user['name']}')),
                  );
                },
                tooltip: 'Edit Tier',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.algerianRed),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User account restricted')),
                  );
                },
                tooltip: 'Restrict',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Row(
          children: [
            Icon(LucideIcons.user, color: AppColors.dzGreen),
            SizedBox(width: 12),
            Text('Traveler Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user['avatar']),
            ),
            const SizedBox(height: 16),
            Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(user['email'], style: const TextStyle(color: AppColors.textSecondary)),
            const Divider(height: 32),
            _buildDetailRow('Elite Status', user['tier']),
            _buildDetailRow('Points Balance', '${user['points']} pts'),
            _buildDetailRow('Member Since', user['joined']),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
