import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../core/theme/app_colors.dart';
import '../../core/services/appwrite_service.dart';
import '../../logic/blocs/rewards/rewards_bloc.dart';
import '../../logic/blocs/rewards/rewards_event.dart';
import '../../logic/blocs/rewards/rewards_state.dart';
import '../widgets/loading_shimmer.dart';

class RewardsManagementScreen extends StatefulWidget {
  const RewardsManagementScreen({super.key});

  @override
  State<RewardsManagementScreen> createState() => _RewardsManagementScreenState();
}

class _RewardsManagementScreenState extends State<RewardsManagementScreen> {
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
    return BlocBuilder<RewardsBloc, RewardsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              Expanded(child: _buildBody(context, state)),
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
              'Rewards Factory',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage luxury rewards and point redemption costs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showRewardForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.elitePurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(LucideIcons.gift, size: 20),
          label: const Text('Create New Reward'),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, RewardsState state) {
    if (state is RewardsLoading) {
      return const LoadingShimmer(
        width: double.infinity,
        height: 600,
        borderRadius: 25,
      );
    } else if (state is RewardsLoaded) {
      final filteredRewards = state.rewards.where((r) =>
        r['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();

      if (filteredRewards.isEmpty && _searchQuery.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.packageOpen,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No rewards found. Start by creating one!',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }
      
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search rewards...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredRewards.length,
              itemBuilder: (context, index) {
                final reward = filteredRewards[index];
                return _buildRewardCard(context, reward);
              },
            ),
          ),
        ],
      );
    } else if (state is RewardsError) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  }

  Widget _buildRewardCard(BuildContext context, Map<String, dynamic> reward) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.network(
              reward['image'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey.shade100,
                child: const Icon(
                  LucideIcons.image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.elitePurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reward['category'],
                        style: const TextStyle(
                          color: AppColors.elitePurple,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Expires: ${reward['expiry']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reward['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Points Cost',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${reward['cost']} pts',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.dzGreen,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            LucideIcons.edit,
                            color: AppColors.dzGreen,
                            size: 20,
                          ),
                          onPressed: () => _showRewardForm(context, reward: reward),
                          tooltip: 'Edit Reward',
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.trash2,
                            color: AppColors.algerianRed,
                            size: 20,
                          ),
                          onPressed: () => _showDeleteConfirmation(context, reward),
                          tooltip: 'Delete Reward',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardForm(BuildContext context, {Map<String, dynamic>? reward}) {
    _formSelectedImage = null;
    _formImageUrl = reward?['image'];
    _formIsUploading = false;
    _webFileBytes = null;
    _webFileName = null;
    
    final titleController = TextEditingController(text: reward?['title']);
    final descController = TextEditingController(text: reward?['description']);
    final costController = TextEditingController(text: reward?['cost']?.toString());
    final expiryController = TextEditingController(text: reward?['expiry']);
    String selectedCat = reward?['category'] ?? 'Dining';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(reward == null ? 'Create New Reward' : 'Edit Reward'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('Reward Title', controller: titleController),
                  const SizedBox(height: 16),
                  _buildTextField('Description', controller: descController, maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Points Cost', controller: costController, keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('Expiry Date', controller: expiryController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Category'),
                    initialValue: selectedCat,
                    items: ['Dining', 'Service', 'Experience', 'Product', 'Other']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => selectedCat = v!,
                  ),
                  const SizedBox(height: 16),
                  _buildImagePicker(context, reward, setState),
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
                      fileId = await appwrite.uploadImageBytes(_webFileBytes!, _webFileName ?? 'reward.jpg');
                    } else {
                      fileId = await appwrite.uploadImage(_formSelectedImage!, 'reward_${DateTime.now().millisecondsSinceEpoch}');
                    }
                    _formImageUrl = appwrite.getImageUrl(AppwriteService.placesBucket, fileId);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
                    setState(() => _formIsUploading = false);
                    return;
                  }
                  setState(() => _formIsUploading = false);
                }

                final rewardData = {
                  'title': titleController.text,
                  'description': descController.text,
                  'cost': int.tryParse(costController.text) ?? 0,
                  'category': selectedCat,
                  'expiry': expiryController.text,
                  'imageUrl': _formImageUrl ?? '',
                };

                if (reward != null) {
                  context.read<RewardsBloc>().add(UpdateReward(reward['id'], rewardData));
                } else {
                  context.read<RewardsBloc>().add(AddReward(rewardData));
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.elitePurple, foregroundColor: Colors.white),
              child: Text(reward == null ? 'Create' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reward'),
        content: Text('Are you sure you want to delete "${reward['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<RewardsBloc>().add(DeleteReward(reward['id']));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.algerianRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {TextEditingController? controller, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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

  Widget _buildImagePicker(BuildContext context, Map<String, dynamic>? reward, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reward Image', style: Theme.of(context).textTheme.labelMedium),
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
