import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/blocs/overview/overview_bloc.dart';
import '../../logic/blocs/overview/overview_state.dart';

class EngagementChart extends StatelessWidget {
  const EngagementChart({super.key});

  // Convert month abbreviation to month index (0-11)
  int _getMonthIndex(String month) {
    const months = {
      'Jan': 0,
      'Feb': 1,
      'Mar': 2,
      'Apr': 3,
      'May': 4,
      'Jun': 5,
      'Jul': 6,
      'Aug': 7,
      'Sep': 8,
      'Oct': 9,
      'Nov': 10,
      'Dec': 11,
    };
    return months[month] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OverviewBloc, OverviewState>(
      builder: (context, state) {
        List<double> luxuryBookings = [];
        List<double> eliteActivity = [];
        List<Map<String, dynamic>> monthLabels = [];

        if (state is OverviewLoaded && state.analyticsData.isNotEmpty) {
          // Sort analytics data by year and month order
          final sortedData = List<Map<String, dynamic>>.from(
            state.analyticsData,
          );
          sortedData.sort((a, b) {
            final yearDiff = (a['year'] ?? 0).compareTo(b['year'] ?? 0);
            if (yearDiff != 0) return yearDiff;
            final monthAIndex = _getMonthIndex(a['month'] ?? '');
            final monthBIndex = _getMonthIndex(b['month'] ?? '');
            return monthAIndex.compareTo(monthBIndex);
          });

          // Get last 6 months from sorted data
          final last6Months = sortedData.length > 6
              ? sortedData.sublist(sortedData.length - 6)
              : sortedData;

          for (var data in last6Months) {
            luxuryBookings.add((data['luxuryBookings'] ?? 0).toDouble());
            eliteActivity.add((data['eliteActivity'] ?? 0).toDouble());
            monthLabels.add({
              'month': data['month'] ?? '',
              'year': data['year'] ?? 0,
            });
          }
        } else {
          // Use mock data if no real data available (last 6 months)
          luxuryBookings = [45, 52, 48, 75, 82, 78];
          eliteActivity = [20, 25, 30, 45, 50, 42];
          monthLabels = [
            {'month': 'Dec', 'year': 2025},
            {'month': 'Jan', 'year': 2026},
            {'month': 'Feb', 'year': 2026},
            {'month': 'Mar', 'year': 2026},
            {'month': 'Apr', 'year': 2026},
            {'month': 'May', 'year': 2026},
          ];
        }

        return _buildChart(luxuryBookings, eliteActivity, monthLabels);
      },
    );
  }

  Widget _buildChart(
    List<double> luxuryBookings,
    List<double> eliteActivity,
    List<Map<String, dynamic>> monthLabels,
  ) {
    // Premium theme colors
    const dzGreen = Color(0xFF006633);
    const algerianRed = Color(0xFFD2143A);
    const gridColor = Color(0xFFF1F3F4);

    final numMonths = luxuryBookings.length > 0 ? luxuryBookings.length - 1 : 5;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Traveler Activity Metrics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Last 6 months booking engagement and luxury tier activity',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              _buildLegend(dzGreen, algerianRed),
            ],
          ),
          const SizedBox(height: 40),
          AspectRatio(
            aspectRatio: 2.2,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: gridColor, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) =>
                          _bottomTitleWidgets(value, meta, monthLabels),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.textPrimary.withValues(
                      alpha: 0.9,
                    ),
                    tooltipRoundedRadius: 12,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        final monthIndex = flSpot.x.toInt();
                        final monthData = monthIndex < monthLabels.length
                            ? monthLabels[monthIndex]
                            : null;
                        final monthName = monthData?['month'] ?? '';
                        return LineTooltipItem(
                          '$monthName \n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${flSpot.y.toInt()} Bookings',
                              style: TextStyle(
                                color: flSpot.barIndex == 0
                                    ? dzGreen
                                    : algerianRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                minX: 0,
                maxX: numMonths.toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  _generateLineData(dzGreen, luxuryBookings, true),
                  _generateLineData(algerianRed, eliteActivity, false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  LineChartBarData _generateLineData(
    Color color,
    List<double> data,
    bool isMain,
  ) {
    return LineChartBarData(
      spots: data
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: isMain ? 4 : 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: isMain ? 4 : 3,
          color: Colors.white,
          strokeWidth: 2,
          strokeColor: color,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: isMain ? 0.15 : 0.05),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(
    double value,
    TitleMeta meta,
    List<Map<String, dynamic>> monthLabels,
  ) {
    const style = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final monthIndex = value.toInt();
    final monthName = monthIndex < monthLabels.length
        ? monthLabels[monthIndex]['month'] ?? ''
        : '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 12,
      child: Text(monthName, style: style),
    );
  }

  Widget _buildLegend(Color primary, Color secondary) {
    return Row(
      children: [
        _legendItem('Luxury Bookings', primary),
        const SizedBox(width: 20),
        _legendItem('Elite Activity', secondary),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
