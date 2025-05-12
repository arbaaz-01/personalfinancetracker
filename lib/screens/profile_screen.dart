import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../utils/theme_config.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form field controllers to manage input without setState
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String? _photoUrl;
  bool _isEditing = false;
  bool _isLoading = false;
  File? _imageFile;
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _nameFocusNode.addListener(_onFocusChange);
    _emailFocusNode.addListener(_onFocusChange);
    _phoneFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.removeListener(_onFocusChange);
    _phoneFocusNode.removeListener(_onFocusChange);
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_nameFocusNode.hasFocus ||
        _emailFocusNode.hasFocus ||
        _phoneFocusNode.hasFocus) {
      _scrollController.animateTo(
        100,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        elevation: 0,
      ),
      body: StreamBuilder<UserProfileModel?>(
        stream: _profileService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          UserProfileModel? profile = snapshot.data;

          // Initialize form controllers with profile data when not editing
          if (!_isEditing && profile != null) {
            _nameController.text = profile.name;
            _emailController.text = profile.email;
            _phoneController.text = profile.phoneNumber ?? '';
            _photoUrl = profile.photoUrl;
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                _buildProfileImage(profile),
                SizedBox(height: 24),
                _isEditing ? _buildEditForm() : _buildProfileInfo(profile),
                SizedBox(height: 30),
                _buildActionButtons(profile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(UserProfileModel? profile) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).cardColor,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!) as ImageProvider
                : (profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty
                    ? (profile.photoUrl!.startsWith('http')
                        ? NetworkImage(profile.photoUrl!)
                        : FileImage(File(profile.photoUrl!))) as ImageProvider
                    : null),
            child: profile?.photoUrl == null ||
                    profile!.photoUrl!.isEmpty && _imageFile == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey[400],
                  )
                : null,
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: _pickImage,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileInfo(UserProfileModel? profile) {
    if (profile == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.person_outline,
                size: 60,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Profile not set up yet',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: Icon(Icons.edit),
                label: Text('Set Up Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileInfoItem(
              icon: Icons.person,
              title: 'Name',
              value: profile.name,
            ),
            Divider(),
            _buildProfileInfoItem(
              icon: Icons.email,
              title: 'Email',
              value: profile.email,
            ),
            if (profile.phoneNumber != null &&
                profile.phoneNumber!.isNotEmpty) ...[
              Divider(),
              _buildProfileInfoItem(
                icon: Icons.phone,
                title: 'Phone',
                value: profile.phoneNumber!,
              ),
            ],
            Divider(),
            _buildProfileInfoItem(
              icon: Icons.currency_rupee,
              title: 'Currency',
              value: profile.currency ?? '₹',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val!.isEmpty || !val.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _imageFile = null;
                      });
                    },
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveProfile,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.save),
                    label: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(UserProfileModel? profile) {
    return Column(
      children: [
        if (!_isEditing && profile != null)
          ElevatedButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Edit Profile'),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        SizedBox(height: 16),
        OutlinedButton.icon(
          icon: Icon(Icons.logout, color: ThemeConfig.expenseColor),
          label: Text('Sign Out',
              style: TextStyle(color: ThemeConfig.expenseColor)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: ThemeConfig.expenseColor),
          ),
          onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).signOut();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? photoUrl = _photoUrl;

        // Use local file path for the image if selected
        if (_imageFile != null) {
          photoUrl = _imageFile!.path; // Store the local file path
        }

        UserProfileModel profile = UserProfileModel(
          userId: FirebaseAuth.instance.currentUser!.uid,
          name: _nameController.text,
          email: _emailController.text,
          photoUrl: photoUrl,
          phoneNumber:
              _phoneController.text.isNotEmpty ? _phoneController.text : null,
          currency: '₹', // Default currency as per profile_service.dart
        );

        await _profileService.updateUserProfile(profile);

        setState(() {
          _isEditing = false;
          _isLoading = false;
          _imageFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
