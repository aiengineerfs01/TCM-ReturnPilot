import 'package:flutter/material.dart';

class TaxReportsCard extends StatelessWidget {
  const TaxReportsCard({
    super.key,
    this.reports = const [],
  });

  final List<TaxReportItem> reports;

  static List<TaxReportItem> get defaultReports => [
        const TaxReportItem(
          title: '2025 Return',
          hasDownload: true,
          badge: 'IN PROGRESS',
        ),
        const TaxReportItem(
          title: '2024 Return',
          hasDownload: true,
        ),
        const TaxReportItem(
          title: 'Uploaded Documents',
          hasDownload: false,
        ),
        const TaxReportItem(
          title: 'E-File Authorization',
          hasDownload: true,
          badge: '8879',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final displayReports = reports.isEmpty ? defaultReports : reports;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 19, 5, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11.05),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'My Tax Reports',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 16 / 20,
              color: Color(0xFF0B2D6C),
            ),
          ),
          const SizedBox(height: 20),

          // Report items
          ...displayReports.map(
            (report) => _TaxReportTile(report: report),
          ),
        ],
      ),
    );
  }
}

class TaxReportItem {
  const TaxReportItem({
    required this.title,
    this.hasDownload = false,
    this.badge,
    this.onTap,
  });

  final String title;
  final bool hasDownload;
  final String? badge;
  final VoidCallback? onTap;
}

class _TaxReportTile extends StatelessWidget {
  const _TaxReportTile({required this.report});

  final TaxReportItem report;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: InkWell(
        onTap: report.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            // Bullet dot (outer light + inner dark)
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B2D6C),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),

            // Title (underlined, teal)
            Text(
              report.title,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 20 / 14,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF00A38C),
                color: Color(0xFF00A38C),
              ),
            ),

            // Download icon
            if (report.hasDownload) ...[
              const SizedBox(width: 7),
              const Icon(
                Icons.download_rounded,
                size: 17,
                color: Color(0xFF00A38C),
              ),
            ],

            // Badge
            if (report.badge != null) ...[
              const SizedBox(width: 7),
              Text(
                '(${report.badge})',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  height: 20 / 10,
                  letterSpacing: 0.42,
                  color: Color(0xFF696D6E),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
