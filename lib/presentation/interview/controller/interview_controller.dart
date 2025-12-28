import 'dart:developer';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/models/chat_media_model.dart';
import 'package:tcm_return_pilot/models/supabase_chat_thread.dart';
import 'package:tcm_return_pilot/services/environment_service.dart';
import 'package:tcm_return_pilot/models/chat_message.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:tcm_return_pilot/services/storage_service.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/utils/extensions.dart';

class InterviewController extends GetxController {
  late OpenAIClient _openai;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool chatLoading = false.obs;

  final SupabaseService supabase = SupabaseService();
  final userId = SupabaseService.client.auth.currentUser!.id;
  SupabaseChatThread? supabaseChatThread;

  String? _threadId;
  List<String> _uploadedFileIds = []; // File IDs for attachment
  List<String> _uploadedSupabaseFileIds = [];
  final Map<String, String> _uploadedFileExt =
      {}; // File extensions for attachment

  bool get isChatLoading => chatLoading.value;

  @override
  void onInit() async {
    super.onInit();

    OpenAI.apiKey = EnvironmentService.openAIApiKey;
    OpenAI.showLogs = true;
    _openai = OpenAIClient(apiKey: EnvironmentService.openAIApiKey);

    /// Initialize or retrieve existing thread
    await _initializeThread();

    /// IMPORTANT: If this is a new thread → initial message sent already
    /// Now load messages AFTER initial message exists
    // await loadExistingThreadMessages();
  }

  Future<void> createSupbaseChatThread() async {
    try {
      "Creating Supabase chat thread for user: $userId".logDebug();
      await supabase.insert(
        table: SupabaseTable.chat_thread,
        data: {'thread_id': _threadId, 'user_id': userId},
      );
      "Supabase chat thread created for user: $userId".logDebug();
      await getSupabaseChatThread();
    } catch (e) {
      "Error creating Supabase chat thread: $e".logDebug();
    }
  }

  Future<void> getSupabaseChatThread() async {
    try {
      "Getting Supabase chat thread for user: $userId".logDebug();
      final data = await supabase.getData(
        table: SupabaseTable.chat_thread,
        column: 'user_id',
        value: userId,
      );
      if (data.isEmpty) {
        "No Supabase chat thread found for user: $userId".logDebug();
        return;
      }
      supabaseChatThread = SupabaseChatThread.fromJson(data.first);
      "Supabase chat thread data retrieved for user: $userId: $data".logDebug();
    } catch (e) {
      "Error getting Supabase chat thread: $e".logDebug();
    } finally {
      update();
    }
  }

  Future<void> createSupbaseChatMessage({
    required String content,
    required SenderType sender,
  }) async {
    try {
      "Creating Supabase chat message for user: $userId".logDebug();
      await supabase.insert(
        table: SupabaseTable.chat_messages,
        data: {
          'thread_id': _threadId,
          'chat_id': supabaseChatThread?.id,
          'user_id': userId,
          'content': content,
          'sender_type': sender.name,
          'media': _uploadedSupabaseFileIds,
        },
      );
      "Supabase chat message created for user: $userId".logDebug();
      _uploadedSupabaseFileIds.clear();
    } catch (e) {
      "Error creating Supabase chat message: $e".logDebug();
    }
  }

  Future<void> loadExistingData() async {
    try {
      chatLoading.value = true;
      await getSupabaseChatThread();
      await loadExistingThreadMessages();
    } catch (e) {
      log("❌ Error loading existing data: $e");
    } finally {
      chatLoading.value = false;
    }
  }

  Future<void> _initializeThread() async {
    try {
      // 1. Try local threadId first
      String localThread = Preference.tcmThreadId;
      if (localThread.isNotEmpty) {
        _threadId = localThread;
        log("📌 Using local stored thread: $_threadId");
        await loadExistingData();
        return;
      }

      // 2. Check Supabase stored thread
      String? remoteId = await supabase.getUserTcmThreadId(userId);

      if (remoteId != null && remoteId.isNotEmpty) {
        _threadId = remoteId;

        // store locally
        await Preference.setTcmThreadId(remoteId);

        log("📌 Loaded tcm_thread_id from Supabase: $_threadId");
        await loadExistingData();
        return;
      }

      // 3. Nothing exists → create new thread
      final newThreadId = await _createThread();
      _threadId = newThreadId;

      // Save everywhere
      await Preference.setTcmThreadId(newThreadId);
      await supabase.saveUserTcmThreadId(userId, newThreadId);

      log("🆕 Created new tcm_thread_id: $_threadId");

      /// --- creating supbase chat thread entry ---
      await createSupbaseChatThread();

      /// Send initial message to kick off interview
      await _sendInitialMessage();
    } catch (e) {
      log("❌ Thread init failed: $e");
    }
  }

  Future<void> loadExistingThreadMessages() async {
    if (_threadId == null || _threadId!.isEmpty) {
      return; // No previous chat
    }

    // Fetch thread messages from OpenAI
    try {
      final threadMessages = await _openai.listThreadMessages(
        threadId: _threadId!,
      );

      log(threadMessages.toString());

      messages.clear();

      // Reverse so oldest → newest
      final ordered = threadMessages.data.reversed;

      for (final msg in ordered) {
        // msg.content can be text, images, or others
        final textContent = msg.content
            .whereType<MessageContentTextObject>() // only text
            .map((c) => c.text.value)
            .join("\n")
            .trim();

        /// Extract ATTACHMENT FILE IDs (if any)
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
          sender: msg.role.name == "assistant" ? "tcm" : "user",
          text: textContent,
          timestamp: DateTime.fromMillisecondsSinceEpoch(msg.createdAt * 1000),
          attachments: attachedFiles,
          // attachments: attachedFiles
          //     .map((file) => ChatAttachment(data: '', type: ''))
          //     .toList(), // Handle attachments if needed
        );

        messages.add(parsedMessage);
      }

      update(); // For GetX or your state management
    } catch (e) {
      log("Error loading messages: $e");
    }
  }

  /// Create a new thread for conversation context
  Future<String> _createThread() async {
    try {
      final thread = await _openai.createThread();
      return thread.id;
    } catch (e) {
      log('Thread creation error: $e');
      rethrow;
    }
  }

  /// Send welcome message to kick off the interview
  Future<void> _sendInitialMessage() async {
    final userInitialText = "Hello!";
    await handleUserResponse(userInitialText);
  }

  void testAddMessage(List<PlatformFile> files) {
    addMessage("This is a test message from TCM.", isUser: true, files: files);
  }

  /// Handle user text input
  Future<void> handleUserResponse(
    String text, {
    List<PlatformFile>? files,
  }) async {
    if (text.trim().isEmpty) return;

    addMessage(
      text,
      isUser: true,
      files: files != null ? List<PlatformFile>.from(files) : [],
    );

    isTyping.value = true;
    await createSupbaseChatMessage(content: text, sender: SenderType.user);

    try {
      // 1. Upload attached files first
      if (files != null && files.isNotEmpty) {
        await uploadDocumentFile(files);
      }

      // 2. Send user message with attachments
      final userMessage = CreateMessageRequest(
        role: MessageRole.user,
        content: CreateMessageRequestContent.text(text),
        attachments: _uploadedFileIds.map((id) {
          final ext = _uploadedFileExt[id] ?? "";
          final isSearchable = [
            "pdf",
            "txt",
            "md",
            "csv",
            "json",
            "docx",
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

      // Clear files after attach
      _uploadedFileIds.clear();

      // 2. Run the Assistant (your Custom GPT ID)
      final run = await _openai.createThreadRun(
        threadId: _threadId ?? '',
        request: CreateRunRequest(
          assistantId: EnvironmentService.openAIAssistantId,
        ),
      );

      // 3. Poll for completion and get response
      final response = await _pollForRunCompletion(run.id);

      log('Assistant response: $response');

      // Fetch all thread messages
      // Fetch thread messages after run completes
      final threadMessages = await _openai.listThreadMessages(
        threadId: _threadId!,
      );

      // Find assistant message generated for THIS run
      final assistantMessage = threadMessages.data.firstWhere(
        (m) => m.role == MessageRole.assistant && m.runId == run.id,
        orElse: () => threadMessages.data.firstWhere(
          (m) => m.role == MessageRole.assistant,
        ),
      );

      // Extract text only
      final String reply = assistantMessage.content
          .whereType<MessageContent>()
          .map((c) => c.text)
          .join('\n')
          .trim();

      addMessage(reply, isUser: false);
      await createSupbaseChatMessage(content: reply, sender: SenderType.tcm);
    } catch (e) {
      log('API Error: $e');
      addMessage('Oops—connection hiccup. Retry your question?', isUser: false);
    } finally {
      isTyping.value = false;
    }
  }

  /// Poll run status until done
  Future<String> _pollForRunCompletion(String runId) async {
    RunObject? run;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 1000));
      run = await _openai.getThreadRun(threadId: _threadId ?? '', runId: runId);

      if (run.status == RunStatus.completed) {
        final messages = await _openai.listThreadMessages(threadId: _threadId!);
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

  /// Upload file (e.g., W-2 PDF for tax analysis)
  Future<void> uploadDocumentFile(List<PlatformFile> files) async {
    try {
      final newIds = <String>[];

      for (var file in files) {
        /// --- Uploading file to OpenAI ---
        final uploaded = await OpenAI.instance.file.upload(
          file: File(file.path!),
          purpose: "assistants",
        );
        newIds.add(uploaded.id);
        _uploadedFileExt[uploaded.id] = file.extension ?? "";

        /// --- Uploading file to our supabase storage ---
        String? url = await supabase.uploadFileToSupabase(file);
        await insertChatMedia(fileId: uploaded.id, url: url ?? '');
        ChatMedia media = await getChatMedia(fileId: uploaded.id);
        _uploadedSupabaseFileIds.add(media.id.toString());
      }

      // Update only once – avoids concurrent modification
      _uploadedFileIds.addAll(newIds);
    } catch (e) {
      log('Upload error: $e');
    }
  }

  /// Add message to UI list
  void addMessage(
    String text, {
    required bool isUser,
    List<PlatformFile>? files,
  }) {
    messages.add(
      ChatMessage(
        text: text,
        timestamp: DateTime.now(),
        id: '',
        sender: isUser ? 'user' : 'tcm',
        attachedLocalFiles: files ?? [],
      ),
    );
    update();
  }

  Future<void> insertChatMedia({
    required String fileId,
    required String url,
  }) async {
    try {
      "Inserting chat media for user: $userId".logDebug();
      await supabase.insert(
        table: SupabaseTable.chat_media,
        data: {
          'chat_id': supabaseChatThread?.id,
          'user_id': userId,
          'user_type': SenderType.user.name,
          'thread_id': _threadId,
          'file_id': fileId,
          'url': url,
        },
      );
      "Chat media inserted for user: $userId".logDebug();
    } catch (e) {
      "Error creating Supabase chat media: $e".logDebug();
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
        "No Chat media found for file: $fileId".logDebug();
        return ChatMedia.empty();
      }
      ChatMedia media = ChatMedia.fromJson(data.first);
      "Chat media data retrieved for file: $fileId: $data".logDebug();
      return media;
    } catch (e) {
      "Error getting chat media: $e".logDebug();
      throw Exception('Error getting chat media: $e');
    } finally {
      update();
    }
  }

  @override
  void onClose() {
    // Optional: Delete thread/files on close
    super.onClose();
  }
}
