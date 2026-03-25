import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/strings.dart';

/// Status of a tax return for a given year.
enum TaxReturnStatus {
  notStarted,
  inProgress,
  filed,
  filedAmended,
}

/// Model for a tax return year entry.
class TaxReturnYear {
  final int year;
  final TaxReturnStatus status;
  final int? progressPercent; // Only for inProgress

  const TaxReturnYear({
    required this.year,
    required this.status,
    this.progressPercent,
  });
}

class ReturnYearSelectionScreen extends StatefulWidget {
  const ReturnYearSelectionScreen({super.key});

  @override
  State<ReturnYearSelectionScreen> createState() =>
      _ReturnYearSelectionScreenState();
}

class _ReturnYearSelectionScreenState extends State<ReturnYearSelectionScreen> {
  static const _navyBlue = Color(0xFF0B2D6C);

  bool _olderYearsExpanded = false;

  // Main tax years shown as cards
  final List<TaxReturnYear> _mainYears = const [
    TaxReturnYear(year: 2025, status: TaxReturnStatus.notStarted),
    TaxReturnYear(
      year: 2024,
      status: TaxReturnStatus.inProgress,
      progressPercent: 42,
    ),
    TaxReturnYear(year: 2023, status: TaxReturnStatus.filed),
  ];

  // Older tax years shown in expandable section
  final List<int> _olderYears = const [2022, 2021, 2020];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 17),
            child: Column(
              children: [
                // ReturnPilot logo
                Image.asset(
                  Strings.returnPilotLogoBluePng,
                  height: 75,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),

                // Subtitle
                const Text(
                  'Select a Tax Year to Begin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1,
                    color: _navyBlue,
                  ),
                ),
                const SizedBox(height: 14),

                // Tax year cards
                ..._mainYears.map((ty) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TaxYearCard(
                        taxYear: ty,
                        onStartReturn: () => _onStartReturn(ty.year),
                        onContinue: () => _onContinue(ty.year),
                        onViewReturn: () => _onViewReturn(ty.year),
                        onAmendReturn: () => _onAmendReturn(ty.year),
                      ),
                    )),
                const SizedBox(height: 4),

                // Older Tax Years toggle
                _buildOlderTaxYearsButton(),

                // Expanded older years
                if (_olderYearsExpanded) ...[
                  const SizedBox(height: 10),
                  _buildOlderYearsList(),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOlderTaxYearsButton() {
    return SizedBox(
      width: double.infinity,
      height: 53.3,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _olderYearsExpanded = !_olderYearsExpanded;
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _navyBlue,
          side: const BorderSide(color: _navyBlue, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Older Tax Years',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 15.55,
                height: 27 / 15.55,
                color: _navyBlue,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _olderYearsExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: _navyBlue,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOlderYearsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.91),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 17.46,
          ),
        ],
      ),
      child: Column(
        children: _olderYears.map((year) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Text(
                  '\u2022 ',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _navyBlue,
                  ),
                ),
                Text(
                  '$year',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 22 / 15,
                    color: _navyBlue,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(' [', style: _olderYearLinkStyle),
                GestureDetector(
                  onTap: () => _onStartReturn(year),
                  child: const Text('Start',
                      style: _olderYearLinkStyle),
                ),
                const Text(' | ', style: _olderYearLinkStyle),
                GestureDetector(
                  onTap: () => _onContinue(year),
                  child: const Text('Continue',
                      style: _olderYearLinkStyle),
                ),
                const Text(' | ', style: _olderYearLinkStyle),
                GestureDetector(
                  onTap: () => _onViewReturn(year),
                  child: const Text('View',
                      style: _olderYearLinkStyle),
                ),
                const Text(' ]', style: _olderYearLinkStyle),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static const _olderYearLinkStyle = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w800,
    fontSize: 15,
    height: 22 / 15,
    color: _navyBlue,
  );

  void _onStartReturn(int year) {
    context.push('/interview-welcome');
  }

  void _onContinue(int year) {
    context.push('/interview');
  }

  void _onViewReturn(int year) {
    // TODO: Navigate to view return
  }

  void _onAmendReturn(int year) {
    // TODO: Navigate to amend flow
  }
}

class _TaxYearCard extends StatelessWidget {
  const _TaxYearCard({
    required this.taxYear,
    required this.onStartReturn,
    required this.onContinue,
    required this.onViewReturn,
    required this.onAmendReturn,
  });

  final TaxReturnYear taxYear;
  final VoidCallback onStartReturn;
  final VoidCallback onContinue;
  final VoidCallback onViewReturn;
  final VoidCallback onAmendReturn;

  static const _navyBlue = Color(0xFF0B2D6C);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.91),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 17.46,
          ),
        ],
      ),
      child: Column(
        children: [
          // Year title
          Text(
            '${taxYear.year} Tax Return',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 26 / 22,
              color: _navyBlue,
            ),
          ),
          const SizedBox(height: 10),

          // Status line
          _buildStatusRow(),
          const SizedBox(height: 10),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: _buildActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    switch (taxYear.status) {
      case TaxReturnStatus.notStarted:
        return const Text(
          'Status: Not Started',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            height: 22 / 13,
            color: Color(0xFF333333),
          ),
        );
      case TaxReturnStatus.inProgress:
        return Text(
          'Status: In Progress (${taxYear.progressPercent}%)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            height: 22 / 13,
            color: Color(0xFF333333),
          ),
        );
      case TaxReturnStatus.filed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Status: Filed',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 22 / 13,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 1),
            SvgPicture.asset(
              Strings.uploadedIcon,
              width: 13,
              height: 13,
            ),
          ],
        );
      case TaxReturnStatus.filedAmended:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Status: Filed',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 22 / 13,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 1),
            SvgPicture.asset(
              Strings.uploadedIcon,
              width: 13,
              height: 13,
            ),
            const Text(
              ' (Amended)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 22 / 13,
                color: Color(0xFF333333),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildActions() {
    switch (taxYear.status) {
      case TaxReturnStatus.notStarted:
        return Column(
          children: [
            _solidButton('Start Return', onStartReturn),
            const SizedBox(height: 5),
            _outlinedButton('Amend Filed Return', onAmendReturn),
          ],
        );
      case TaxReturnStatus.inProgress:
        return _solidButton('Continue', onContinue);
      case TaxReturnStatus.filed:
        return _solidButton('View Return', onViewReturn);
      case TaxReturnStatus.filedAmended:
        return Column(
          children: [
            _solidButton('View Return', onViewReturn),
            const SizedBox(height: 5),
            _outlinedButton('Amend Return', onAmendReturn),
          ],
        );
    }
  }

  Widget _solidButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _navyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15.55,
            height: 27 / 15.55,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _outlinedButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _navyBlue,
          side: const BorderSide(color: _navyBlue, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15.55,
            height: 27 / 15.55,
            color: _navyBlue,
          ),
        ),
      ),
    );
  }
}
