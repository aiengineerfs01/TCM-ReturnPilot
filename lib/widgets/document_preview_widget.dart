import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

// ============================================
// FILE DROP ZONE WIDGET
// ============================================
class FileDropZone extends StatelessWidget {
  final VoidCallback onTap;

  const FileDropZone({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RectDottedBorderOptions(
          color: const Color(0xFF00B894),
          strokeWidth: 1.4,
          dashPattern: const [6, 5],
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          color: AppTheme.of(context).secondaryBackground,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF00B894),
                size: 28,
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: 'Select ',
                      style: poppinsSemiBold.copyWith(
                        fontSize: 14,
                        color: AppTheme.of(context).appGreen,
                      ),
                    ),
                    TextSpan(
                      text: 'Files to Upload',
                      style: poppinsRegular.copyWith(
                        fontSize: 14,
                        color: AppTheme.of(context).primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Max 10 MB files are allowed',
                style: poppinsRegular.copyWith(
                  fontSize: 14,
                  color: AppTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// SELFIE ZONE WIDGET
// ============================================
class SelfieZone extends StatelessWidget {
  final VoidCallback onTap;

  const SelfieZone({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RectDottedBorderOptions(
          color: const Color(0xFF00B894),
          strokeWidth: 1.4,
          dashPattern: const [6, 5],
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          color: AppTheme.of(context).secondaryBackground,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt, color: Color(0xFF00B894), size: 35),
              const SizedBox(height: 10),
              Text(
                'Open camera and take selfie',
                style: poppinsRegular.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// FILE PREVIEW WIDGET
// ============================================
class FilePreviewWidget extends StatelessWidget {
  final File file;
  final String fileName;
  final VoidCallback onRemove;
  final VoidCallback onRetake;

  const FilePreviewWidget({
    super.key,
    required this.file,
    required this.fileName,
    required this.onRemove,
    required this.onRetake,
  });

  bool get _isImage {
    final path = file.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png');
  }

  String get _truncatedFileName {
    if (fileName.length > 25) {
      return '${fileName.substring(0, 22)}...';
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.appGreen, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Preview thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.grey2.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _isImage
                  ? Image.file(file, fit: BoxFit.cover, width: 60, height: 60)
                  : Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red.shade400,
                        size: 30,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _truncatedFileName,
                  style: poppinsMedium.copyWith(
                    fontSize: 14,
                    color: theme.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: theme.appGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Uploaded successfully',
                      style: poppinsRegular.copyWith(
                        fontSize: 12,
                        color: theme.appGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Column(
            children: [
              _ActionButton(
                icon: Icons.refresh,
                color: theme.appGreen,
                onTap: onRetake,
              ),
              const SizedBox(height: 8),
              _ActionButton(
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// SELFIE PREVIEW WIDGET
// ============================================
class SelfiePreviewWidget extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  final VoidCallback onRetake;

  const SelfiePreviewWidget({
    super.key,
    required this.file,
    required this.onRemove,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.appGreen, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selfie preview
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.appGreen, width: 3),
              boxShadow: [
                BoxShadow(
                  color: theme.appGreen.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Success message
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: theme.appGreen, size: 18),
              const SizedBox(width: 6),
              Text(
                'Selfie captured successfully',
                style: poppinsMedium.copyWith(
                  fontSize: 14,
                  color: theme.appGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PillButton(
                icon: Icons.camera_alt,
                label: 'Retake',
                color: theme.appGreen,
                onTap: onRetake,
              ),
              const SizedBox(width: 16),
              _PillButton(
                icon: Icons.delete_outline,
                label: 'Remove',
                color: Colors.red,
                onTap: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// HELPER WIDGETS
// ============================================
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: poppinsMedium.copyWith(fontSize: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
