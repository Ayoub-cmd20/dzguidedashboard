import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'overview_event.dart';
import 'overview_state.dart';
import 'package:intl/intl.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  final AppwriteService _appwrite = AppwriteService();

  OverviewBloc() : super(OverviewInitial()) {
    on<LoadOverviewData>((event, emit) async {
      emit(OverviewLoading());
      try {
        // Use optimized single method call
        final overviewData = await _appwrite.getOverviewData();

        // Check if analytics data indicates empty collection
        final analyticsData =
            overviewData['analyticsData'] as List<Map<String, dynamic>>;
        final bool hasEmptyAnalytics =
            analyticsData.isNotEmpty &&
            analyticsData.first['month'] == 'No Data' &&
            analyticsData.first['message'] != null;

        // Format dates for display
        final formattedInquiries = (overviewData['recentInquiries'] as List)
            .map((inquiry) {
              final dateStr = (inquiry['date'] ?? '') as String;
              String formattedDate = dateStr;
              try {
                if (dateStr.isNotEmpty) {
                  formattedDate = DateFormat(
                    'MMM dd, yyyy',
                  ).format(DateTime.parse(dateStr));
                }
              } catch (e) {
                // Keep original format if parsing fails
              }

              return {
                ...inquiry as Map<String, dynamic>,
                'date': formattedDate,
              };
            })
            .toList();

        emit(
          OverviewLoaded(
            stats: overviewData['stats'],
            recentInquiries: formattedInquiries,
            analyticsData: analyticsData,
            hasEmptyAnalytics: hasEmptyAnalytics,
          ),
        );
      } catch (e) {
        // Check for AppwriteException with string error codes
        if (e is AppwriteException &&
            (e.code == '401' || e.code == '404' || e.code == 'unauthorized')) {
          // Provide Mock Data for unauthorized/offline development
          final stats = [
            {
              'title': 'Active Destinations',
              'value': '42',
              'trend': '+5 new',
              'icon': 'mapPin',
            },
            {
              'title': 'Pending Inquiries',
              'value': '12',
              'trend': 'Action Needed',
              'icon': 'clock',
            },
            {
              'title': 'Global Travelers',
              'value': '1,284',
              'trend': '+12%',
              'icon': 'users',
            },
            {
              'title': 'Available Rewards',
              'value': '15',
              'trend': 'Active',
              'icon': 'gift',
            },
          ];
          final inquiries = [
            {
              'venue': 'Royal Saharan Suite',
              'inquirer': 'John Doe',
              'date': 'May 20, 2024',
              'capacity': '4 Guests',
              'status': 'Pending',
            },
            {
              'venue': 'Casbah Heritage Tour',
              'inquirer': 'Sarah Smith',
              'date': 'May 22, 2024',
              'capacity': '2 Guests',
              'status': 'Confirmed',
            },
            {
              'venue': 'Oran Coastal Resort',
              'inquirer': 'Ahmed K.',
              'date': 'June 05, 2024',
              'capacity': '5 Guests',
              'status': 'Pending',
            },
          ];
          // Generate mock analytics data for the error case
          final List<Map<String, dynamic>> mockAnalytics = [];
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          for (int i = 0; i < 12; i++) {
            mockAnalytics.add({
              'month': months[i],
              'year': DateTime.now().year,
              'luxuryBookings': 45 + (i * 5) + (i % 3 * 10),
              'eliteActivity': 20 + (i * 4) + (i % 2 * 8),
            });
          }

          emit(
            OverviewLoaded(
              stats: stats,
              recentInquiries: inquiries,
              analyticsData: mockAnalytics,
            ),
          );
        } else {
          emit(OverviewError('Failed to load dashboard: ${e.toString()}'));
        }
      }
    });
  }
}
