import 'package:flutter_bloc/flutter_bloc.dart';
import 'rewards_event.dart';
import 'rewards_state.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  RewardsBloc() : super(RewardsInitial()) {
    on<LoadRewards>((event, emit) async {
      emit(RewardsLoading());
      try {
        await Future.delayed(const Duration(milliseconds: 800));
        final mockRewards = [
          {
            'id': 'r1',
            'title': 'Algiers Palace Suite',
            'description': 'One night stay in the presidential suite with panoramic views.',
            'cost': 15000,
            'expiry': 'Dec 2024',
            'category': 'Luxury Stay',
            'image': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=100&q=80',
          },
          {
            'id': 'r2',
            'title': 'Sahara Desert Tour',
            'description': '3-day guided luxury tour through the Tassili n\'Ajjer dunes.',
            'cost': 25000,
            'expiry': 'Nov 2024',
            'category': 'Adventure',
            'image': 'https://images.unsplash.com/photo-1509023464722-18d996393ca8?auto=format&fit=crop&w=100&q=80',
          },
          {
            'id': 'r3',
            'title': 'Constantine Gourmet Dining',
            'description': 'Fine dining experience for two at the historic bridges restaurant.',
            'cost': 5000,
            'expiry': 'Oct 2024',
            'category': 'Dining',
            'image': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=100&q=80',
          },
        ];
        emit(RewardsLoaded(mockRewards));
      } catch (e) {
        emit(RewardsError('Failed to load rewards'));
      }
    });

    on<UpdateRewardCost>((event, emit) {
      if (state is RewardsLoaded) {
        final current = (state as RewardsLoaded).rewards;
        final updated = current.map((r) {
          if (r['id'] == event.id) {
            return {...r, 'cost': event.newCost};
          }
          return r;
        }).toList();
        emit(RewardsLoaded(updated));
      }
    });
  }
}
