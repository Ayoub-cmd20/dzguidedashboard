abstract class UsersEvent {}

class LoadUsers extends UsersEvent {}

class UpdateUserTier extends UsersEvent {
  final String userId;
  final String tier;
  UpdateUserTier(this.userId, this.tier);
}
