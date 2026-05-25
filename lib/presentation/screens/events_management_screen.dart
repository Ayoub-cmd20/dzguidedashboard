import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/appwrite_service.dart';
import '../../logic/blocs/events/events_bloc.dart';
import '../../logic/blocs/events/events_event.dart';
import '../../logic/blocs/events/events_state.dart';
import '../../logic/blocs/places/places_bloc.dart';
import '../../logic/blocs/places/places_state.dart';
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
                  return const LoadingShimmer(
                    width: double.infinity,
                    height: 600,
                    borderRadius: 25,
                  );
                } else if (state is EventsLoaded) {
                  final filteredEvents = state.events
                      .where(
                        (e) => e['title'].toString().toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
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
            const Text(
              'Events Management',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage cultural festivals and local events across Algeria',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showEventForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dzGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('Add New Event'),
        ),
      ],
    );
  }

  Widget _buildEventsList(
    BuildContext context,
    List<Map<String, dynamic>> events,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
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
      children:
          ['Image', 'Event Title', 'Date', 'Category', 'Place ID', 'Actions']
              .map(
                (text) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  TableRow _buildTableRow(BuildContext context, Map<String, dynamic> event) {
    final dateStr = event['date'] is String && event['date'].toString().length >= 10
        ? event['date'].substring(0, 10) // Extract date part from ISO string
        : event['date'].toString();

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              event['imageUrl'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade100,
                child: const Icon(LucideIcons.image, size: 20),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            event['title'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(dateStr)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.dzGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              event['category'],
              style: const TextStyle(
                color: AppColors.dzGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(event['placeId'], style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  LucideIcons.edit3,
                  size: 18,
                  color: AppColors.dzGreen,
                ),
                onPressed: () => _showEventForm(context, event: event),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: AppColors.algerianRed,
                ),
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
    final descriptionController = TextEditingController(
      text: event?['description'],
    );
    
    DateTime selectedDate = event?['date'] != null
        ? DateTime.parse(event!['date'])
        : DateTime.now();

    String selectedCategory = event?['category'] ?? 'Culture';
    String selectedPlaceId = event?['placeId'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(event == null ? 'Add New Event' : 'Edit Event'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('Event Title', controller: titleController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Description',
                    controller: descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildPlacesDropdown(setState, selectedPlaceId, (placeId) {
                    setState(() => selectedPlaceId = placeId);
                  }),
                  const SizedBox(height: 16),
                  _buildDatePickerButton(context, setState, selectedDate, (date) {
                    setState(() => selectedDate = date);
                  }),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Category'),
                    value: selectedCategory,
                    items:
                        [
                              'Music',
                              'Sports',
                              'Culture',
                              'Festival',
                              'Food',
                              'Art',
                              'Other',
                            ]
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 16),
                  _buildImagePicker(context, event, setState),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _formIsUploading
                  ? null
                  : () async {
                      if (_webFileBytes != null || _formSelectedImage != null) {
                        setState(() => _formIsUploading = true);
                        try {
                          final appwrite = AppwriteService();
                          String fileId;
                          if (_webFileBytes != null) {
                            fileId = await appwrite.uploadImageBytes(
                              _webFileBytes!,
                              _webFileName ?? 'event.jpg',
                            );
                          } else {
                            fileId = await appwrite.uploadImage(
                              _formSelectedImage!,
                              'event_${DateTime.now().millisecondsSinceEpoch}',
                            );
                          }
                          _formImageUrl = appwrite.getImageUrl(
                            AppwriteService.placesBucket,
                            fileId,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Upload failed: $e')),
                          );
                          setState(() => _formIsUploading = false);
                          return;
                        }
                        setState(() => _formIsUploading = false);
                      }

                      final eventData = {
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'placeId': selectedPlaceId,
                        'date': selectedDate.toIso8601String(),
                        'category': selectedCategory,
                        'imageUrl': _formImageUrl ?? '',
                      };

                      if (event != null) {
                        context.read<EventsBloc>().add(
                          UpdateEvent(event['id'], eventData),
                        );
                      } else {
                        context.read<EventsBloc>().add(AddEvent(eventData));
                      }
                      Navigator.pop(ctx);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dzGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(event == null ? 'Create' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<EventsBloc>().add(DeleteEvent(event['id']));
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.algerianRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines == 1 ? 1 : 3,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    Map<String, dynamic>? event,
    StateSetter setState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event Image', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _formIsUploading
              ? null
              : () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: false,
                  );
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
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _formSelectedImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _webFileBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _webFileBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _formImageUrl != null && _formImageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _formImageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.upload, color: Colors.grey),
                            SizedBox(height: 4),
                            Text(
                              'Click to upload image',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
                if (_formIsUploading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlacesDropdown(
    StateSetter setState,
    String selectedPlaceId,
    Function(String) onChanged,
  ) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        if (state is PlacesLoading) {
          return InputDecorator(
            decoration: _inputDecoration('Select Place'),
            child: const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        } else if (state is PlacesLoaded) {
          final places = state.places;
          return DropdownButtonFormField<String>(
            decoration: _inputDecoration('Select Place'),
            value: selectedPlaceId.isNotEmpty ? selectedPlaceId : null,
            items: places.map((place) {
              return DropdownMenuItem<String>(
                value: place['id'] as String,
                child: Text(place['name'] as String),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  onChanged(value);
                });
              }
            },
            hint: const Text('Choose a place'),
          );
        } else if (state is PlacesError) {
          return Text(
            'Error loading places: ${state.message}',
            style: const TextStyle(color: AppColors.algerianRed),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDatePickerButton(
    BuildContext context,
    StateSetter setState,
    DateTime selectedDate,
    Function(DateTime) onDateChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event Date & Time', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedDate),
              );

              if (pickedTime != null) {
                final DateTime finalDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                onDateChanged(finalDateTime);
              } else {
                onDateChanged(pickedDate);
              }
            }
          },
          icon: const Icon(LucideIcons.calendar, size: 18),
          label: Text(
            DateFormat('MMM dd, yyyy - HH:mm').format(selectedDate),
            style: const TextStyle(fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: Colors.grey.shade300),
            alignment: Alignment.centerLeft,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
