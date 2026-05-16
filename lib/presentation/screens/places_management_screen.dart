import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/blocs/places/places_bloc.dart';
import '../../logic/blocs/places/places_event.dart';
import '../../logic/blocs/places/places_state.dart';
import '../widgets/loading_shimmer.dart';

class PlacesManagementScreen extends StatelessWidget {
  const PlacesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Places Management',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Manage all Algerian destinations and their status',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showPlaceForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dzGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('Add New Destination'),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, PlacesState state) {
    if (state is PlacesLoading) {
      return const LoadingShimmer(width: double.infinity, height: 600, borderRadius: 25);
    } else if (state is PlacesLoaded) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search destinations...',
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Historical'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Nature'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Luxury'),
                ],
              ),
              const SizedBox(height: 24),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1.5),
                  5: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _buildTableHeader(),
                  ...state.places.map((place) => _buildTableRow(context, place)),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (state is PlacesError) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = label == 'All';
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) {},
      backgroundColor: Colors.white,
      selectedColor: AppColors.dzGreen.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.dzGreen : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppColors.dzGreen : Colors.grey.shade200),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        'Image',
        'Destination',
        'Category',
        'Rating',
        'Status',
        'Actions',
      ]
          .map((text) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ))
          .toList(),
    );
  }

  TableRow _buildTableRow(BuildContext context, Map<String, dynamic> place) {
    bool isLive = place['status'] == 'Live';
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              place['image'],
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 48,
                height: 48,
                color: Colors.grey.shade100,
                child: const Icon(LucideIcons.image, size: 20, color: Colors.grey),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(place['location'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(place['category']),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(place['rating'].toString()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Switch(
            value: isLive,
            activeThumbColor: AppColors.dzGreen,
            onChanged: (val) {
              context.read<PlacesBloc>().add(UpdatePlaceStatus(place['id'], val));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.edit2, size: 18, color: AppColors.elitePurple),
                onPressed: () => _showPlaceForm(context, place: place),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.algerianRed),
                onPressed: () {
                  context.read<PlacesBloc>().add(DeletePlace(place['id']));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPlaceForm(BuildContext context, {Map<String, dynamic>? place}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(place == null ? 'Add New Destination' : 'Edit Destination'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Title', initialValue: place?['title']),
                const SizedBox(height: 16),
                _buildTextField('Description', maxLines: 3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Latitude')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Longitude')),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Category'),
                  initialValue: place?['category'],
                  items: ['Historical', 'Nature', 'Luxury']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 16),
                _buildTextField('Image URL', initialValue: place?['image']),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dzGreen, foregroundColor: Colors.white),
            child: Text(place == null ? 'Create' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1, String? initialValue}) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
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
}
