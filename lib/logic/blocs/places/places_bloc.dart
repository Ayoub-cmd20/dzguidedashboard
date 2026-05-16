import 'package:flutter_bloc/flutter_bloc.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  PlacesBloc() : super(PlacesInitial()) {
    on<LoadPlaces>((event, emit) async {
      emit(PlacesLoading());
      try {
        // Simulating Appwrite fetch
        await Future.delayed(const Duration(milliseconds: 800));
        final mockPlaces = [
          {
            'id': '1',
            'title': 'Casbah of Algiers',
            'category': 'Historical',
            'rating': 4.8,
            'status': 'Live',
            'location': 'Algiers',
            'image': 'https://images.unsplash.com/photo-1523438885200-e635ba2c371e?auto=format&fit=crop&w=100&q=80',
          },
          {
            'id': '2',
            'title': 'Tassili n\'Ajjer',
            'category': 'Nature',
            'rating': 4.9,
            'status': 'Live',
            'location': 'Illizi',
            'image': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=100&q=80',
          },
          {
            'id': '3',
            'title': 'Santa Cruz Fort',
            'category': 'Historical',
            'rating': 4.7,
            'status': 'Hidden',
            'location': 'Oran',
            'image': 'https://images.unsplash.com/photo-1565552607561-75294aa52bb5?auto=format&fit=crop&w=100&q=80',
          },
          {
            'id': '4',
            'title': 'Constantine Bridges',
            'category': 'Nature',
            'rating': 4.6,
            'status': 'Live',
            'location': 'Constantine',
            'image': 'https://images.unsplash.com/photo-1449034446853-66c86144b0ad?auto=format&fit=crop&w=100&q=80',
          },
        ];
        emit(PlacesLoaded(mockPlaces));
      } catch (e) {
        emit(PlacesError('Failed to load places'));
      }
    });

    on<UpdatePlaceStatus>((event, emit) {
      if (state is PlacesLoaded) {
        final currentPlaces = (state as PlacesLoaded).places;
        final updatedPlaces = currentPlaces.map((p) {
          if (p['id'] == event.id) {
            return {...p, 'status': event.isLive ? 'Live' : 'Hidden'};
          }
          return p;
        }).toList();
        emit(PlacesLoaded(updatedPlaces));
      }
    });

    on<DeletePlace>((event, emit) {
      if (state is PlacesLoaded) {
        final currentPlaces = (state as PlacesLoaded).places;
        final updatedPlaces = currentPlaces.where((p) => p['id'] != event.id).toList();
        emit(PlacesLoaded(updatedPlaces));
      }
    });
  }
}
