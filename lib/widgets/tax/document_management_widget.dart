/// =============================================================================
/// Document Management Widget
///
/// A reusable widget for managing tax documents (upload, replace, delete).
/// Can be embedded in interview screen or review screen.
///
/// Features:
/// - Upload new documents
/// - View uploaded documents
/// - Replace existing documents
/// - Delete documents
/// - Document type detection
/// - Processing status indicators
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/services/tax/auto_fill_orchestrator_service.dart';

/// Compact document management widget for use within interview screen
class DocumentManagementWidget extends StatelessWidget {
  final AutoFillOrchestratorService? autoFillService;
  final bool isCollapsed;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;

  const DocumentManagementWidget({
    super.key,
    this.autoFillService,
    this.isCollapsed = true,
    this.onExpand,
    this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (autoFillService == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: isCollapsed
          ? _buildCollapsedView(theme)
          : _buildExpandedView(context, theme),
    );
  }

  Widget _buildCollapsedView(AppTheme theme) {
    final documents = autoFillService?.uploadedDocuments ?? [];

    return InkWell(
      onTap: onExpand,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.folder_outlined, color: theme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documents',
                    style: poppinsMedium.copyWith(
                      fontSize: 14,
                      color: theme.primaryText,
                    ),
                  ),
                  Text(
                    documents.isEmpty
                        ? 'No documents uploaded'
                        : '${documents.length} document${documents.length == 1 ? '' : 's'} uploaded',
                    style: poppinsRegular.copyWith(
                      fontSize: 12,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.expand_more, color: theme.secondaryText),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context, AppTheme theme) {
    final documents = autoFillService?.uploadedDocuments ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        InkWell(
          onTap: onCollapse,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.folder_open, color: theme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Documents',
                    style: poppinsMedium.copyWith(
                      fontSize: 14,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                Icon(Icons.expand_less, color: theme.secondaryText),
              ],
            ),
          ),
        ),

        const Divider(height: 1),

        // Document list
        if (documents.isEmpty)
          _buildEmptyDocuments(theme)
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: documents.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) =>
                  _buildDocumentItem(ctx, theme, documents[index]),
            ),
          ),

        // Upload button
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _uploadDocument(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Upload Document',
                style: poppinsMedium.copyWith(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyDocuments(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: theme.secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No documents yet',
            style: poppinsMedium.copyWith(
              fontSize: 14,
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload W-2, 1099, or other tax documents',
            style: poppinsRegular.copyWith(
              fontSize: 12,
              color: theme.secondaryText.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, AppTheme theme, UploadedDocument document) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getDocumentColor(document.documentType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getDocumentIcon(document.documentType),
              color: _getDocumentColor(document.documentType),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: poppinsMedium.copyWith(
                    fontSize: 13,
                    color: theme.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      document.documentType.displayName,
                      style: poppinsRegular.copyWith(
                        fontSize: 11,
                        color: theme.secondaryText,
                      ),
                    ),
                    if (document.isProcessed) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle, size: 12, color: Colors.green),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.secondaryText, size: 20),
            onSelected: (value) {
              if (value == 'replace') {
                _replaceDocument(document);
              } else if (value == 'delete') {
                _deleteDocument(context, document);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'replace',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 18),
                    SizedBox(width: 8),
                    Text('Replace'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.w2:
        return Icons.work;
      case DocumentType.form1099Int:
      case DocumentType.form1099Div:
      case DocumentType.form1099Nec:
      case DocumentType.form1099G:
      case DocumentType.form1099R:
      case DocumentType.form1099Misc:
      case DocumentType.form1099B:
      case DocumentType.form1099Ssa:
        return Icons.receipt_long;
      case DocumentType.governmentId:
        return Icons.badge;
      case DocumentType.bankStatement:
        return Icons.account_balance;
      case DocumentType.priorYearReturn:
        return Icons.history;
      case DocumentType.scheduleC:
      case DocumentType.scheduleE:
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.w2:
        return Colors.blue;
      case DocumentType.form1099Int:
      case DocumentType.form1099Div:
        return Colors.green;
      case DocumentType.form1099Nec:
        return Colors.orange;
      case DocumentType.governmentId:
        return Colors.purple;
      case DocumentType.bankStatement:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Future<void> _uploadDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      // Show document type selector
      final docType = await _showDocumentTypeDialog(context);
      if (docType != null) {
        await autoFillService?.uploadDocument(
          file: file,
          documentType: docType,
        );
      }
    }
  }

  Future<DocumentType?> _showDocumentTypeDialog(BuildContext context) async {
    return showDialog<DocumentType>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Document Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: DocumentType.values.map((type) {
              return ListTile(
                leading: Icon(
                  _getDocumentIcon(type),
                  color: _getDocumentColor(type),
                ),
                title: Text(type.displayName),
                onTap: () => Navigator.pop(ctx, type),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _replaceDocument(UploadedDocument document) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      await autoFillService?.replaceDocument(
        existingDocumentId: document.id,
        newFile: file,
      );
    }
  }

  Future<void> _deleteDocument(BuildContext context, UploadedDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${document.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await autoFillService?.deleteDocument(document.id);
    }
  }
}

/// Full-page document management screen
class DocumentManagementScreen extends StatelessWidget {
  const DocumentManagementScreen({super.key});

  static const String routeName = 'DocumentManagementScreen';
  static const String routePath = '/documents';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    // TODO: Pass autoFillService via constructor or provider when available
    AutoFillOrchestratorService? autoFillService;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Tax Documents',
          style: poppinsSemiBold.copyWith(
            fontSize: 18,
            color: theme.primaryText,
          ),
        ),
        backgroundColor: theme.secondaryBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _uploadDocument(context, autoFillService),
          ),
        ],
      ),
      body: autoFillService == null
          ? _buildNoService(theme)
          : _buildDocumentList(context, theme, autoFillService),
    );
  }

  Widget _buildNoService(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off, size: 64, color: theme.secondaryText),
          const SizedBox(height: 16),
          Text(
            'Document service unavailable',
            style: poppinsMedium.copyWith(
              fontSize: 16,
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please start a tax return first',
            style: poppinsRegular.copyWith(
              fontSize: 14,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList(
      BuildContext context, AppTheme theme, AutoFillOrchestratorService autoFillService) {
    final documents = autoFillService.uploadedDocuments;

    if (documents.isEmpty) {
      return _buildEmptyState(context, theme, autoFillService);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (ctx, index) {
        final document = documents[index];
        return _DocumentCard(
          document: document,
          onReplace: () => _replaceDocument(autoFillService, document),
          onDelete: () => _deleteDocument(ctx, autoFillService, document),
        );
      },
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppTheme theme, AutoFillOrchestratorService autoFillService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 80,
            color: theme.secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No documents uploaded',
            style: poppinsSemiBold.copyWith(
              fontSize: 18,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your W-2, 1099, and other tax documents\nto auto-fill your return',
            style: poppinsRegular.copyWith(
              fontSize: 14,
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _uploadDocument(context, autoFillService),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument(
      BuildContext context, AutoFillOrchestratorService? autoFillService) async {
    if (autoFillService == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      // Show document type selector
      final docType = await _showDocumentTypeDialog(context);
      if (docType != null) {
        await autoFillService.uploadDocument(
          file: file,
          documentType: docType,
        );
      }
    }
  }

  Future<DocumentType?> _showDocumentTypeDialog(BuildContext context) async {
    return showDialog<DocumentType>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Document Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: DocumentType.values.map((type) => ListTile(
              title: Text(type.displayName),
              onTap: () => Navigator.pop(ctx, type),
            )).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _replaceDocument(
      AutoFillOrchestratorService autoFillService,
      UploadedDocument document) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      await autoFillService.replaceDocument(
        existingDocumentId: document.id,
        newFile: file,
      );
    }
  }

  Future<void> _deleteDocument(
      BuildContext context,
      AutoFillOrchestratorService autoFillService,
      UploadedDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${document.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await autoFillService.deleteDocument(document.id);
    }
  }
}

/// Individual document card widget
class _DocumentCard extends StatelessWidget {
  final UploadedDocument document;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Document header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getDocumentColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getDocumentIcon(),
                    color: _getDocumentColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.fileName,
                        style: poppinsMedium.copyWith(
                          fontSize: 14,
                          color: theme.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDocumentColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              document.documentType.displayName,
                              style: poppinsMedium.copyWith(
                                fontSize: 10,
                                color: _getDocumentColor(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (document.isProcessed)
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 14, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  'Processed',
                                  style: poppinsRegular.copyWith(
                                    fontSize: 11,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: theme.secondaryText,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Processing...',
                                  style: poppinsRegular.copyWith(
                                    fontSize: 11,
                                    color: theme.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onReplace,
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Replace'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: theme.alternate.withOpacity(0.3),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon() {
    switch (document.documentType) {
      case DocumentType.w2:
        return Icons.work;
      case DocumentType.form1099Int:
      case DocumentType.form1099Div:
      case DocumentType.form1099Nec:
      case DocumentType.form1099G:
      case DocumentType.form1099R:
      case DocumentType.form1099Misc:
      case DocumentType.form1099B:
      case DocumentType.form1099Ssa:
        return Icons.receipt_long;
      case DocumentType.governmentId:
        return Icons.badge;
      case DocumentType.bankStatement:
        return Icons.account_balance;
      case DocumentType.priorYearReturn:
        return Icons.history;
      case DocumentType.scheduleC:
      case DocumentType.scheduleE:
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor() {
    switch (document.documentType) {
      case DocumentType.w2:
        return Colors.blue;
      case DocumentType.form1099Int:
      case DocumentType.form1099Div:
        return Colors.green;
      case DocumentType.form1099Nec:
        return Colors.orange;
      case DocumentType.governmentId:
        return Colors.purple;
      case DocumentType.bankStatement:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
