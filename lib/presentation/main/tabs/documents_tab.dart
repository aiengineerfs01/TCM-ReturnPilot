import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/app_colors.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/presentation/main/widgets/document_card.dart';

class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _navyBlue = Color(0xFF0B2D6C);
  static const _teal = Color(0xFF00A38C);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBackground,
      child: Column(
        children: [
          // ─── Navy header ───
          Container(
            width: double.infinity,
            color: _navyBlue,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        Strings.returnPilotLogoPng,
                        height: 50,
                      ),
                    ),
                  ),

                  // Sub-header row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 18),
                    child: Row(
                      children: [
                        Text(
                          'Tax Year · 2025',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Tax Documents',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // Handle save & exit
                          },
                          child: const Text(
                            'Save & Exit',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: _teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Tab bar ───
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: _navyBlue,
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              indicatorColor: _teal,
              indicatorWeight: 3,
              dividerColor: const Color(0xFFE3E9ED),
              tabs: const [
                Tab(text: 'Primary Documents'),
                Tab(text: 'Other Documents'),
              ],
            ),
          ),

          // ─── Tab content ───
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPrimaryDocuments(),
                _buildOtherDocuments(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryDocuments() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info text
          Text(
            'You can add or replace documents at anytime.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: const Color(0xFF78828A).withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),

          // W-2 Form
          const DocumentCard(
            title: 'W-2 Form',
            subtitle: '(Description)',
            status: DocumentStatus.pending,
          ),
          const SizedBox(height: 14),

          // 1099 (Any Type)
          const DocumentCard(
            title: '1099 (Any Type)',
            subtitle: '(Optional)',
            status: DocumentStatus.uploaded,
            attachedFiles: [
              AttachedFile(name: '1099 document.pdf', size: '5.5mb'),
            ],
          ),
          const SizedBox(height: 14),

          // Photo ID
          const DocumentCard(
            title: 'Photo ID',
            subtitle: '(Description/ID)',
            status: DocumentStatus.failed,
            attachedFiles: [
              AttachedFile(name: '1099 document.pdf', size: '5.5mb'),
            ],
          ),
          const SizedBox(height: 14),

          // Prior-Year Tax Return
          const DocumentCard(
            title: 'Prior-Year Tax Return',
            subtitle: '(Optional)',
            status: DocumentStatus.pending,
          ),
          const SizedBox(height: 14),

          // SSA-1099 (Social Security)
          const DocumentCard(
            title: 'SSA-1099 (Social Security)',
            subtitle: '',
            status: DocumentStatus.pending,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOtherDocuments() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 60,
            color: Color(0xFFBCC3CB),
          ),
          SizedBox(height: 12),
          Text(
            'No other documents',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
