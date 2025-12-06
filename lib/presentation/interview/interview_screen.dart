import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/chat_message.dart';
import 'package:tcm_return_pilot/presentation/interview/controller/interview_controller.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/chat_bubble.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/typing_indicator.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/utils/extensions.dart';
import 'package:tcm_return_pilot/widgets/app_logo.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';
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
  final InterviewController controller = Get.put(InterviewController());
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10),
                  child: const BackArrow(),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AppLogo(color: theme.primary, width: 300),
                    ),
                    Text(
                      'TCM Interview',
                      style: poppinsSemiBold.copyWith(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Chat Messages
            Expanded(
              child: Obx(() {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return controller.isChatLoading
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
                            controller.messages.length +
                            (controller.isTyping.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.messages.length) {
                            return const TypingIndicator();
                          }
                          final ChatMessage message =
                              controller.messages[index];
                          return ChatBubble(message: message);
                        },
                      );
              }),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (uploadedFiles.isNotEmpty)
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
    );
  }

  Widget _buildInputBar(AppTheme theme) {
    final bool canSend = textController.text.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        await controller.handleUserResponse(
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
                      await controller.handleUserResponse(
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
      ),
    );
  }
}
