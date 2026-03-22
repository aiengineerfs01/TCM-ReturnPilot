import 'package:flutter/material.dart';

class RefundInfoCards extends StatelessWidget {
  const RefundInfoCards({
    super.key,
    this.refundAmount = 3842,
    this.taxYear = '2025',
    this.refundDays = '2-Days',
    this.deliveryMethod = 'Direct Deposit',
    this.isApproved = true,
    this.optIn = true,
  });

  final double refundAmount;
  final String taxYear;
  final String refundDays;
  final String deliveryMethod;
  final bool isApproved;
  final bool optIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Refund Estimated Card
        Expanded(
          child: _RefundAmountCard(
            amount: refundAmount,
            taxYear: taxYear,
          ),
        ),
        const SizedBox(width: 16),

        // Refund Status Card
        Expanded(
          child: _RefundStatusCard(
            days: refundDays,
            deliveryMethod: deliveryMethod,
            isApproved: isApproved,
            optIn: optIn,
          ),
        ),
      ],
    );
  }
}

class _RefundAmountCard extends StatelessWidget {
  const _RefundAmountCard({
    required this.amount,
    required this.taxYear,
  });

  final double amount;
  final String taxYear;

  @override
  Widget build(BuildContext context) {
    final formatted = '\$${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}';

    return Container(
      height: 116,
      padding: const EdgeInsets.symmetric(horizontal: 4.11, vertical: 15.63),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.09),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 8.23,
            spreadRadius: -2.47,
          ),
        ],
      ),
      child: Column(
        children: [
          // Amount + Refund Estimated + Badge
          Expanded(
            child: Column(
              children: [
                // Amount
                Text(
                  formatted,
                  style: const TextStyle(
                    fontFamily: 'Be Vietnam',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    height: 13 / 26,
                    color: Color(0xFF04E762),
                  ),
                ),
                const SizedBox(height: 8),

                // Refund icon + label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cached_rounded,
                      size: 19,
                      color: const Color(0xFF0B2D6C),
                    ),
                    const SizedBox(width: 1),
                    const Text(
                      'Refund Estimated',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 13 / 12,
                        color: Color(0xFF0B2D6C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ESTIMATED badge (blue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1.65,
                    vertical: 0.82,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(4, 150, 255, 0.2),
                    borderRadius: BorderRadius.circular(3.29),
                  ),
                  child: const Text(
                    'ESTIMATED',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam',
                      fontWeight: FontWeight.w800,
                      fontSize: 8.23,
                      height: 7 / 8.23,
                      color: Color(0xFF28B5E1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: double.infinity,
            height: 0.7,
            color: const Color.fromRGBO(0, 0, 0, 0.15),
          ),
          const SizedBox(height: 7),

          // Tax Year
          Text(
            'Tax Year: $taxYear',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 10,
              height: 11 / 10,
              color: Color(0xFF323232),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefundStatusCard extends StatelessWidget {
  const _RefundStatusCard({
    required this.days,
    required this.deliveryMethod,
    required this.isApproved,
    required this.optIn,
  });

  final String days;
  final String deliveryMethod;
  final bool isApproved;
  final bool optIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.fromLTRB(4.11, 15.63, 4.11, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.09),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 8.23,
            spreadRadius: -2.47,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '$days Refund Status',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      height: 12 / 13,
                      color: Color(0xFF0B2D6C),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Delivery method
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Delivery: $deliveryMethod',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      height: 14 / 10,
                      color: Color(0xFF3C3C3C),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // APPROVED badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1.65,
                      vertical: 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 163, 140, 0.22),
                      borderRadius: BorderRadius.circular(3.29),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 10,
                          color: const Color(0xFF00A38C),
                        ),
                        const SizedBox(width: 2.47),
                        const Text(
                          'APPROVED',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam',
                            fontWeight: FontWeight.w800,
                            fontSize: 8.23,
                            height: 7 / 8.23,
                            color: Color(0xFF00A38C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: double.infinity,
            height: 0.7,
            color: const Color.fromRGBO(0, 0, 0, 0.15),
          ),
          const SizedBox(height: 5),

          // Opt-in
          Text(
            'Opt-in: ${optIn ? "Yes" : "No"}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 10.7,
              height: 14 / 10.7,
              color: Color(0xFF323232),
            ),
          ),
        ],
      ),
    );
  }
}
