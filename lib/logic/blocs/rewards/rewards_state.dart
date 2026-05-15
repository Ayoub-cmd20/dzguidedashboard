abstract class RewardsState {}

class RewardsInitial extends RewardsState {}

class RewardsLoading extends RewardsState {}

class RewardsLoaded extends RewardsState {
  final List<Map<String, dynamic>> rewards;
  RewardsLoaded(this.rewards);
}

class RewardsError extends RewardsState {
  final String message;
  RewardsError(this.message);
}
