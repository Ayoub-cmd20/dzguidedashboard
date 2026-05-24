abstract class EventsEvent {}

class LoadEvents extends EventsEvent {}

class AddEvent extends EventsEvent {
  final Map<String, dynamic> event;
  AddEvent(this.event);
}

class UpdateEvent extends EventsEvent {
  final String id;
  final Map<String, dynamic> event;
  UpdateEvent(this.id, this.event);
}

class DeleteEvent extends EventsEvent {
  final String id;
  DeleteEvent(this.id);
}
