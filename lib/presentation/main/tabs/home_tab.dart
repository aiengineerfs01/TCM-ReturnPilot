import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/presentation/main/widgets/filing_progress_card.dart';
import 'package:tcm_return_pilot/presentation/main/widgets/home_header.dart';
import 'package:tcm_return_pilot/presentation/main/widgets/refund_info_cards.dart';
import 'package:tcm_return_pilot/presentation/main/widgets/tax_reports_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E5EA),
      child: Column(
        children: [
          // Dark navy header
          const HomeHeader(userName: 'Mehak'),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
              child: Column(
                children: [
                  // Refund info cards (side by side)
                  RefundInfoCards(),
                  SizedBox(height: 20),

                  // Filing Progress
                  FilingProgressCard(),
                  SizedBox(height: 20),

                  // My Tax Reports
                  TaxReportsCard(),
                  SizedBox(height: 20),

                  // Start Interview Button
                  SizedBox(
                    width: double.infinity,
                    height: 53,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/return-year-selection');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B2D6C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Start My Tax Return',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15.55,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
