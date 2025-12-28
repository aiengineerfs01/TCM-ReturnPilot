import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

enum PickerSource { camera, gallery, file }

class DocumentPickerResult {
  final File? file;
  final String? fileName;
  final String? errorMessage;
  final bool isSuccess;

  DocumentPickerResult({
    this.file,
    this.fileName,
    this.errorMessage,
    this.isSuccess = false,
  });

  factory DocumentPickerResult.success({
    required File file,
    required String fileName,
  }) {
    return DocumentPickerResult(
      file: file,
      fileName: fileName,
      isSuccess: true,
    );
  }

  factory DocumentPickerResult.error(String message) {
    return DocumentPickerResult(errorMessage: message, isSuccess: false);
  }

  factory DocumentPickerResult.cancelled() {
    return DocumentPickerResult(isSuccess: false);
  }
}

class DocumentPickerService {
  static final DocumentPickerService _instance =
      DocumentPickerService._internal();
  factory DocumentPickerService() => _instance;
  DocumentPickerService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  // Maximum file size in bytes (10 MB)
  static const int maxFileSizeInBytes = 10 * 1024 * 1024;

  // Allowed file extensions
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  // ============================================
  // PICK DOCUMENT (ID Front/Back)
  // ============================================
  Future<DocumentPickerResult> pickDocument(BuildContext context) async {
    try {
      final PickerSource? source = await _showDocumentSourceDialog(context);

      if (source == null) {
        return DocumentPickerResult.cancelled();
      }

      if (source == PickerSource.file || source == PickerSource.gallery) {
        return await _pickFromFiles();
      } else {
        return await _pickFromCamera();
      }
    } catch (e) {
      return DocumentPickerResult.error('Failed to pick document: $e');
    }
  }

  // ============================================
  // PICK SELFIE
  // ============================================
  Future<DocumentPickerResult> pickSelfie(BuildContext context) async {
    try {
      final PickerSource? source = await _showSelfieSourceDialog(context);

      if (source == null) {
        return DocumentPickerResult.cancelled();
      }

      if (source == PickerSource.gallery) {
        return await _pickImageFromGallery();
      } else {
        return await _pickSelfieFromCamera();
      }
    } catch (e) {
      return DocumentPickerResult.error('Failed to take selfie: $e');
    }
  }

  // ============================================
  // PICK PROFILE IMAGE
  // ============================================
  Future<DocumentPickerResult> pickProfileImage(BuildContext context) async {
    try {
      final PickerSource? source = await _showProfileImageSourceDialog(context);

      if (source == null) {
        return DocumentPickerResult.cancelled();
      }

      if (source == PickerSource.gallery) {
        return await _pickImageFromGallery(
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );
      } else {
        return await _pickFromCamera(
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );
      }
    } catch (e) {
      return DocumentPickerResult.error('Failed to pick image: $e');
    }
  }

  // ============================================
  // PRIVATE METHODS - FILE PICKING
  // ============================================
  Future<DocumentPickerResult> _pickFromFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null || result.files.single.path == null) {
      return DocumentPickerResult.cancelled();
    }

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    // Validate file size
    final validationResult = await _validateFileSize(file);
    if (!validationResult.isSuccess) {
      return validationResult;
    }

    return DocumentPickerResult.success(file: file, fileName: fileName);
  }

  Future<DocumentPickerResult> _pickFromCamera({
    double maxWidth = 1920,
    double maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (pickedFile == null) {
      return DocumentPickerResult.cancelled();
    }

    final file = File(pickedFile.path);

    // Validate file size
    final validationResult = await _validateFileSize(file);
    if (!validationResult.isSuccess) {
      return validationResult;
    }

    return DocumentPickerResult.success(file: file, fileName: pickedFile.name);
  }

  Future<DocumentPickerResult> _pickSelfieFromCamera() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile == null) {
      return DocumentPickerResult.cancelled();
    }

    final file = File(pickedFile.path);

    // Validate file size
    final validationResult = await _validateFileSize(file);
    if (!validationResult.isSuccess) {
      return validationResult;
    }

    return DocumentPickerResult.success(file: file, fileName: pickedFile.name);
  }

  Future<DocumentPickerResult> _pickImageFromGallery({
    double maxWidth = 1080,
    double maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (pickedFile == null) {
      return DocumentPickerResult.cancelled();
    }

    final file = File(pickedFile.path);

    // Validate file size
    final validationResult = await _validateFileSize(file);
    if (!validationResult.isSuccess) {
      return validationResult;
    }

    return DocumentPickerResult.success(file: file, fileName: pickedFile.name);
  }

  // ============================================
  // FILE VALIDATION
  // ============================================
  Future<DocumentPickerResult> _validateFileSize(File file) async {
    final fileSize = await file.length();

    if (fileSize > maxFileSizeInBytes) {
      return DocumentPickerResult.error(
        'File size exceeds 10 MB.  Please select a smaller file.',
      );
    }

    return DocumentPickerResult(isSuccess: true);
  }

  // ============================================
  // DIALOGS
  // ============================================
  Future<PickerSource?> _showDocumentSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<PickerSource>(
      context: context,
      backgroundColor: AppTheme.of(context).primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final theme = AppTheme.of(context);
        return _PickerBottomSheet(
          title: 'Upload Document',
          subtitle: 'Choose how to upload your ID',
          options: [
            _PickerOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Use camera to capture document',
              source: PickerSource.camera,
              theme: theme,
            ),
            _PickerOption(
              icon: Icons.folder_open,
              title: 'Browse Files',
              subtitle: 'Select from your device',
              source: PickerSource.file,
              theme: theme,
            ),
          ],
        );
      },
    );
  }

  Future<PickerSource?> _showSelfieSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<PickerSource>(
      context: context,
      backgroundColor: AppTheme.of(context).primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final theme = AppTheme.of(context);
        return _PickerBottomSheet(
          title: 'Take Selfie',
          subtitle: 'Choose how to take your selfie',
          options: [
            _PickerOption(
              icon: Icons.camera_front,
              title: 'Front Camera',
              subtitle: 'Take a selfie using front camera',
              source: PickerSource.camera,
              theme: theme,
            ),
            _PickerOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select an existing photo',
              source: PickerSource.gallery,
              theme: theme,
            ),
          ],
        );
      },
    );
  }

  Future<PickerSource?> _showProfileImageSourceDialog(
    BuildContext context,
  ) async {
    return await showModalBottomSheet<PickerSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final theme = AppTheme.of(context);
        return _PickerBottomSheet(
          title: 'Select Image',
          subtitle: 'Choose profile picture source',
          options: [
            _PickerOption(
              icon: Icons.camera_alt,
              title: 'Camera',
              subtitle: 'Take a new photo',
              source: PickerSource.camera,
              theme: theme,
            ),
            _PickerOption(
              icon: Icons.photo_library,
              title: 'Gallery',
              subtitle: 'Choose from gallery',
              source: PickerSource.gallery,
              theme: theme,
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // SNACKBAR HELPERS
  // ============================================
  static void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
    );
  }
}

// ============================================
// PICKER BOTTOM SHEET WIDGET
// ============================================
class _PickerBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_PickerOption> options;

  const _PickerBottomSheet({
    required this.title,
    required this.subtitle,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.grey2.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(title, style: poppinsSemiBold.copyWith(fontSize: 18)),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: poppinsRegular.copyWith(fontSize: 14, color: theme.grey2),
            ),
            const SizedBox(height: 20),

            // Options
            ...options,

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PICKER OPTION WIDGET
// ============================================
class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PickerSource source;
  final dynamic theme;

  const _PickerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.source,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.appGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.appGreen),
      ),
      title: Text(title, style: poppinsMedium.copyWith(fontSize: 16)),
      subtitle: Text(
        subtitle,
        style: poppinsRegular.copyWith(fontSize: 12, color: theme.grey2),
      ),
      onTap: () => Navigator.pop(context, source),
    );
  }
}
