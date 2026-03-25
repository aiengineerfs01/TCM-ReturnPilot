import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/chat_message.dart';
import 'package:tcm_return_pilot/utils/extensions.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';
    final theme = AppTheme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isUser ? 50 : 12,
          right: isUser ? 12 : 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? theme.primary : theme.accent1,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachedLocalFiles.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.attachedLocalFiles.map((file) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: file.name.fileExt == 'pdf'
                        ? Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: theme.accent1,
                              border: Border.all(color: theme.error, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: theme.error,
                              size: 40,
                            ),
                          )
                        : Image.file(
                            File(file.path!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
            if (message.attachments.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.attachments.map((file) {
                  return file.id == null || file.url == null
                      ? SizedBox.shrink()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: file.url?.fileExt == 'pdf'
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: theme.accent1,
                                    border: Border.all(
                                      color: theme.error,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: theme.error,
                                    size: 40,
                                  ),
                                )
                              : Image.network(
                                  file.url!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              message.text,
              style: poppinsRegular.copyWith(
                color: isUser ? Colors.white : theme.primaryText,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
