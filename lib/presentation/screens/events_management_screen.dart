import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../core/theme/app_colors.dart';
import '../../core/services/appwrite_service.dart';
import '../../logic/blocs/events/events_bloc.dart';
import '../../logic/blocs/events/events_event.dart';
import '../../logic/blocs/events/events_state.dart';
import '../widgets/loading_shimmer.dart';

class EventsManagementScreen extends StatefulWidget {
  const EventsManagementScreen({super.key});

  @override
  State<EventsManagementScreen> createState() => _EventsManagementScreenState();
}

class _EventsManagementScreenState extends State<EventsManagementScreen> {
  String _searchQuery = '';
  
  // For web file picker support
  Uint8List? _webFileBytes;
  String? _webFileName;
  
  // For form state
  File? _formSelectedImage;
  String? _formImageUrl;
  bool _formIsUploading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          Expanded(
            child: BlocBuilder<EventsBloc, EventsState>(
              builder: (context, state) {
                if (state is EventsLoading) {
                  return const LoadingShimmer(width: double.infinity, height: 600, borderRadius: 25);
                } else if (state is EventsLoaded) {
                  final filteredEvents = state.events.where((e) =>
                    e['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                  return _buildEventsList(context, filteredEvents);
                } else if (state is EventsError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Events Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text('Manage cultural festivals and local events across Algeria', 
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showEventForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dzGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('Add New Event'),
        ),
      ],
    );
  }

  Widget _buildEventsList(BuildContext context, List<Map<String, dynamic>> events) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _buildTableHeader(),
                  ...events.map((event) => _buildTableRow(context, event)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: ['Image', 'Event Title', 'Location', 'Date', 'Status', 'Actions'].map((text) => 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        )
      ).toList(),
    );
  }

  TableRow _buildTableRow(BuildContext context, Map<String, dynamic> event) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(event['imageUrl'], width: 50, height: 50, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade100, child: const Icon(LucideIcons.image, size: 20)),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.w600))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(event['location'])),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(event['date'])),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (event['status'] == 'Upcoming' ? AppColors.dzGreen : Colors.grey).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(event['status'], style: TextStyle(color: event['status'] == 'Upcoming' ? AppColors.dzGreen : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.edit3, size: 18, color: AppColors.dzGreen),
                onPressed: () => _showEventForm(context, event: event),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.algerianRed),
                onPressed: () => _showDeleteConfirmation(context, event),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEventForm(BuildContext context, {Map<String, dynamic>? event}) {
    _formSelectedImage = null;
    _formImageUrl = event?['imageUrl'];
    _formIsUploading = false;
    _webFileBytes = null;
    _webFileName = null;
    
    final titleController = TextEditingController(text: event?['title']);
    final locationController = TextEditingController(text: event?['location']);
    final dateController = TextEditingController(text: event?['date']);
    String selectedCat = event?['category'] ?? 'Culture';
    String selectedStatus = event?['status'] ?? 'Upcoming';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(event == null ? 'Add New Event' : 'Edit Event'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('Event Title', controller: titleController),
                  const SizedBox(height: 16),
                  _buildTextField('Location (City, Region)', controller: locationController),
                  const SizedBox(height: 16),
                  _buildTextField('Date (e.g. July 25, 2024)', controller: dateController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Category'),
                          initialValue: selectedCat,
                          items: ['Music', 'Sports', 'Culture', 'Festival', 'Other']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => selectedCat = v!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Status'),
                          initialValue: selectedStatus,
                          items: ['Upcoming', 'Completed', 'Canceled']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => selectedStatus = v!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildImagePicker(context, event, setState),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: _formIsUploading ? null : () async {
                if (_webFileBytes != null || _formSelectedImage != null) {
                  setState(() => _formIsUploading = true);
                  try {
                    final appwrite = AppwriteService();
                    String fileId;
                    if (_webFileBytes != null) {
                      fileId = await appwrite.uploadImageBytes(_webFileBytes!, _webFileName ?? 'event.jpg');
                    } else {
                      fileId = await appwrite.uploadImage(_formSelectedImage!, 'event_${DateTime.now().millisecondsSinceEpoch}');
                    }
                    _formImageUrl = appwrite.getImageUrl(AppwriteService.placesBucket, fileId);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
                    setState(() => _formIsUploading = false);
                    return;
                  }
                  setState(() => _formIsUploading = false);
                }

                final eventData = {
                  'title': titleController.text,
                  'location': locationController.text,
                  'date': dateController.text,
                  'category': selectedCat,
                  'status': selectedStatus,
                  'imageUrl': _formImageUrl ?? '',
                };

                if (event != null) {
                  context.read<EventsBloc>().add(UpdateEvent(event['id'], eventData));
                } else {
                  context.read<EventsBloc>().add(AddEvent(eventData));
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dzGreen, foregroundColor: Colors.white),
              child: Text(event == null ? 'Create' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<EventsBloc>().add(DeleteEvent(event['id']));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.algerianRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _buildImagePicker(BuildContext context, Map<String, dynamic>? event, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event Image', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _formIsUploading ? null : () async {
            final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
            if (result != null) {
              setState(() {
                if (result.files.single.bytes != null) {
                  _webFileBytes = result.files.single.bytes;
                  _webFileName = result.files.single.name;
                  _formSelectedImage = null;
                } else {
                  _formSelectedImage = File(result.files.single.path!);
                  _webFileBytes = null;
                }
              });
            }
          },
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Stack(
              children: [
                Center(
                  child: _formSelectedImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_formSelectedImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover))
                      : _webFileBytes != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(_webFileBytes!, width: double.infinity, height: double.infinity, fit: BoxFit.cover))
                          : _formImageUrl != null && _formImageUrl!.isNotEmpty
                              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_formImageUrl!, width: double.infinity, height: double.infinity, fit: BoxFit.cover))
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Icon(LucideIcons.upload, color: Colors.grey), SizedBox(height: 4), Text('Click to upload image', style: TextStyle(color: Colors.grey, fontSize: 12))],
                                ),
                ),
                if (_formIsUploading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
