abstract class RewardsEvent {}

class LoadRewards extends RewardsEvent {}

class UpdateRewardCost extends RewardsEvent {
  final String id;
  final int newCost;
  UpdateRewardCost(this.id, this.newCost);
}

class DeleteReward extends RewardsEvent {
  final String id;
  DeleteReward(this.id);
}
