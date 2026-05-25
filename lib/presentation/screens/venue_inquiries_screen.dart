import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/blocs/inquiries/inquiries_bloc.dart';
import '../../logic/blocs/inquiries/inquiries_event.dart';
import '../../logic/blocs/inquiries/inquiries_state.dart';
import '../widgets/loading_shimmer.dart';

class VenueInquiriesScreen extends StatelessWidget {
  const VenueInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InquiriesBloc, InquiriesState>(
      listener: (context, state) {
        if (state is InquiriesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.algerianRed,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
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
          'Venue Inquiries',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'Review and manage event booking requests for luxury Algerian venues',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, InquiriesState state) {
    if (state is InquiriesLoading) {
      return const LoadingShimmer(width: double.infinity, height: 600, borderRadius: 25);
    } else if (state is InquiriesLoaded) {
      if (state.inquiries.isEmpty) {
        return const Center(
          child: Text('No inquiries found.'),
        );
      }
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
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1.5),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _buildTableHeader(),
                  ...state.inquiries.map((inquiry) => _buildTableRow(context, inquiry)),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (state is InquiriesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, color: AppColors.algerianRed, size: 48),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<InquiriesBloc>().add(LoadInquiries()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        'Venue',
        'Inquirer',
        'Event Date',
        'Capacity',
        'Status',
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

  TableRow _buildTableRow(BuildContext context, Map<String, dynamic> inquiry) {
    final status = inquiry['status'].toString().toLowerCase();
    final isConfirmed = status == 'confirmed';
    final isPending = status == 'pending';
    final isDeclined = status == 'declined' || status == 'rejected';

    Color statusColor = AppColors.elitePurple;
    if (isConfirmed) statusColor = AppColors.dzGreen;
    if (isDeclined) statusColor = AppColors.algerianRed;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(inquiry['venue'], style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(inquiry['inquirer']),
              Text(inquiry['email'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(inquiry['date']),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(inquiry['capacity']),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              inquiry['status'][0].toUpperCase() + inquiry['status'].substring(1),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.eye, size: 20, color: AppColors.textSecondary),
                onPressed: () => _showInquiryDetails(context, inquiry),
                tooltip: 'View Details',
              ),
              if (isPending) ...[
                IconButton(
                  icon: const Icon(LucideIcons.checkCircle, size: 20, color: AppColors.dzGreen),
                  onPressed: () => _showConfirmationDialog(context, inquiry, 'confirmed'),
                  tooltip: 'Confirm',
                ),
                IconButton(
                  icon: const Icon(LucideIcons.xCircle, size: 20, color: AppColors.algerianRed),
                  onPressed: () => _showConfirmationDialog(context, inquiry, 'declined'),
                  tooltip: 'Decline',
                ),
              ],
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 20, color: AppColors.algerianRed),
                onPressed: () => _showDeleteDialog(context, inquiry),
                tooltip: 'Delete',
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
        content: Text('Are you sure you want to delete the inquiry from "${inquiry['inquirer']}"? This action cannot be undone.'),
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
