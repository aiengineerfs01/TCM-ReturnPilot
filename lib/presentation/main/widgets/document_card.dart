import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tcm_return_pilot/constants/strings.dart';

enum DocumentStatus { primary, uploaded, failed, pending }

class AttachedFile {
  final String name;
  final String size;

  const AttachedFile({required this.name, required this.size});
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.status,
    this.attachedFiles = const [],
    this.onAddDocument,
  });

  final String title;
  final String subtitle;
  final DocumentStatus status;
  final List<AttachedFile> attachedFiles;
  final VoidCallback? onAddDocument;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD1E3E0), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              children: [
                // Top row: icon + title/subtitle + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload file icon
                    Image.asset(Strings.uploadFileIcon, width: 80, height: 80),
                    const SizedBox(width: 12),

                    // Title, subtitle & Add Document button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF212021),
                              ),
                            ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            // + Add Document button
                            GestureDetector(
                              onTap: onAddDocument,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B2D6C),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add Document',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Status badge
                    _StatusBadge(status: status),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Attached files (shown below the card)
        if (attachedFiles.isNotEmpty)
          ...attachedFiles.map(
            (file) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Filename & size
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            file.size,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF78828A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action icons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.visibility_outlined,
                            color: Color(0xFF0B2D6C),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF0B2D6C),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFF0B2D6C),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DocumentStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DocumentStatus.pending:
        return _buildOutlinedBadge(
          svgAsset: Strings.pendingIcon,
          label: 'Pending',
          color: const Color(0xFF4B8AFF),
        );
      case DocumentStatus.primary:
        return _buildOutlinedBadge(
          svgAsset: Strings.pendingIcon,
          label: 'Primary',
          color: const Color(0xFF4B8AFF),
        );
      case DocumentStatus.uploaded:
        return _buildOutlinedBadge(
          svgAsset: Strings.uploadedIcon,
          label: 'Uploaded',
          color: const Color(0xFF14AE5C),
        );
      case DocumentStatus.failed:
        return _buildOutlinedBadge(
          svgAsset: Strings.failedIcon,
          label: 'Failed',
          color: const Color(0xFFFF4343),
        );
    }
  }

  Widget _buildOutlinedBadge({
    required String svgAsset,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(svgAsset, width: 12, height: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
