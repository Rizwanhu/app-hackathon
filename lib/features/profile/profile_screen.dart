import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../services/sme_app_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _services = SmeAppServices.instance;
  final _usernameController = TextEditingController();
  String? _avatarUrl;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final user = _profileService.currentUser;
    _email = user?.email;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _profileService.getProfile();
      if (data != null && mounted) {
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _avatarUrl = data['avatar_url'];
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final File file = File(pickedFile.path);
        final String fileExt = pickedFile.path.split('.').last;
        final upload = await _services.storage.uploadAvatarFile(
          file: file,
          fileExtension: fileExt,
        );
        if (upload.isFailure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(upload.errorMessage ?? 'Upload failed'),
                backgroundColor: AppColors.expenseRed,
              ),
            );
          }
          return;
        }
        final url = upload.dataOrNull!;

        final saved = await _profileService.updateProfile(
          username: _usernameController.text.trim(),
          avatarUrl: url,
        );
        if (saved.isFailure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(saved.errorMessage ?? 'Could not save profile'),
                backgroundColor: AppColors.expenseRed,
              ),
            );
          }
          return;
        }

        setState(() => _avatarUrl = url);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: AppColors.incomeGreen,
            ),
          );
        }
      } catch (e) {
        debugPrint('Upload Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload Failed: $e'), backgroundColor: AppColors.expenseRed),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: _isLoading && _email == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      child: Column(
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 56,
                                  backgroundColor: AppColors.surfaceSecondary,
                                  backgroundImage:
                                      _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                                  child: _avatarUrl == null
                                      ? Icon(Icons.person_rounded, size: 56, color: Colors.grey.shade500)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 4,
                                  child: Material(
                                    color: AppColors.primary,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: _showPickerOptions,
                                      customBorder: const CircleBorder(),
                                      child: const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(Icons.add_a_photo_rounded, size: 18, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _email ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        final r = await _profileService.updateProfile(
                          username: _usernameController.text.trim(),
                        );
                        if (!mounted) return;
                        setState(() => _isLoading = false);
                        if (!context.mounted) return;
                        if (r.isFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(r.errorMessage ?? 'Save failed'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile saved')),
                          );
                        }
                      },
                      child: const Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Update Profile Picture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () { Navigator.pop(ctx); _pickAndUploadImage(ImageSource.gallery); },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () { Navigator.pop(ctx); _pickAndUploadImage(ImageSource.camera); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}