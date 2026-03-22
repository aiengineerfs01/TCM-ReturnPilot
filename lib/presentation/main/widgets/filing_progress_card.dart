import 'package:flutter/material.dart';

class FilingProgressCard extends StatelessWidget {
  const FilingProgressCard({
    super.key,
    this.items = const [],
  });

  final List<FilingProgressItem> items;

  static List<FilingProgressItem> get defaultItems => [
        const FilingProgressItem(
          title: 'W2 Uploaded',
          progress: 1.0,
          isCompleted: true,
        ),
        const FilingProgressItem(
          title: 'ID Verification',
          progress: 0.59,
          isCompleted: false,
        ),
        const FilingProgressItem(
          title: 'Sign E-File Authorization',
          progress: 0.0,
          isCompleted: false,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final displayItems = items.isEmpty ? defaultItems : items;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(5, 19, 5, 13),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Filing Progress',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                height: 16 / 20,
                color: Color(0xFF0B2D6C),
              ),
            ),
            const SizedBox(height: 20),

            // Progress items
            ...displayItems.map(
              (item) => _FilingProgressTile(item: item),
            ),
          ],
        ),
      ),
    );
  }
}

class FilingProgressItem {
  const FilingProgressItem({
    required this.title,
    required this.progress,
    required this.isCompleted,
  });

  final String title;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
}

class _FilingProgressTile extends StatelessWidget {
  const _FilingProgressTile({required this.item});

  final FilingProgressItem item;

  @override
  Widget build(BuildContext context) {
    final percentage = (item.progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(229, 229, 234, 0.72),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            SizedBox(
              width: 16,
              height: 16,
              child: item.isCompleted
                  ? const Icon(
                      Icons.check_box,
                      size: 16,
                      color: Color(0xFF0B2D6C),
                    )
                  : const Icon(
                      Icons.check_box_outline_blank,
                      size: 16,
                      color: Color(0xFF0B2D6C),
                    ),
            ),
            const SizedBox(width: 10),

            // Title + Progress bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 14 / 12,
                      color: Color(0xFF0B2D6C),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Progress bar + percentage
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22.98),
                          child: SizedBox(
                            height: 8,
                            child: LinearProgressIndicator(
                              value: item.progress,
                              backgroundColor: const Color(0xFFD9D9D9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF00A38C),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 10.86,
                          height: 13 / 10.86,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
