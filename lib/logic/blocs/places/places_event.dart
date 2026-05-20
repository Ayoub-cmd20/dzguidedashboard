abstract class PlacesEvent {}

class LoadPlaces extends PlacesEvent {}

class AddPlace extends PlacesEvent {
  final Map<String, dynamic> place;
  AddPlace(this.place);
}

class UpdatePlace extends PlacesEvent {
  final String id;
  final Map<String, dynamic> place;
  UpdatePlace(this.id, this.place);
}

class UpdatePlaceStatus extends PlacesEvent {
  final String id;
  final bool isLive;
  UpdatePlaceStatus(this.id, this.isLive);
}

class DeletePlace extends PlacesEvent {
  final String id;
  DeletePlace(this.id);
}
