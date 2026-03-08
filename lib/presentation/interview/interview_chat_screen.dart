import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/interview/cubit/interview_cubit.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/chat_bubble.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/typing_indicator.dart';
import 'package:file_picker/file_picker.dart';

/// Interview chat screen widget.
/// This is the actual chat interface for the tax interview.
class InterviewChatScreen extends StatefulWidget {
  const InterviewChatScreen({super.key});

  @override
  State<InterviewChatScreen> createState() => _InterviewChatScreenState();
}

class _InterviewChatScreenState extends State<InterviewChatScreen> {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<PlatformFile> uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

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

    return Column(
      children: [
        // Header
        _buildHeader(theme),

        // Chat Messages
        Expanded(
          child: BlocBuilder<InterviewCubit, InterviewState>(
            builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            if (state.chatLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Loading chat...',
                      style: poppinsRegular.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  state.messages.length +
                  (state.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length &&
                    state.isTyping) {
                  return const TypingIndicator();
                }
                final message = state.messages[index];
                return ChatBubble(message: message);
              },
            );
          },
          ),
        ),

        // Uploaded files preview
        if (uploadedFiles.isNotEmpty) _buildUploadedFilesPreview(theme),

        // Input Area
        _buildInputArea(theme),
      ],
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: theme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Tax Interview',
            style: poppinsSemiBold.copyWith(fontSize: 20, color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Add info or settings
            },
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedFilesPreview(AppTheme theme) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: uploadedFiles.length,
        itemBuilder: (context, index) {
          final file = uploadedFiles[index];
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.borderColor),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.insert_drive_file,
                    color: theme.primary,
                    size: 30,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        uploadedFiles.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  right: 4,
                  child: Text(
                    file.name,
                    style: poppinsRegular.copyWith(
                      fontSize: 8,
                      color: theme.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(AppTheme theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _pickAndUploadFile,
            icon: Icon(Icons.attach_file, color: theme.secondaryText),
          ),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: poppinsRegular.copyWith(color: theme.hintText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: theme.inputFill,
              ),
              style: poppinsRegular.copyWith(color: theme.primaryText),
              maxLines: 4,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<InterviewCubit, InterviewState>(
            builder: (context, state) => IconButton(
              onPressed:
                  state.isTyping ||
                      textController.text.trim().isEmpty
                  ? null
                  : () {
                      final text = textController.text.trim();
                      if (text.isNotEmpty) {
                        context.read<InterviewCubit>().handleUserResponse(text);
                        textController.clear();
                      }
                    },
              icon: Icon(
                Icons.send_rounded,
                color:
                    state.isTyping ||
                        textController.text.trim().isEmpty
                    ? theme.secondaryText.withOpacity(0.5)
                    : theme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
