import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/services/document_picker_service.dart';
import 'package:tcm_return_pilot/widgets/app_top_bar.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/document_preview_widget.dart';
import 'package:tcm_return_pilot/widgets/safe_pop_scope.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';

class VerifyIdentityScreen extends StatefulWidget {
  const VerifyIdentityScreen({super.key});

  static const String routeName = 'VerifyIdentityScreen';
  static const String routePath = '/verifyIdentity';

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  // Service instance
  final DocumentPickerService _pickerService = DocumentPickerService();

  // Store selected files
  File? _frontIdFile;
  File? _backIdFile;
  File? _selfieFile;

  // Store file names
  String? _frontIdFileName;
  String? _backIdFileName;

  // Check if all documents are uploaded
  bool get _isAllDocumentsUploaded =>
      _frontIdFile != null && _backIdFile != null && _selfieFile != null;

  // ============================================
  // PICK HANDLERS
  // ============================================
  Future<void> _pickFrontId() async {
    final result = await _pickerService.pickDocument(context);
    _handlePickerResult(
      result,
      onSuccess: (file, fileName) {
        setState(() {
          _frontIdFile = file;
          _frontIdFileName = fileName;
        });
      },
    );
  }

  Future<void> _pickBackId() async {
    final result = await _pickerService.pickDocument(context);
    _handlePickerResult(
      result,
      onSuccess: (file, fileName) {
        setState(() {
          _backIdFile = file;
          _backIdFileName = fileName;
        });
      },
    );
  }

  Future<void> _pickSelfie() async {
    final result = await _pickerService.pickSelfie(context);
    _handlePickerResult(
      result,
      onSuccess: (file, fileName) {
        setState(() {
          _selfieFile = file;
        });
      },
    );
  }

  // ============================================
  // RESULT HANDLER
  // ============================================
  void _handlePickerResult(
    DocumentPickerResult result, {
    required Function(File file, String fileName) onSuccess,
  }) {
    if (result.isSuccess && result.file != null) {
      onSuccess(result.file!, result.fileName ?? 'Unknown');
    } else if (result.errorMessage != null) {
      DocumentPickerService.showErrorSnackbar(result.errorMessage!);
    }
  }

  // ============================================
  // REMOVE HANDLERS
  // ============================================
  void _removeFrontId() {
    setState(() {
      _frontIdFile = null;
      _frontIdFileName = null;
    });
  }

  void _removeBackId() {
    setState(() {
      _backIdFile = null;
      _backIdFileName = null;
    });
  }

  void _removeSelfie() {
    setState(() {
      _selfieFile = null;
    });
  }

  // ============================================
  // SUBMIT
  // ============================================

  // Add controller in state class
  final AuthController _authController = Get.find<AuthController>();

  // Update the _submitVerification method
  Future<void> _submitVerification() async {
    if (!_isAllDocumentsUploaded) {
      DocumentPickerService.showErrorSnackbar(
        'Please upload all required documents and selfie.',
      );
      return;
    }

    await _authController.submitIdentityVerification(
      frontId: _frontIdFile!,
      backId: _backIdFile!,
      selfie: _selfieFile!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafePopScope(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: Column(
            children: [
              AppTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(21, 20, 21, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                        'Verify Identity',
                        style: poppinsSemiBold.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Upload your ID (front & back) and a quick selfie for verification',
                        style: poppinsMedium.copyWith(
                          fontSize: 14,
                          color: theme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Front ID Section
                      _buildSectionTitle('Upload Front Side of ID'),
                      const SizedBox(height: 8),
                      _buildFrontIdWidget(),
                      const SizedBox(height: 21),

                      // Back ID Section
                      _buildSectionTitle('Upload Back Side of ID'),
                      const SizedBox(height: 8),
                      _buildBackIdWidget(),
                      const SizedBox(height: 21),

                      // Selfie Section
                      _buildSectionTitle('Take your selfie'),
                      const SizedBox(height: 8),
                      _buildSelfieWidget(),
                      const SizedBox(height: 30),

                      // Submit Button
                      Obx(
                        () => PrimaryButton(
                          onTap: _authController.isLoading
                              ? null
                              : _submitVerification,
                          child: _authController.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Submit for Verification',
                                  style: poppinsMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Logo
                      Center(child: SolvquestLogo(height: 45)),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  // ============================================
  // BUILD HELPERS
  // ============================================
  Widget _buildSectionTitle(String title) {
    return Text(title, style: poppinsBold.copyWith(fontSize: 15));
  }

  Widget _buildFrontIdWidget() {
    if (_frontIdFile != null) {
      return FilePreviewWidget(
        file: _frontIdFile!,
        fileName: _frontIdFileName ?? 'Front ID',
        onRemove: _removeFrontId,
        onRetake: _pickFrontId,
      );
    }
    return FileDropZone(onTap: _pickFrontId);
  }

  Widget _buildBackIdWidget() {
    if (_backIdFile != null) {
      return FilePreviewWidget(
        file: _backIdFile!,
        fileName: _backIdFileName ?? 'Back ID',
        onRemove: _removeBackId,
        onRetake: _pickBackId,
      );
    }
    return FileDropZone(onTap: _pickBackId);
  }

  Widget _buildSelfieWidget() {
    if (_selfieFile != null) {
      return SelfiePreviewWidget(
        file: _selfieFile!,
        onRemove: _removeSelfie,
        onRetake: _pickSelfie,
      );
    }
    return SelfieZone(onTap: _pickSelfie);
  }
}
