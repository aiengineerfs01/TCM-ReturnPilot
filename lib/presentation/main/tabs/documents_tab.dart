import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

/// Documents tab content for the main navigation screen.
/// Placeholder for document management functionality.
class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Documents',
              style: poppinsSemiBold.copyWith(
                fontSize: 28,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your tax documents',
              style: poppinsRegular.copyWith(
                fontSize: 16,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 40),

            // Placeholder content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80,
                      color: theme.secondaryText.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No documents yet',
                      style: poppinsMedium.copyWith(
                        fontSize: 18,
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your tax documents to get started',
                      style: poppinsRegular.copyWith(
                        fontSize: 14,
                        color: theme.secondaryText.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
