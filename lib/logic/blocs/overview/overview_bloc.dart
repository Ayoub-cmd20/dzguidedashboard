import 'package:flutter_bloc/flutter_bloc.dart';
import 'overview_event.dart';
import 'overview_state.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  OverviewBloc() : super(OverviewInitial()) {
    on<LoadOverviewData>((event, emit) async {
      emit(OverviewLoading());
      try {
        // Simulating API call to Appwrite
        await Future.delayed(const Duration(seconds: 1));
        
        final stats = [
          {'title': 'Total Travelers', 'value': '12,840', 'trend': '+12%', 'icon': 'users'},
          {'title': 'Pending Inquiries', 'value': '48', 'trend': '+5%', 'icon': 'clock'},
          {'title': 'Points Redeemed', 'value': '850K', 'trend': '+18%', 'icon': 'gift'},
          {'title': 'Active Destinations', 'value': '142', 'trend': '+3%', 'icon': 'mapPin'},
        ];

        final inquiries = [
          {
            'venue': 'Sheraton Algiers',
            'inquirer': 'Ahmed Benali',
            'date': 'May 15, 2024',
            'capacity': '250 Guests',
            'status': 'Pending',
          },
          {
            'venue': 'Hotel El Aurassi',
            'inquirer': 'Sara Mansouri',
            'date': 'May 18, 2024',
            'capacity': '120 Guests',
            'status': 'Confirmed',
          },
          {
            'venue': 'Sofitel Hamma Garden',
            'inquirer': 'Karim Zaid',
            'date': 'June 02, 2024',
            'capacity': '50 Guests',
            'status': 'Pending',
          },
        ];

        emit(OverviewLoaded(stats: stats, recentInquiries: inquiries));
      } catch (e) {
        emit(OverviewError('Failed to load dashboard data'));
      }
    });
  }
}
