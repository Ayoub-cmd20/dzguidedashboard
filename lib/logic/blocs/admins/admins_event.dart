abstract class AdminsEvent {}

class LoadAdmins extends AdminsEvent {}

class AddAdmin extends AdminsEvent {
  final Map<String, dynamic> admin;
  AddAdmin(this.admin);
}

class UpdateAdminRole extends AdminsEvent {
  final String userId;
  final String newRole;
  UpdateAdminRole(this.userId, this.newRole);
}

class RemoveAdmin extends AdminsEvent {
  final String userId;
  RemoveAdmin(this.userId);
}
