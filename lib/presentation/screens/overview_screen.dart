import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/blocs/overview/overview_bloc.dart';
import '../../logic/blocs/overview/overview_event.dart';
import '../../logic/blocs/overview/overview_state.dart';
import '../../logic/blocs/inquiries/inquiries_bloc.dart';
import '../../logic/blocs/inquiries/inquiries_event.dart';
import '../../logic/blocs/inquiries/inquiries_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/engagement_chart.dart';

class OverviewScreen extends StatelessWidget {
  final VoidCallback? onViewAll;
  const OverviewScreen({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InquiriesBloc, InquiriesState>(
      listener: (context, state) {
        if (state is InquiriesLoaded) {
          // Sync overview stats when an inquiry is modified
          context.read<OverviewBloc>().add(LoadOverviewData());
        }
        if (state is InquiriesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.algerianRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<OverviewBloc, OverviewState>(
        builder: (context, state) {
          if (state is OverviewLoading) {
            return _buildLoadingState();
          } else if (state is OverviewLoaded) {
            return _buildContent(context, state);
          } else if (state is OverviewError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            children: List.generate(4, (index) => const Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 24),
                child: LoadingShimmer(height: 160, width: double.infinity, borderRadius: 25),
              ),
            )),
          ),
          const SizedBox(height: 32),
          const LoadingShimmer(height: 400, width: double.infinity, borderRadius: 25),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, OverviewLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          LayoutBuilder(builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 1200 ? 4 : 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.6,
              ),
              itemCount: state.stats.length,
              itemBuilder: (context, index) {
                final stat = state.stats[index];
                return StatCard(
                  title: stat['title'],
                  value: stat['value'],
                  trend: stat['trend'],
                  icon: _getIcon(stat['icon']),
                  color: _getColor(stat['icon']),
                );
              },
            );
          }),
          const SizedBox(height: 32),
          const EngagementChart(),
          const SizedBox(height: 32),
          // Recent Inquiries Table
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Venue Inquiries',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.recentInquiries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No recent inquiries.')),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1000,
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(1.5),
                          3: FlexColumnWidth(1.2),
                          4: FlexColumnWidth(1.3),
                          5: FlexColumnWidth(1.5),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          _buildHeaderRow(),
                          ...state.recentInquiries.map((inquiry) => _buildDataRow(
                                context,
                                inquiry,
                              )),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'users': return LucideIcons.users;
      case 'clock': return LucideIcons.clock;
      case 'gift': return LucideIcons.gift;
      case 'mapPin': return LucideIcons.mapPin;
      default: return LucideIcons.helpCircle;
    }
  }

  Color _getColor(String iconName) {
    switch (iconName) {
      case 'users': return AppColors.dzGreen;
      case 'clock': return AppColors.elitePurple;
      case 'gift': return AppColors.dzGreen;
      case 'mapPin': return AppColors.algerianRed;
      default: return AppColors.dzGreen;
    }
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      children: [
        'Venue',
        'Inquirer',
        'Event Date',
        'Capacity',
        'Status',
        'Action',
      ]
          .map((text) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ))
          .toList(),
    );
  }

  TableRow _buildDataRow(
    BuildContext context,
    Map<String, dynamic> inquiry,
  ) {
    final String statusStr = inquiry['status'].toString().toLowerCase();
    final bool isConfirmed = statusStr == 'confirmed';
    final bool isPending = statusStr == 'pending';
    final bool isDeclined = statusStr == 'declined' || statusStr == 'rejected';

    Color statusColor = AppColors.elitePurple;
    if (isConfirmed) statusColor = AppColors.dzGreen;
    if (isDeclined) statusColor = AppColors.algerianRed;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(inquiry['venue'], style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(inquiry['inquirer']),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(inquiry['date']),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(inquiry['capacity']),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: UnconstrainedBox(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                inquiry['status'],
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(LucideIcons.eye, size: 18, color: AppColors.textSecondary),
                onPressed: () => _showInquiryDetails(context, inquiry),
                tooltip: 'View Details',
              ),
              if (isPending) ...[
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: const Icon(LucideIcons.checkCircle, size: 18, color: AppColors.dzGreen),
                  onPressed: () => _showConfirmationDialog(context, inquiry, 'confirmed'),
                  tooltip: 'Confirm',
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: const Icon(LucideIcons.xCircle, size: 18, color: AppColors.algerianRed),
                  onPressed: () => _showConfirmationDialog(context, inquiry, 'declined'),
                  tooltip: 'Decline',
                ),
              ],
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.algerianRed),
                onPressed: () => _showDeleteDialog(context, inquiry),
                tooltip: 'Delete Inquiry',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context, Map<String, dynamic> inquiry, String newStatus) {
    final bool isConfirming = newStatus == 'confirmed';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isConfirming ? 'Confirm Booking' : 'Decline Inquiry'),
        content: Text('Are you sure you want to ${isConfirming ? 'confirm' : 'decline'} this booking for "${inquiry['venue']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<InquiriesBloc>().add(UpdateInquiryStatus(inquiry['id'], newStatus));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isConfirming ? AppColors.dzGreen : AppColors.algerianRed,
              foregroundColor: Colors.white,
            ),
            child: Text(isConfirming ? 'Confirm' : 'Decline'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> inquiry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Inquiry'),
        content: Text('Delete inquiry from "${inquiry['inquirer']}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<InquiriesBloc>().add(DeleteInquiry(inquiry['id']));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.algerianRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showInquiryDetails(BuildContext context, Map<String, dynamic> inquiry) {
    final status = inquiry['status'].toString().toLowerCase();
    final isPending = status == 'pending';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Row(
          children: [
            Icon(LucideIcons.calendarCheck, color: AppColors.dzGreen),
            SizedBox(width: 12),
            Text('Inquiry Details'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Venue', inquiry['venue']),
              _buildDetailItem('Inquirer', inquiry['inquirer']),
              _buildDetailItem('Event Date', inquiry['date']),
              _buildDetailItem('Guest Count', inquiry['capacity']),
              const SizedBox(height: 16),
              const Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(inquiry['requirements'] ?? 'No special requirements specified.'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (isPending) ...[
            TextButton(
              onPressed: () {
                context.read<InquiriesBloc>().add(UpdateInquiryStatus(inquiry['id'], 'declined'));
                Navigator.pop(ctx);
              },
              child: const Text('Decline', style: TextStyle(color: AppColors.algerianRed)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<InquiriesBloc>().add(UpdateInquiryStatus(inquiry['id'], 'confirmed'));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dzGreen, foregroundColor: Colors.white),
              child: const Text('Confirm Booking'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
