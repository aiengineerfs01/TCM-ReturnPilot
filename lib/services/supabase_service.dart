// ignore_for_file: constant_identifier_names

import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/utils/extensions.dart';

/// Enum for your Supabase table names — keeps your code organized
enum SupabaseTable { users, profile, chat_thread, chat_messages, chat_media }

/// A clean and professional Supabase service for basic CRUD operations
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  static SupabaseClient get client => Supabase.instance.client;

  /// Insert a new row into a given table
  Future<void> insert({
    required SupabaseTable table,
    required Map<String, dynamic> data,
  }) async {
    await _client.from(_tableName(table)).insert(data);
  }

  /// Update existing rows in a given table based on filters
  Future<PostgrestResponse> update({
    required SupabaseTable table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
  }) async {
    final response = await _client
        .from(_tableName(table))
        .update(data)
        .eq(column, value);
    return response;
  }

  /// Delete rows from a given table based on filters
  Future<PostgrestResponse> delete({
    required SupabaseTable table,
    required String column,
    required dynamic value,
  }) async {
    final response = await _client
        .from(_tableName(table))
        .delete()
        .eq(column, value);
    return response;
  }

  Future<List<Map<String, dynamic>>> getData({
    required SupabaseTable table,
    String? column,
    dynamic value,
  }) async {
    try {
      var query = _client.from(_tableName(table)).select();

      if (column != null && value != null) {
        query = query.eq(column, value);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      log('Database error: ${e.message}');
      return [];
    } catch (e) {
      log('Unexpected error: $e');
      return [];
    }
  }

  /// Real-time subscription to table changes (insert, update, delete)
  void subscribeToTable({
    required SupabaseTable table,
    void Function(Map<String, dynamic> payload)? onInsert,
    void Function(Map<String, dynamic> payload)? onUpdate,
    void Function(Map<String, dynamic> payload)? onDelete,
  }) {
    _client.channel('public:${_tableName(table)}')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: _tableName(table),
        callback: (payload) => onInsert?.call(payload.newRecord),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: _tableName(table),
        callback: (payload) => onUpdate?.call(payload.newRecord),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: _tableName(table),
        callback: (payload) => onDelete?.call(payload.oldRecord),
      )
      ..subscribe();
  }

  /// Helper function to convert enum to actual table name
  String _tableName(SupabaseTable table) => table.name;

  /// Fetch user's tcm_thread_id from Supabase
  Future<String?> getUserTcmThreadId(String userId) async {
    try {
      final result = await _client
          .from(_tableName(SupabaseTable.profile))
          .select('tcm_thread_id')
          .eq('id', userId)
          .single();

      return result['tcm_thread_id'];
    } catch (e) {
      log("❌ getUserTcmThreadId error: $e");
      return null;
    }
  }

  /// Save user's tcm_thread_id into Supabase
  Future<bool> saveUserTcmThreadId(String userId, String threadId) async {
    try {
      await _client
          .from(_tableName(SupabaseTable.profile))
          .update({'tcm_thread_id': threadId})
          .eq('id', userId);

      return true;
    } catch (e) {
      log("❌ saveUserTcmThreadId error: $e");
      return false;
    }
  }

  Future<String?> uploadFileToSupabase(PlatformFile file) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        "User not logged in.".logDebug();
        return null;
      }

      // Create a unique path: users/{uid}/{timestamp}.{ext}
      final fileExt = file.extension ?? "bin";
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.$fileExt";
      final filePath = "users/$uid/$fileName";

      // --- Upload to storage ---
      final uploadResult = await _client.storage
          .from("chat_media")
          .upload(
            filePath,
            File(file.path!),
            fileOptions: FileOptions(upsert: false, metadata: {'owner': uid}),
          );

      // If error (uploadResult is null or empty)
      if (uploadResult.isEmpty) {
        "Upload failed.".logDebug();
        return null;
      }

      // --- Get public URL ---
      final publicUrl = _client.storage
          .from("chat_media")
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      "Supabase upload error: $e".logDebug();
      return null;
    }
  }
}
