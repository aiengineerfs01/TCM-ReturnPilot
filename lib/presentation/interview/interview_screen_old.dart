import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/chat_message.dart';
import 'package:tcm_return_pilot/presentation/interview/controller/interview_controller.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/chat_bubble.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/typing_indicator.dart';
import 'package:tcm_return_pilot/widgets/app_logo.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';

class InterviewScreenOld extends StatefulWidget {
  const InterviewScreenOld({super.key});

  static const String routeName = 'InterviewScreen';
  static const String routePath = '/interviewScreen';

  @override
  State<InterviewScreenOld> createState() => _InterviewScreenOldState();
}

class _InterviewScreenOldState extends State<InterviewScreenOld> {
  final InterviewController controller = Get.put(InterviewController());
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   controller.startInterview();
    // });
    // textController.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10),
                  child: BackArrow(),
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
            SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.jumpTo(
                      scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(top: 12),
                  itemCount:
                      controller.messages.length +
                      (controller.isTyping.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.messages.length) {
                      return const TypingIndicator();
                    }

                    final ChatMessage message = controller.messages[index];
                    return ChatBubble(message: message);
                  },
                );
              }),
            ),
            _buildInputBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(AppTheme theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Expanded(
            //   child: TextField(
            //     controller: textController,
            //     style: const TextStyle(fontSize: 16),
            //     decoration: const InputDecoration(
            //       hintText: "Type your response...",
            //       border: InputBorder.none,
            //     ),
            //   ),
            // ),
            Expanded(
              child: CustomTextField(
                hintText: 'Type your response...',
                controller: textController,
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (textController.text.trim().isNotEmpty) {
                  controller.handleUserResponse(textController.text.trim());
                  textController.clear();
                }
              },
              child: Image.asset(
                Strings.sendIcon,
                width: 42,
                height: 42,
                color: textController.text.trim().isNotEmpty
                    ? theme.primary
                    : Colors.grey,
              ),
            ),
            // IconButton(
            //   icon: const Icon(Icons.send_rounded),
            //   color: theme.primary,
            //   onPressed: () {
            //     if (textController.text.trim().isNotEmpty) {
            //       controller.handleUserResponse(textController.text.trim());
            //       textController.clear();
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
