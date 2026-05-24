abstract class RewardsEvent {}

class LoadRewards extends RewardsEvent {}

class AddReward extends RewardsEvent {
  final Map<String, dynamic> reward;
  AddReward(this.reward);
}

class UpdateReward extends RewardsEvent {
  final String id;
  final Map<String, dynamic> reward;
  UpdateReward(this.id, this.reward);
}

class UpdateRewardCost extends RewardsEvent {
  final String id;
  final int newCost;
  UpdateRewardCost(this.id, this.newCost);
}

class DeleteReward extends RewardsEvent {
  final String id;
  DeleteReward(this.id);
}
