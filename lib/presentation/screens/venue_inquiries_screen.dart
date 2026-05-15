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
    return BlocBuilder<InquiriesBloc, InquiriesState>(
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
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
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
      return Center(child: Text(state.message));
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
        'Action',
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
    bool isConfirmed = inquiry['status'] == 'Confirmed';
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
              color: (isConfirmed ? AppColors.dzGreen : AppColors.elitePurple).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              inquiry['status'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isConfirmed ? AppColors.dzGreen : AppColors.elitePurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(LucideIcons.eye, size: 20, color: AppColors.dzGreen),
            onPressed: () => _showInquiryDetails(context, inquiry),
          ),
        ),
      ],
    );
  }

  void _showInquiryDetails(BuildContext context, Map<String, dynamic> inquiry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(LucideIcons.calendarCheck, color: AppColors.dzGreen),
            const SizedBox(width: 12),
            const Text('Inquiry Details'),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(inquiry['requirements']),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          if (inquiry['status'] == 'Pending')
            ElevatedButton(
              onPressed: () {
                context.read<InquiriesBloc>().add(UpdateInquiryStatus(inquiry['id'], 'Confirmed'));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dzGreen, foregroundColor: Colors.white),
              child: const Text('Confirm Booking'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
