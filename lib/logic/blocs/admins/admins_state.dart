abstract class AdminsState {}

class AdminsInitial extends AdminsState {}

class AdminsLoading extends AdminsState {}

class AdminsLoaded extends AdminsState {
  final List<Map<String, dynamic>> admins;
  AdminsLoaded(this.admins);
}

class AdminsError extends AdminsState {
  final String message;
  AdminsError(this.message);
}
