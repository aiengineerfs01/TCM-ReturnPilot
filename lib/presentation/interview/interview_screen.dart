import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/chat_message.dart';
import 'package:tcm_return_pilot/presentation/interview/cubit/interview_cubit.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/chat_bubble.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/typing_indicator.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/utils/extensions.dart';
import 'package:tcm_return_pilot/widgets/app_top_bar.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';
import 'package:file_picker/file_picker.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  static const String routeName = 'InterviewScreen';
  static const String routePath = '/interviewScreen';

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<PlatformFile> uploadedFiles = [];

  @override
  void initState() {
    super.initState();

    // Future.delayed(const Duration(milliseconds: 500), () {
    //   controller.startInterview(); // This will send the first AI message
    // });

    textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // Optional: Add file picker for W-2, 1099, etc.
  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      uploadedFiles.addAll(result.files);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return BlocProvider<InterviewCubit>(
      create: (_) => InterviewCubit(),
      child: Builder(
        builder: (context) => Scaffold(
      body: Column(
        children: [
          // Header
          AppTopBar(),

          // Chat Messages
          Expanded(
            child: BlocBuilder<InterviewCubit, InterviewState>(
              builder: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });

              return state.chatLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            'Loading chat...',
                            style: poppinsRegular.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(top: 12),
                      itemCount:
                          state.messages.length +
                          1 + // +1 for header
                          (state.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        // First item is the header
                        if (index == 0) {
                          return _buildChatHeader(theme);
                        }

                        // Adjust index for messages (subtract 1 for header)
                        final messageIndex = index - 1;

                        // Typing indicator at the end
                        if (messageIndex == state.messages.length) {
                          return const TypingIndicator();
                        }

                        final ChatMessage message =
                            state.messages[messageIndex];
                        return ChatBubble(message: message);
                      },
                    );
              },
            ),
          ),

          if (uploadedFiles.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    child: Wrap(
                      spacing: 8,
                      children: uploadedFiles.map((file) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            file.name.fileExt == 'pdf'
                                ? Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.error,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.picture_as_pdf,
                                      color: theme.error,
                                      size: 40,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(file.path!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  uploadedFiles.remove(file);
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: theme.accent2,
                                  shape: BoxShape.circle,
                                ),
                                margin: EdgeInsets.all(3),
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                    color: theme.accent1,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

          // Input Bar
          _buildInputBar(theme),
        ],
      ),
        ),
      ),
    );
  }

  /// Build the scrollable chat header with title and greeting
  Widget _buildChatHeader(AppTheme theme) {
    // Get user's first name from Supabase
    final user = SupabaseService.client.auth.currentUser;
    final userData = user?.userMetadata;
    String firstName = 'there';

    if (userData != null) {
      firstName =
          userData['first_name'] ??
          userData['display_name']?.toString().split(' ').first ??
          userData['name']?.toString().split(' ').first ??
          'there';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TCM Interview',
            style: poppinsBold.copyWith(fontSize: 24, color: theme.primaryText),
          ),
          const SizedBox(height: 4),
          Text(
            'Hi $firstName! 👋',
            style: poppinsRegular.copyWith(
              fontSize: 16,
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInputBar(AppTheme theme) {
    final bool canSend = textController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 26,
      ),
      child: Row(
        children: [
          // File Upload Button (W-2, ID, etc.)
          GestureDetector(
            onTap: _pickAndUploadFile,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.attach_file, color: theme.accent1),
            ),
          ),
          const SizedBox(width: 8),
    
          // Text Input
          Expanded(
            child: CustomTextField(
              hintText: 'Type your response...',
              controller: textController,
              onSubmit: canSend
                  ? (_) async {
                      context.read<InterviewCubit>().handleUserResponse(
                        textController.text.trim(),
                        files: List.of(uploadedFiles),
                      );
                      textController.clear();
                      uploadedFiles.clear();
                      setState(() {});
                    }
                  : null,
            ),
          ),
          const SizedBox(width: 10),
    
          // Send Button
          GestureDetector(
            onTap: canSend
                ? () async {
                    context.read<InterviewCubit>().handleUserResponse(
                      textController.text.trim(),
                      files: List.of(uploadedFiles),
                    );
                    textController.clear();
                    uploadedFiles.clear();
                    setState(() {});
                  }
                : null,
            child: Image.asset(
              Strings.sendIcon,
              width: 46,
              height: 46,
              color: canSend ? theme.primary : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
