import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:news_app/controllers/saved_controller.dart';
import 'package:news_app/controllers/theme_controller.dart';
import 'package:news_app/services/storage_service.dart';
import 'package:news_app/utils/app_colors.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final StorageService _storageService = StorageService();
  late String _name;
  late String _phone;
  late String _bio;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _name = _storageService.getProfileName();
    _phone = _storageService.getProfilePhone();
    _bio = _storageService.getProfileBio();
  }

  String get _initials {
    final words = _name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final phoneController = TextEditingController(text: _phone);
    final bioController = TextEditingController(text: _bio);

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              TextField(
                controller: bioController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await _storageService.saveProfile(
                name: nameController.text,
                phone: phoneController.text,
                bio: bioController.text,
              );
              Get.back(result: true);
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );

    nameController.dispose();
    phoneController.dispose();
    bioController.dispose();

    if (result == true && mounted) {
      setState(_loadProfile);
      Get.snackbar(
        'Profile updated',
        'Your profile details have been saved.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedController = Get.find<SavedController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStats(savedController),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 16),
                  _buildSettingsSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile', style: TextStyle(color: Colors.white70)),
              IconButton(
                onPressed: _editProfile,
                tooltip: 'Edit profile',
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(SavedController savedController) {
    return Obx(
      () => Row(
        children: [
          _statTile('${savedController.savedArticles.length}', 'Saved'),
          const SizedBox(width: 12),
          _statTile('7', 'Topics'),
          const SizedBox(width: 12),
          _statTile('24/7', 'Updated'),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return _section(
      title: 'Contact details',
      children: [
        _infoTile(
          Icons.phone_outlined,
          _phone.isEmpty ? 'Add phone number' : _phone,
        ),
        _infoTile(Icons.verified_user_outlined, 'Personalized news feed'),
      ],
    );
  }

  Widget _buildSettingsSection() {
    final themeController = Get.find<ThemeController>();
    return _section(
      title: 'Preferences',
      children: [
        Obx(
          () => SwitchListTile(
            secondary: Icon(
              themeController.isDarkMode.value
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'Dark & glow mode',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Tampilan gelap dengan aksen bercahaya'),
            value: themeController.isDarkMode.value,
            onChanged: themeController.toggleTheme,
          ),
        ),
        _infoTile(Icons.notifications_none_rounded, 'News notifications'),
        _infoTile(Icons.lock_outline_rounded, 'Privacy and security'),
      ],
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textHint,
      ),
    );
  }
}
