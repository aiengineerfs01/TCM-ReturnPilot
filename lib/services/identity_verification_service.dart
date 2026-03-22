import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/models/identity_verification_model.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/utils/enums.dart';

class IdentityVerificationService {
  static final IdentityVerificationService _instance =
      IdentityVerificationService._internal();
  factory IdentityVerificationService() => _instance;
  IdentityVerificationService._internal();

  final SupabaseClient _client = SupabaseService.client;

  // Bucket and folder configuration
  static const String _bucketName = 'profile_media';
  static const String _identityFolder = 'identity';

  // ============================================
  // UPLOAD IDENTITY DOCUMENTS
  // ============================================
  Future<IdentityVerificationResult> submitVerification({
    required File frontId,
    required File backId,
    required File selfie,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return IdentityVerificationResult.error('User not authenticated');
      }

      // Upload all documents in parallel
      final results = await Future.wait([
        _uploadDocument(
          file: frontId,
          userId: userId,
          documentType: 'front_id',
        ),
        _uploadDocument(file: backId, userId: userId, documentType: 'back_id'),
        _uploadDocument(file: selfie, userId: userId, documentType: 'selfie'),
      ]);

      final frontIdUrl = results[0];
      final backIdUrl = results[1];
      final selfieUrl = results[2];

      // Check if all uploads succeeded
      if (frontIdUrl == null || backIdUrl == null || selfieUrl == null) {
        return IdentityVerificationResult.error(
          'Failed to upload one or more documents',
        );
      }

      // Save to database
      await _saveVerificationRecord(
        userId: userId,
        frontIdUrl: frontIdUrl,
        backIdUrl: backIdUrl,
        selfieUrl: selfieUrl,
      );

      // Update profile verification status
      await _updateProfileVerificationStatus(
        userId: userId,
        status: IdentityVerificationStatus.pending,
      );

      return IdentityVerificationResult.success(
        message: 'Documents submitted successfully',
      );
    } catch (e) {
      log('Error submitting verification: $e');
      return IdentityVerificationResult.error(
        'Failed to submit verification: ${e.toString()}',
      );
    }
  }

  // ============================================
  // UPLOAD SINGLE DOCUMENT
  // ============================================
  Future<String?> _uploadDocument({
    required File file,
    required String userId,
    required String documentType,
  }) async {
    try {
      // Generate unique file name
      final fileExtension = path.extension(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${documentType}_$timestamp$fileExtension';
      final filePath = '$_identityFolder/$userId/$fileName';

      // Delete existing file if any (to replace)
      await _deleteExistingDocument(userId, documentType);

      // Upload new file
      await _client.storage
          .from(_bucketName)
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      log('Error uploading $documentType: $e');
      return null;
    }
  }

  // ============================================
  // DELETE EXISTING DOCUMENT
  // ============================================
  Future<void> _deleteExistingDocument(
    String userId,
    String documentType,
  ) async {
    try {
      final folderPath = '$_identityFolder/$userId';

      // List files in user's folder
      final files = await _client.storage
          .from(_bucketName)
          .list(path: folderPath);

      // Find and delete files matching the document type
      for (final file in files) {
        if (file.name.startsWith(documentType)) {
          await _client.storage.from(_bucketName).remove([
            '$folderPath/${file.name}',
          ]);
        }
      }
    } catch (e) {
      // Ignore errors - file might not exist
      log('Error deleting existing document:  $e');
    }
  }

  // ============================================
  // SAVE VERIFICATION RECORD
  // ============================================
  Future<void> _saveVerificationRecord({
    required String userId,
    required String frontIdUrl,
    required String backIdUrl,
    required String selfieUrl,
  }) async {
    final data = {
      'user_id': userId,
      'front_id_url': frontIdUrl,
      'back_id_url': backIdUrl,
      'selfie_url': selfieUrl,
      'status': IdentityVerificationStatus.pending.value,
      'submitted_at': DateTime.now().toIso8601String(),
    };

    await _client
        .from(SupabaseTable.identity_verifications.name)
        .upsert(data, onConflict: 'user_id');
  }

  // ============================================
  // UPDATE PROFILE VERIFICATION STATUS
  // ============================================
  Future<void> _updateProfileVerificationStatus({
    required String userId,
    required IdentityVerificationStatus status,
  }) async {
    await _client
        .from(SupabaseTable.profiles.name)
        .update({
          'identity_verification_status': status.value,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  // ============================================
  // GET VERIFICATION STATUS
  // ============================================
  Future<IdentityVerificationModel?> getVerificationStatus() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _client
          .from(SupabaseTable.identity_verifications.name)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return IdentityVerificationModel.fromJson(response);
    } catch (e) {
      log('Error getting verification status: $e');
      return null;
    }
  }

  // ============================================
  // RESUBMIT VERIFICATION (After Rejection)
  // ============================================
  Future<IdentityVerificationResult> resubmitVerification({
    File? frontId,
    File? backId,
    File? selfie,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return IdentityVerificationResult.error('User not authenticated');
      }

      // Get existing verification
      final existing = await getVerificationStatus();
      if (existing == null) {
        return IdentityVerificationResult.error(
          'No existing verification found',
        );
      }

      // Only allow resubmission if rejected
      if (existing.status != IdentityVerificationStatus.rejected) {
        return IdentityVerificationResult.error(
          'Can only resubmit rejected verifications',
        );
      }

      String? frontIdUrl = existing.frontIdUrl;
      String? backIdUrl = existing.backIdUrl;
      String? selfieUrl = existing.selfieUrl;

      // Upload new documents if provided
      if (frontId != null) {
        frontIdUrl = await _uploadDocument(
          file: frontId,
          userId: userId,
          documentType: 'front_id',
        );
      }

      if (backId != null) {
        backIdUrl = await _uploadDocument(
          file: backId,
          userId: userId,
          documentType: 'back_id',
        );
      }

      if (selfie != null) {
        selfieUrl = await _uploadDocument(
          file: selfie,
          userId: userId,
          documentType: 'selfie',
        );
      }

      // Update record
      await _saveVerificationRecord(
        userId: userId,
        frontIdUrl: frontIdUrl!,
        backIdUrl: backIdUrl!,
        selfieUrl: selfieUrl!,
      );

      // Update profile status
      await _updateProfileVerificationStatus(
        userId: userId,
        status: IdentityVerificationStatus.pending,
      );

      return IdentityVerificationResult.success(
        message: 'Documents resubmitted successfully',
      );
    } catch (e) {
      log('Error resubmitting verification: $e');
      return IdentityVerificationResult.error(
        'Failed to resubmit verification: ${e.toString()}',
      );
    }
  }
}

// ============================================
// RESULT CLASS
// ============================================
class IdentityVerificationResult {
  final bool isSuccess;
  final String? message;
  final String? errorMessage;

  IdentityVerificationResult({
    required this.isSuccess,
    this.message,
    this.errorMessage,
  });

  factory IdentityVerificationResult.success({String? message}) {
    return IdentityVerificationResult(isSuccess: true, message: message);
  }

  factory IdentityVerificationResult.error(String errorMessage) {
    return IdentityVerificationResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
