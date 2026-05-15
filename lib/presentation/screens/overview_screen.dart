import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/blocs/overview/overview_bloc.dart';
import '../../logic/blocs/overview/overview_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/engagement_chart.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OverviewBloc, OverviewState>(
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
    );
  }

  Widget _buildLoadingState() {
    return Padding(
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
          // Engagement Chart
          const EngagementChart(),
          const SizedBox(height: 32),
          // Inquiry Management Table
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
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1000,
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.5),
                        4: FlexColumnWidth(1.5),
                        5: FlexColumnWidth(1),
                      },
                      children: [
                        _buildHeaderRow(),
                        ...state.recentInquiries.map((inquiry) => _buildDataRow(
                              inquiry['venue'],
                              inquiry['inquirer'],
                              inquiry['date'],
                              inquiry['capacity'],
                              inquiry['status'],
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
    String venue,
    String inquirer,
    String date,
    String capacity,
    String status,
  ) {
    bool isConfirmed = status == 'Confirmed';
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(venue, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(inquirer),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(date),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(capacity),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: UnconstrainedBox(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isConfirmed ? AppColors.dzGreen : AppColors.elitePurple).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isConfirmed ? AppColors.dzGreen : AppColors.elitePurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: IconButton(
            icon: const Icon(LucideIcons.moreHorizontal, size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
