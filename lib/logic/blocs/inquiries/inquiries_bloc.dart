import 'package:flutter_bloc/flutter_bloc.dart';
import 'inquiries_event.dart';
import 'inquiries_state.dart';

class InquiriesBloc extends Bloc<InquiriesEvent, InquiriesState> {
  InquiriesBloc() : super(InquiriesInitial()) {
    on<LoadInquiries>((event, emit) async {
      emit(InquiriesLoading());
      try {
        // Simulating fetch from Appwrite
        await Future.delayed(const Duration(milliseconds: 800));
        final mockInquiries = [
          {
            'id': '101',
            'venue': 'Sheraton Algiers',
            'inquirer': 'Ahmed Benali',
            'email': 'ahmed.b@email.com',
            'date': 'May 15, 2024',
            'capacity': '250 Guests',
            'status': 'Pending',
            'requirements': 'Wedding event with traditional catering and stage setup.',
          },
          {
            'id': '102',
            'venue': 'Hotel El Aurassi',
            'inquirer': 'Sara Mansouri',
            'email': 'sara.m@email.com',
            'date': 'May 18, 2024',
            'capacity': '120 Guests',
            'status': 'Confirmed',
            'requirements': 'Corporate seminar with AV equipment and coffee breaks.',
          },
          {
            'id': '103',
            'venue': 'Sofitel Hamma Garden',
            'inquirer': 'Karim Zaid',
            'email': 'k.zaid@email.com',
            'date': 'June 02, 2024',
            'capacity': '50 Guests',
            'status': 'Pending',
            'requirements': 'Private birthday party, outdoor terrace preferred.',
          },
          {
            'id': '104',
            'venue': 'Constantine Marriott',
            'inquirer': 'Yasmine Drif',
            'email': 'y.drif@email.com',
            'date': 'June 10, 2024',
            'capacity': '300 Guests',
            'status': 'Confirmed',
            'requirements': 'International conference, needs translation booths.',
          },
        ];
        emit(InquiriesLoaded(mockInquiries));
      } catch (e) {
        emit(InquiriesError('Failed to load inquiries'));
      }
    });

    on<UpdateInquiryStatus>((event, emit) {
      if (state is InquiriesLoaded) {
        final currentInquiries = (state as InquiriesLoaded).inquiries;
        final updatedInquiries = currentInquiries.map((inq) {
          if (inq['id'] == event.id) {
            return {...inq, 'status': event.status};
          }
          return inq;
        }).toList();
        emit(InquiriesLoaded(updatedInquiries));
      }
    });
  }
}
