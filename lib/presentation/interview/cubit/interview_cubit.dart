import 'dart:developer';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:tcm_return_pilot/models/chat_media_model.dart';
import 'package:tcm_return_pilot/models/chat_message.dart';
import 'package:tcm_return_pilot/models/supabase_chat_thread.dart';
import 'package:tcm_return_pilot/services/environment_service.dart';
import 'package:tcm_return_pilot/services/storage_service.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/services/tax/auto_fill_orchestrator_service.dart';
import 'package:tcm_return_pilot/utils/extensions.dart';

// =============================================================================
// Interview State
// =============================================================================

class InterviewState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool chatLoading;
  final String currentReturnId;
  final bool autoFillEnabled;
  final bool interviewCompleted;
  final String extractionStatus;

  const InterviewState({
    this.messages = const [],
    this.isTyping = false,
    this.chatLoading = false,
    this.currentReturnId = '',
    this.autoFillEnabled = true,
    this.interviewCompleted = false,
    this.extractionStatus = '',
  });

  InterviewState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? chatLoading,
    String? currentReturnId,
    bool? autoFillEnabled,
    bool? interviewCompleted,
    String? extractionStatus,
  }) {
    return InterviewState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      chatLoading: chatLoading ?? this.chatLoading,
      currentReturnId: currentReturnId ?? this.currentReturnId,
      autoFillEnabled: autoFillEnabled ?? this.autoFillEnabled,
      interviewCompleted: interviewCompleted ?? this.interviewCompleted,
      extractionStatus: extractionStatus ?? this.extractionStatus,
    );
  }
}

// =============================================================================
// Interview Cubit
// =============================================================================

class InterviewCubit extends Cubit<InterviewState> {
  InterviewCubit() : super(const InterviewState()) {
    _initCubit();
  }

  late OpenAIClient _openai;
  final SupabaseService supabase = SupabaseService();
  final String userId = SupabaseService.client.auth.currentUser!.id;

  SupabaseChatThread? _supabaseChatThread;
  String? _threadId;
  final List<String> _uploadedFileIds = [];
  final List<String> _uploadedSupabaseFileIds = [];
  final Map<String, String> _uploadedFileExt = {};

  // Auto-fill
  AutoFillOrchestratorService? _autoFillService;

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  bool get isChatLoading => state.chatLoading;
  AutoFillProgress? get autoFillProgress => _autoFillService?.progress;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> _initCubit() async {
    OpenAI.apiKey = EnvironmentService.openAIApiKey;
    OpenAI.showLogs = true;
    _openai = OpenAIClient(apiKey: EnvironmentService.openAIApiKey);

    // Initialize auto-fill service
    await _initializeAutoFill();

    // Initialize or retrieve existing thread
    await _initializeThread();
  }

  // ===========================================================================
  // Auto-Fill Initialization
  // ===========================================================================

  Future<void> _initializeAutoFill() async {
    try {
      _autoFillService = AutoFillOrchestratorService();
      await _autoFillService!.init();

      // Check if there's an existing return for this user
      await _loadOrCreateTaxReturn();

      'Auto-fill service initialized'.logDebug();
    } catch (e) {
      'Failed to initialize auto-fill service: $e'.logDebug();
      emit(state.copyWith(autoFillEnabled: false));
    }
  }

  Future<void> _loadOrCreateTaxReturn() async {
    if (_autoFillService == null) return;

    try {
      final existingReturns = await supabase.getData(
        table: SupabaseTable.tax_returns,
        column: 'user_id',
        value: userId,
      );

      final currentYear = DateTime.now().year;
      final draftReturn = existingReturns.cast<Map<String, dynamic>>().where(
        (r) => r['status'] == 'draft' && r['tax_year'] == currentYear,
      ).firstOrNull;

      if (draftReturn != null) {
        emit(state.copyWith(currentReturnId: draftReturn['id']));
        await _autoFillService!.loadExistingReturn(draftReturn['id']);
        'Loaded existing draft return: ${draftReturn['id']}'.logDebug();
      } else {
        final newReturnId = await _autoFillService!.startNewReturn(
          taxYear: currentYear,
        );
        if (newReturnId != null) {
          emit(state.copyWith(currentReturnId: newReturnId));
          'Created new tax return: $newReturnId'.logDebug();
        }
      }
    } catch (e) {
      'Error loading/creating tax return: $e'.logDebug();
    }
  }

  // ===========================================================================
  // Supabase Chat Thread
  // ===========================================================================

  Future<void> createSupbaseChatThread() async {
    try {
      'Creating Supabase chat thread for user: $userId'.logDebug();
      await supabase.insert(
        table: SupabaseTable.chat_thread,
        data: {'thread_id': _threadId, 'user_id': userId},
      );
      'Supabase chat thread created for user: $userId'.logDebug();
      await getSupabaseChatThread();
    } catch (e) {
      'Error creating Supabase chat thread: $e'.logDebug();
    }
  }

  Future<void> getSupabaseChatThread() async {
    try {
      'Getting Supabase chat thread for user: $userId'.logDebug();
      final data = await supabase.getData(
        table: SupabaseTable.chat_thread,
        column: 'user_id',
        value: userId,
      );
      if (data.isEmpty) {
        'No Supabase chat thread found for user: $userId'.logDebug();
        return;
      }
      _supabaseChatThread = SupabaseChatThread.fromJson(data.first);
      'Supabase chat thread data retrieved for user: $userId: $data'.logDebug();
    } catch (e) {
      'Error getting Supabase chat thread: $e'.logDebug();
    }
  }

  Future<void> createSupbaseChatMessage({
    required String content,
    required SenderType sender,
  }) async {
    try {
      'Creating Supabase chat message for user: $userId'.logDebug();
      await supabase.insert(
        table: SupabaseTable.chat_messages,
        data: {
          'thread_id': _threadId,
          'chat_id': _supabaseChatThread?.id,
          'user_id': userId,
          'content': content,
          'sender_type': sender.name,
          'media': _uploadedSupabaseFileIds,
        },
      );
      'Supabase chat message created for user: $userId'.logDebug();
      _uploadedSupabaseFileIds.clear();
    } catch (e) {
      'Error creating Supabase chat message: $e'.logDebug();
    }
  }

  // ===========================================================================
  // Thread Initialization
  // ===========================================================================

  Future<void> loadExistingData() async {
    try {
      emit(state.copyWith(chatLoading: true));
      await getSupabaseChatThread();
      await loadExistingThreadMessages();
    } catch (e) {
      log('Error loading existing data: $e');
    } finally {
      emit(state.copyWith(chatLoading: false));
    }
  }

  Future<void> _initializeThread() async {
    try {
      // 1. Try local threadId first
      String localThread = Preference.tcmThreadId;
      if (localThread.isNotEmpty) {
        _threadId = localThread;
        log('Using local stored thread: $_threadId');
        await loadExistingData();
        return;
      }

      // 2. Check Supabase stored thread
      String? remoteId = await supabase.getUserTcmThreadId(userId);

      if (remoteId != null && remoteId.isNotEmpty) {
        _threadId = remoteId;
        await Preference.setTcmThreadId(remoteId);
        log('Loaded tcm_thread_id from Supabase: $_threadId');
        await loadExistingData();
        return;
      }

      // 3. Nothing exists -> create new thread
      final newThreadId = await _createThread();
      _threadId = newThreadId;

      await Preference.setTcmThreadId(newThreadId);
      await supabase.saveUserTcmThreadId(userId, newThreadId);

      log('Created new tcm_thread_id: $_threadId');

      await createSupbaseChatThread();
      await _sendInitialMessage();
    } catch (e) {
      log('Thread init failed: $e');
    }
  }

  Future<void> loadExistingThreadMessages() async {
    if (_threadId == null || _threadId!.isEmpty) {
      return;
    }

    try {
      final threadMessages = await _openai.listThreadMessages(
        threadId: _threadId!,
      );

      log(threadMessages.toString());

      final newMessages = <ChatMessage>[];
      final ordered = threadMessages.data.reversed;

      for (final msg in ordered) {
        final textContent = msg.content
            .whereType<MessageContentTextObject>()
            .map((c) => c.text.value)
            .join('\n')
            .trim();

        final List<String> attachmentIds =
            msg.attachments?.map((att) => att.fileId ?? '').toList() ?? [];

        final List<ChatMedia> attachedFiles = await Future.wait(
          attachmentIds.map((id) async {
            if (id.isNotEmpty) {
              final media = await getChatMedia(fileId: id);
              return media;
            }
            return ChatMedia.empty();
          }),
        );

        final parsedMessage = ChatMessage(
          id: msg.id,
          sender: msg.role.name == 'assistant' ? 'tcm' : 'user',
          text: textContent,
          timestamp: DateTime.fromMillisecondsSinceEpoch(msg.createdAt * 1000),
          attachments: attachedFiles,
        );

        newMessages.add(parsedMessage);
      }

      emit(state.copyWith(messages: newMessages));
    } catch (e) {
      log('Error loading messages: $e');
    }
  }

  // ===========================================================================
  // Thread & Message Handling
  // ===========================================================================

  Future<String> _createThread() async {
    try {
      final thread = await _openai.createThread();
      return thread.id;
    } catch (e) {
      log('Thread creation error: $e');
      rethrow;
    }
  }

  Future<void> _sendInitialMessage() async {
    final userInitialText = 'Hello!';
    await handleUserResponse(userInitialText);
  }

  void testAddMessage(List<PlatformFile> files) {
    _addMessage('This is a test message from TCM.', isUser: true, files: files);
  }

  Future<void> handleUserResponse(
    String text, {
    List<PlatformFile>? files,
  }) async {
    if (text.trim().isEmpty) return;

    _addMessage(
      text,
      isUser: true,
      files: files != null ? List<PlatformFile>.from(files) : [],
    );

    emit(state.copyWith(isTyping: true));
    await createSupbaseChatMessage(content: text, sender: SenderType.user);

    try {
      // 1. Upload attached files first
      if (files != null && files.isNotEmpty) {
        await uploadDocumentFile(files);
        await _uploadDocumentsToAutoFill(files);
      }

      // 2. Send user message with attachments
      final userMessage = CreateMessageRequest(
        role: MessageRole.user,
        content: CreateMessageRequestContent.text(text),
        attachments: _uploadedFileIds.map((id) {
          final ext = _uploadedFileExt[id] ?? '';
          final isSearchable = [
            'pdf',
            'txt',
            'md',
            'csv',
            'json',
            'docx',
          ].contains(ext);

          return MessageAttachment(
            fileId: id,
            tools: isSearchable
                ? [AssistantTools.fileSearch(type: 'file_search')]
                : [],
          );
        }).toList(),
      );

      await _openai.createThreadMessage(
        threadId: _threadId ?? '',
        request: userMessage,
      );

      _uploadedFileIds.clear();

      // 3. Run the Assistant
      final run = await _openai.createThreadRun(
        threadId: _threadId ?? '',
        request: CreateRunRequest(
          assistantId: EnvironmentService.openAIAssistantId,
        ),
      );

      // 4. Poll for completion and get response
      final response = await _pollForRunCompletion(run.id);

      log('Assistant response: $response');

      final threadMessages = await _openai.listThreadMessages(
        threadId: _threadId!,
      );

      final assistantMessage = threadMessages.data.firstWhere(
        (m) => m.role == MessageRole.assistant && m.runId == run.id,
        orElse: () => threadMessages.data.firstWhere(
          (m) => m.role == MessageRole.assistant,
        ),
      );

      final String reply = assistantMessage.content
          .whereType<MessageContent>()
          .map((c) => c.text)
          .join('\n')
          .trim();

      final displayReply = _filterDisplayMessage(reply);

      _addMessage(displayReply, isUser: false);
      await createSupbaseChatMessage(content: reply, sender: SenderType.tcm);

      // Auto-fill: Process AI response
      await _processAIResponseForAutoFill(reply);
      await _checkInterviewCompletion(reply);
    } catch (e) {
      log('API Error: $e');
      _addMessage('Oops—connection hiccup. Retry your question?', isUser: false);
    } finally {
      emit(state.copyWith(isTyping: false));
    }
  }

  Future<String> _pollForRunCompletion(String runId) async {
    RunObject? run;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 1000));
      run = await _openai.getThreadRun(threadId: _threadId ?? '', runId: runId);

      if (run.status == RunStatus.completed) {
        final messages =
            await _openai.listThreadMessages(threadId: _threadId!);
        final assistantMsg = messages.data
            .firstWhere(
              (m) => m.role == MessageRole.assistant,
              orElse: () => throw Exception('No assistant response'),
            )
            .content
            .first;

        if (assistantMsg.type == ContentType.text.value) {
          return assistantMsg.text;
        }
        return 'Response includes media—check details.';
      }

      if (run.status == RunStatus.failed ||
          run.status == RunStatus.cancelled ||
          run.status == RunStatus.expired) {
        final error = run.lastError?.message ?? 'Unknown issue';
        throw Exception('Run failed: $error');
      }
    }
  }

  // ===========================================================================
  // File Upload
  // ===========================================================================

  Future<void> uploadDocumentFile(List<PlatformFile> files) async {
    try {
      final newIds = <String>[];

      for (var file in files) {
        final uploaded = await OpenAI.instance.file.upload(
          file: File(file.path!),
          purpose: 'assistants',
        );
        newIds.add(uploaded.id);
        _uploadedFileExt[uploaded.id] = file.extension ?? '';

        String? url = await supabase.uploadFileToSupabase(file);
        await insertChatMedia(fileId: uploaded.id, url: url ?? '');
        ChatMedia media = await getChatMedia(fileId: uploaded.id);
        _uploadedSupabaseFileIds.add(media.id.toString());
      }

      _uploadedFileIds.addAll(newIds);
    } catch (e) {
      log('Upload error: $e');
    }
  }

  // ===========================================================================
  // Message Helpers
  // ===========================================================================

  void _addMessage(
    String text, {
    required bool isUser,
    List<PlatformFile>? files,
  }) {
    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(
        ChatMessage(
          text: text,
          timestamp: DateTime.now(),
          id: '',
          sender: isUser ? 'user' : 'tcm',
          attachedLocalFiles: files ?? [],
        ),
      );
    emit(state.copyWith(messages: updatedMessages));
  }

  // ===========================================================================
  // Chat Media
  // ===========================================================================

  Future<void> insertChatMedia({
    required String fileId,
    required String url,
  }) async {
    try {
      'Inserting chat media for user: $userId'.logDebug();
      await supabase.insert(
        table: SupabaseTable.chat_media,
        data: {
          'chat_id': _supabaseChatThread?.id,
          'user_id': userId,
          'user_type': SenderType.user.name,
          'thread_id': _threadId,
          'file_id': fileId,
          'url': url,
        },
      );
      'Chat media inserted for user: $userId'.logDebug();
    } catch (e) {
      'Error creating Supabase chat media: $e'.logDebug();
    }
  }

  Future<ChatMedia> getChatMedia({required String fileId}) async {
    try {
      final data = await supabase.getData(
        table: SupabaseTable.chat_media,
        column: 'file_id',
        value: fileId,
      );
      if (data.isEmpty) {
        'No Chat media found for file: $fileId'.logDebug();
        return ChatMedia.empty();
      }
      ChatMedia media = ChatMedia.fromJson(data.first);
      'Chat media data retrieved for file: $fileId: $data'.logDebug();
      return media;
    } catch (e) {
      'Error getting chat media: $e'.logDebug();
      throw Exception('Error getting chat media: $e');
    }
  }

  // ===========================================================================
  // Auto-Fill Processing
  // ===========================================================================

  Future<void> _processAIResponseForAutoFill(String aiResponse) async {
    if (!state.autoFillEnabled || _autoFillService == null) return;
    if (state.currentReturnId.isEmpty) return;

    try {
      emit(state.copyWith(extractionStatus: 'Processing response...'));

      await _autoFillService!.processAIResponse(aiResponse);

      final progress = _autoFillService!.progress;
      if (progress.overallProgress > 0) {
        emit(state.copyWith(
          extractionStatus:
              'Auto-fill progress: ${(progress.overallProgress * 100).toInt()}%',
        ));
      } else {
        emit(state.copyWith(extractionStatus: ''));
      }

      'AI response processed for auto-fill'.logDebug();
    } catch (e) {
      'Error processing AI response for auto-fill: $e'.logDebug();
      emit(state.copyWith(extractionStatus: ''));
    }
  }

  Future<void> _uploadDocumentsToAutoFill(List<PlatformFile> files) async {
    if (!state.autoFillEnabled || _autoFillService == null) return;

    try {
      for (final file in files) {
        final docType = _inferDocumentType(file.name);

        await _autoFillService!.uploadDocument(
          file: file,
          documentType: docType,
        );

        'Document uploaded to auto-fill: ${file.name}'.logDebug();
      }
    } catch (e) {
      'Error uploading document to auto-fill: $e'.logDebug();
    }
  }

  DocumentType _inferDocumentType(String fileName) {
    final lowerName = fileName.toLowerCase();

    if (lowerName.contains('w2') || lowerName.contains('w-2')) {
      return DocumentType.w2;
    } else if (lowerName.contains('1099-int') ||
        lowerName.contains('1099int')) {
      return DocumentType.form1099Int;
    } else if (lowerName.contains('1099-div') ||
        lowerName.contains('1099div')) {
      return DocumentType.form1099Div;
    } else if (lowerName.contains('1099-nec') ||
        lowerName.contains('1099nec')) {
      return DocumentType.form1099Nec;
    } else if (lowerName.contains('1099-g') || lowerName.contains('1099g')) {
      return DocumentType.form1099G;
    } else if (lowerName.contains('1099-r') || lowerName.contains('1099r')) {
      return DocumentType.form1099R;
    } else if (lowerName.contains('1099')) {
      return DocumentType.form1099Misc;
    } else if (lowerName.contains('id') ||
        lowerName.contains('license') ||
        lowerName.contains('passport')) {
      return DocumentType.governmentId;
    } else if (lowerName.contains('ssa') ||
        lowerName.contains('social security')) {
      return DocumentType.form1099Ssa;
    } else {
      return DocumentType.other;
    }
  }

  String _filterDisplayMessage(String message) {
    var filtered = message;

    filtered = filtered.replaceAll(
      RegExp(r'```json[\s\S]*?```', multiLine: true),
      '',
    );

    filtered = filtered.replaceAll(
      RegExp(
          r'\{[\s\S]*?"(taxpayer_name|ssn|filing_status|w2_income)"[\s\S]*?\}',
          multiLine: true),
      '',
    );

    filtered = filtered.replaceAll('[INTERVIEW_COMPLETE]', '');
    filtered = filtered.replaceAll('[TAX_DATA_FINAL]', '');

    filtered = filtered.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    filtered = filtered.trim();

    if (filtered.isEmpty) {
      return 'Your tax information has been saved! You can now review your return.';
    }

    return filtered;
  }

  Future<void> _checkInterviewCompletion(String aiResponse) async {
    final completionIndicators = [
      '[INTERVIEW_COMPLETE]',
      '[TAX_DATA_FINAL]',
      '"filing_complete": true',
      '"interview_complete": true',
      'your taxes are on the way',
      'all set!',
      'we\'ve processed your',
      'tax return is ready',
      'ready to file',
      'proceed to review',
    ];

    final lowerResponse = aiResponse.toLowerCase();
    final isComplete = completionIndicators.any(
      (indicator) => lowerResponse.contains(indicator.toLowerCase()),
    );

    final hasJsonBlock = aiResponse.contains('```json') ||
        aiResponse.contains('"taxpayer_name"') ||
        aiResponse.contains('"ssn"') ||
        aiResponse.contains('"filing_status"');

    if ((isComplete || hasJsonBlock) && !state.interviewCompleted) {
      emit(state.copyWith(interviewCompleted: true));
      'Interview completion detected!'.logDebug();
      await _finalizeAutoFill();
    }
  }

  Future<void> _finalizeAutoFill() async {
    if (!state.autoFillEnabled || _autoFillService == null) return;

    try {
      emit(state.copyWith(
          extractionStatus: 'Finalizing your tax information...'));

      final result = await _autoFillService!.finalizeInterviewData();

      if (result.success) {
        var status =
            'Data saved! ${result.sectionsCompleted.length} sections completed.';

        if (result.hasPendingReviews) {
          status +=
              ' ${result.sectionsPendingReview.length} sections need review.';
        }

        emit(state.copyWith(extractionStatus: status));

        'Auto-fill finalized successfully'.logDebug();
        'Completed: ${result.sectionsCompleted}'.logDebug();
        'Pending review: ${result.sectionsPendingReview}'.logDebug();
      } else {
        emit(state.copyWith(
            extractionStatus: 'Some data could not be processed.'));
        'Auto-fill finalized with errors: ${result.errors}'.logDebug();
      }
    } catch (e) {
      'Error finalizing auto-fill: $e'.logDebug();
      emit(state.copyWith(extractionStatus: ''));
    }
  }

  // ===========================================================================
  // Public Auto-Fill Accessors
  // ===========================================================================

  AutoFillProgress? getAutoFillProgress() {
    return _autoFillService?.progress;
  }

  Map<String, List<String>> getItemsNeedingReview() {
    return _autoFillService?.getReviewSummary() ?? {};
  }

  String? getTaxReturnId() {
    return state.currentReturnId.isNotEmpty ? state.currentReturnId : null;
  }

  Future<bool> replaceDocument({
    required String existingDocumentId,
    required PlatformFile newFile,
  }) async {
    if (_autoFillService == null) return false;

    try {
      final result = await _autoFillService!.replaceDocument(
        existingDocumentId: existingDocumentId,
        newFile: newFile,
      );

      if (result != null) {
        'Document replaced successfully'.logDebug();
        return true;
      }
      return false;
    } catch (e) {
      'Error replacing document: $e'.logDebug();
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    if (_autoFillService == null) return false;

    try {
      return await _autoFillService!.deleteDocument(documentId);
    } catch (e) {
      'Error deleting document: $e'.logDebug();
      return false;
    }
  }

  List<UploadedDocument> getUploadedDocuments() {
    return _autoFillService?.uploadedDocuments ?? [];
  }
}
