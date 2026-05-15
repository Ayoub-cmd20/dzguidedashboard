abstract class InquiriesState {}

class InquiriesInitial extends InquiriesState {}

class InquiriesLoading extends InquiriesState {}

class InquiriesLoaded extends InquiriesState {
  final List<Map<String, dynamic>> inquiries;
  InquiriesLoaded(this.inquiries);
}

class InquiriesError extends InquiriesState {
  final String message;
  InquiriesError(this.message);
}
