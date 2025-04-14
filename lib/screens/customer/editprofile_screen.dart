import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ts_autoparts_app/services/auth_service.dart';
import 'package:ts_autoparts_app/utils/secure_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  File? _image;
  String? _existingImageUrl;

  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    final username = await SecureStorage.getUsername();
    final profileImageUrl = await SecureStorage.getProfileImage();

    setState(() {
      _nameController.text = username ?? '';
      _existingImageUrl = profileImageUrl;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedUser = await _authService.updateUserProfile(
      name: _nameController.text.trim(),
      profileImage: _image,
    );

    if (updatedUser != null) {
      await SecureStorage.saveUsername(updatedUser['name']);

      if (updatedUser['profile_image'] != null) {
        await SecureStorage.saveProfileImage(updatedUser['profile_image']);
        setState(() {
          _existingImageUrl = updatedUser['profile_image'];
          _image = null;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }

    setState(() => _isLoading = false);
  }

  ImageProvider _getProfileImage() {
    if (_image != null) {
      return FileImage(_image!);
    } else if (_existingImageUrl != null &&
        _existingImageUrl!.startsWith('http')) {
      final cacheBustedUrl =
          '$_existingImageUrl?v=${DateTime.now().millisecondsSinceEpoch}';
      return NetworkImage(cacheBustedUrl);
    } else {
      return const AssetImage('assets/images/profile.jpg');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: _getProfileImage(),
                                child: _image == null &&
                                        (_existingImageUrl == null ||
                                            _existingImageUrl!.isEmpty)
                                    ? const Icon(Icons.person, size: 60)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        size: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Username",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ),
    );
  }
}