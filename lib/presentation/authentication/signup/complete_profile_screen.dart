import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/utils/extensions.dart';
import 'package:tcm_return_pilot/utils/validators.dart';
import 'package:tcm_return_pilot/widgets/app_top_bar.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';
import 'package:tcm_return_pilot/widgets/required_text.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';
import 'dart:io';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  static const String routeName = 'CompleteProfileScreen';
  static const String routePath = '/completeProfile';

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  final _firstNameController =
      TextEditingController(); // ← RENAMED from _nameController
  final _lastNameController = TextEditingController(); // ← NEW CONTROLLER
  final _addressController = TextEditingController(); // ← NEW CONTROLLER
  final _phoneController = TextEditingController(); // ← NEW CONTROLLER
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ← NEW:  Image picker variables
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // ← NEW: Method to pick image
  Future<void> _pickImage() async {
    try {
      // Show bottom sheet to choose between camera and gallery
      final ImageSource? source = await _showImageSourceDialog();

      if (source == null) return;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
      Get.snackbar(
        'Error',
        'Failed to pick image:  $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ← NEW: Method to show image source dialog
  Future<ImageSource?> _showImageSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.of(context).primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final theme = AppTheme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: poppinsSemiBold.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: theme.appGreen),
                  title: Text(
                    'Camera',
                    style: poppinsMedium.copyWith(fontSize: 16),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: theme.appGreen),
                  title: Text(
                    'Gallery',
                    style: poppinsMedium.copyWith(fontSize: 16),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose(); // ← UPDATED
    _lastNameController.dispose(); // ← NEW
    _addressController.dispose(); // ← NEW
    _phoneController.dispose(); // ← NEW
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Obx(() {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                AppTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    // ← NEW: Added SingleChildScrollView for scrolling
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        21,
                        20,
                        21,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Information',
                            style: poppinsSemiBold.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fill the personal details below',
                            style: poppinsMedium.copyWith(
                              fontSize: 14,
                              color: theme.grey2,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // ← NEW: Avatar Section
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.grey2.withOpacityAlpha(0.1),
                                      border: Border.all(
                                        color: theme.grey2.withOpacityAlpha(
                                          0.3,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: _selectedImage != null
                                        ? ClipOval(
                                            child: Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                              width: 120,
                                              height: 120,
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                size: 40,
                                                color: theme.grey2,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Upload Image',
                                                style: poppinsRegular.copyWith(
                                                  fontSize: 10,
                                                  color: theme.grey2,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Text(
                                    'Select',
                                    style: poppinsMedium.copyWith(
                                      fontSize: 14,
                                      color: theme.appGreen,
                                      decoration: TextDecoration.underline,
                                      decorationColor: theme.appGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ← END:  Avatar Section
                          RequiredText(text: 'First Name'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: 'Enter your first name',
                            controller: _firstNameController, // ← UPDATED
                            validator: (value) => Validator.validateForm(
                              value,
                              'please enter your first name',
                            ),
                          ),
                          const SizedBox(height: 16),

                          RequiredText(text: 'Last Name'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: 'Enter your last name',
                            controller: _lastNameController, // ← UPDATED
                            validator: (value) => Validator.validateForm(
                              value,
                              'please enter your last name',
                            ),
                          ),
                          const SizedBox(height: 16),

                          RequiredText(text: 'Address'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: 'Enter your complete address',
                            controller: _addressController, // ← UPDATED
                            validator: (value) => Validator.validateForm(
                              value,
                              'please enter your address',
                            ),
                          ),
                          const SizedBox(height: 16),

                          RequiredText(text: 'Contact Number'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: 'Enter your phone number',
                            controller: _phoneController, // ← UPDATED
                            validator: (value) => Validator.validateForm(
                              value,
                              'please enter your phone number',
                            ),

                            keyBoardType: TextInputType.phone, // ← NEW
                          ),
                          const SizedBox(height: 22),

                          PrimaryButton(
                            onTap: _authController.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (_selectedImage == null) {
                                        Get.snackbar(
                                          'Error',
                                          'Please select an image',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        return;
                                      }
                                      await _authController.completeProfile(
                                        _firstNameController.text.trim(),
                                        _lastNameController.text.trim(),
                                        _addressController.text.trim(),
                                        _phoneController.text.trim(),
                                        _selectedImage,
                                      );
                                    }
                                  },
                            child: _authController.isLoading
                                ? const CircularProgressIndicator.adaptive()
                                : Text(
                                    'Get Started',
                                    style: poppinsMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 10),

                          Center(child: SolvquestLogo(height: 45)),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
