import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_feedback.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _avatarPreviewBytes;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<SessionProvider>().currentUser;
    if (_fullNameController.text.isEmpty) {
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final error = await context.read<SessionProvider>().updateProfile(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
        );

    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, context.tr(error), backgroundColor: Colors.red.shade700);
      return;
    }

    showAppSnackBar(context, context.tr('Profile updated successfully.'));
    Navigator.pop(context);
  }

  Future<void> _selectAvatarSource() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.tr('Take Photo')),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.tr('Choose From Gallery')),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _pickAvatar(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (pickedFile == null) {
      return;
    }

    final imageBytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    setState(() {
      _avatarPreviewBytes = imageBytes;
      _isUploadingAvatar = true;
    });

    final error = await context.read<SessionProvider>().updateProfileAvatar(
          imageBytes: imageBytes,
          filename: pickedFile.name.isNotEmpty ? pickedFile.name : 'avatar.jpg',
        );

    if (!mounted) return;

    setState(() {
      _isUploadingAvatar = false;
      if (error == null) {
        _avatarPreviewBytes = null;
      }
    });

    if (error != null) {
      showAppSnackBar(
        context,
        context.tr(error),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    showAppSnackBar(
      context,
      context.tr('Profile image updated successfully.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF1B5E20);
    const Color lightGreenFill = Color(0xFFF1F8E9);
    final user = context.watch<SessionProvider>().currentUser;
    final isBusy = context.watch<SessionProvider>().isBusy;
    final hasAvatar = user.avatarUrl.trim().isNotEmpty;
    final ImageProvider? avatarImage =
        _avatarPreviewBytes != null
            ? MemoryImage(_avatarPreviewBytes!)
            : (hasAvatar ? NetworkImage(user.avatarUrl) : null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: darkGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('Edit Profile'),
          style: GoogleFonts.outfit(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: lightGreenFill, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: lightGreenFill,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Text(
                              user.initials,
                              style: GoogleFonts.outfit(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: darkGreen,
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (_isUploadingAvatar)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    bottom: 0,
                    end: 4,
                    child: GestureDetector(
                      onTap:
                          _isUploadingAvatar || isBusy
                              ? null
                              : _selectAvatarSource,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: darkGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildField(context.tr('Full Name'), _fullNameController, Icons.person_outline),
            _buildField(context.tr('Email Address'), _emailController, Icons.email_outlined),
            _buildField(context.tr('Phone Number'), _phoneController, Icons.phone_android_outlined),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: isBusy ? null : _saveChanges,
                child: isBusy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text(
                        context.tr('Save Changes'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    const Color darkGreen = Color(0xFF1B5E20);
    const Color lightGreenFill = Color(0xFFF1F8E9);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: darkGreen, size: 20),
              filled: true,
              fillColor: lightGreenFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}
