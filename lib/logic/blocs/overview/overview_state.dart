abstract class OverviewState {}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  final List<Map<String, dynamic>> stats;
  final List<Map<String, dynamic>> recentInquiries;
  final List<Map<String, dynamic>> analyticsData;
  final bool hasEmptyAnalytics;

  OverviewLoaded({
    required this.stats,
    required this.recentInquiries,
    required this.analyticsData,
    this.hasEmptyAnalytics = false,
  });
}

class OverviewError extends OverviewState {
  final String message;
  OverviewError(this.message);
}
