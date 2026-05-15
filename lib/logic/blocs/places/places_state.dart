abstract class PlacesState {}

class PlacesInitial extends PlacesState {}

class PlacesLoading extends PlacesState {}

class PlacesLoaded extends PlacesState {
  final List<Map<String, dynamic>> places;
  PlacesLoaded(this.places);
}

class PlacesError extends PlacesState {
  final String message;
  PlacesError(this.message);
}
