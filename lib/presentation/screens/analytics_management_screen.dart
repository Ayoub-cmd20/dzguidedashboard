import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/appwrite_service.dart';
import '../../logic/blocs/overview/overview_bloc.dart';
import '../../logic/blocs/overview/overview_event.dart';
import '../widgets/loading_shimmer.dart';

class AnalyticsManagementScreen extends StatefulWidget {
  const AnalyticsManagementScreen({super.key});

  @override
  State<AnalyticsManagementScreen> createState() =>
      _AnalyticsManagementScreenState();
}

class _AnalyticsManagementScreenState extends State<AnalyticsManagementScreen> {
  final AppwriteService _appwrite = AppwriteService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _analyticsData = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _appwrite.getAnalyticsData();
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load analytics: $e')));
    }
  }

  void _showAnalyticsForm({Map<String, dynamic>? analytics}) {
    final monthController = TextEditingController(
      text: analytics?['month'] ?? '',
    );
    final yearController = TextEditingController(
      text: analytics?['year']?.toString() ?? DateTime.now().year.toString(),
    );
    final luxuryController = TextEditingController(
      text: analytics?['luxuryBookings']?.toString() ?? '0',
    );
    final eliteController = TextEditingController(
      text: analytics?['eliteActivity']?.toString() ?? '0',
    );
    final usersController = TextEditingController(
      text: analytics?['totalUsers']?.toString() ?? '0',
    );
    final inquiriesController = TextEditingController(
      text: analytics?['newInquiries']?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          analytics == null ? 'Add Analytics Data' : 'Edit Analytics Data',
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Month'),
                        value: monthController.text.isNotEmpty
                            ? monthController.text
                            : null,
                        items:
                            const [
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun',
                                  'Jul',
                                  'Aug',
                                  'Sep',
                                  'Oct',
                                  'Nov',
                                  'Dec',
                                ]
                                .map(
                                  (month) => DropdownMenuItem(
                                    value: month,
                                    child: Text(month),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            monthController.text = value ?? '',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: yearController,
                        decoration: _inputDecoration('Year'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Luxury Bookings',
                  controller: luxuryController,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Elite Activity',
                  controller: eliteController,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Total Users',
                  controller: usersController,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'New Inquiries',
                  controller: inquiriesController,
                  isNumber: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _appwrite.updateAnalyticsData(
                  month: monthController.text,
                  year: int.parse(yearController.text),
                  luxuryBookings: int.parse(luxuryController.text),
                  eliteActivity: int.parse(eliteController.text),
                  totalUsers: int.parse(usersController.text),
                  newInquiries: int.parse(inquiriesController.text),
                );
                Navigator.pop(ctx);
                _loadAnalyticsData();
                context.read<OverviewBloc>().add(LoadOverviewData());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Analytics data updated successfully'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update analytics: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dzGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          Expanded(
            child: _isLoading
                ? const LoadingShimmer(
                    width: double.infinity,
                    height: 600,
                    borderRadius: 25,
                  )
                : _buildAnalyticsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics Management',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage traveler metrics and activity data',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAnalyticsForm(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dzGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('Add Data'),
        ),
      ],
    );
  }

  Widget _buildAnalyticsList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        padding: const EdgeInsets.all(24),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _buildTableHeader(),
            ..._analyticsData.map((data) => _buildTableRow(data)),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children:
          [
                'Month',
                'Year',
                'Luxury Bookings',
                'Elite Activity',
                'Total Users',
                'Actions',
              ]
              .map(
                (text) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> data) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(data['month'] ?? ''),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(data['year']?.toString() ?? ''),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(data['luxuryBookings']?.toString() ?? '0'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(data['eliteActivity']?.toString() ?? '0'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(data['totalUsers']?.toString() ?? '0'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(
              LucideIcons.edit3,
              size: 18,
              color: AppColors.dzGreen,
            ),
            onPressed: () => _showAnalyticsForm(analytics: data),
          ),
        ),
      ],
    );
  }
}
