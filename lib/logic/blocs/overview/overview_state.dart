abstract class OverviewState {}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  final List<Map<String, dynamic>> stats;
  final List<Map<String, dynamic>> recentInquiries;

  OverviewLoaded({required this.stats, required this.recentInquiries});
}

class OverviewError extends OverviewState {
  final String message;
  OverviewError(this.message);
}
