abstract class InquiriesEvent {}

class LoadInquiries extends InquiriesEvent {}

class UpdateInquiryStatus extends InquiriesEvent {
  final String id;
  final String status;
  UpdateInquiryStatus(this.id, this.status);
}
