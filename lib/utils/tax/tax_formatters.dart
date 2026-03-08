/// =============================================================================
/// Tax Formatters
/// 
/// Utility class for formatting currency, percentages, and tax-related values.
/// Consistent formatting across the entire tax module.
/// =============================================================================

import 'package:intl/intl.dart';

/// Utility class for formatting tax-related values
class TaxFormatters {
  TaxFormatters._(); // Private constructor - use static methods

  // ===========================================================================
  // Currency Formatting
  // ===========================================================================

  /// Standard currency format ($1,234.56)
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  /// Currency without decimals ($1,235)
  static final _currencyWholeFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 0,
  );

  /// Compact currency ($1.2K, $1.5M)
  static final _currencyCompactFormat = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 1,
  );

  /// Format as currency with 2 decimal places
  /// 
  /// Example: 1234.56 -> "$1,234.56"
  static String currency(double? amount) {
    if (amount == null) return r'$0.00';
    return _currencyFormat.format(amount);
  }

  /// Format as currency with no decimal places
  /// 
  /// Example: 1234.56 -> "$1,235"
  static String currencyWhole(double? amount) {
    if (amount == null) return r'$0';
    return _currencyWholeFormat.format(amount);
  }

  /// Format as compact currency
  /// 
  /// Example: 1500000 -> "$1.5M"
  static String currencyCompact(double? amount) {
    if (amount == null) return r'$0';
    return _currencyCompactFormat.format(amount);
  }

  /// Format currency with sign (+ or -)
  /// 
  /// Example: 1234.56 -> "+$1,234.56", -500 -> "-$500.00"
  static String currencyWithSign(double? amount) {
    if (amount == null) return r'$0.00';
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${currency(amount)}';
  }

  /// Format as refund (green/positive) or owed (red/negative)
  /// Returns tuple of (formatted string, isRefund)
  static (String, bool) refundOrOwed(double? amount) {
    if (amount == null || amount == 0) {
      return (r'$0.00', true);
    }
    if (amount > 0) {
      return (currency(amount), true); // Refund
    } else {
      return (currency(-amount), false); // Owed
    }
  }

  // ===========================================================================
  // Percentage Formatting
  // ===========================================================================

  /// Format as percentage with 1 decimal place
  /// 
  /// Example: 0.2456 -> "24.6%"
  static String percent(double? rate) {
    if (rate == null) return '0.0%';
    return '${(rate * 100).toStringAsFixed(1)}%';
  }

  /// Format as percentage with no decimal places
  /// 
  /// Example: 0.24 -> "24%"
  static String percentWhole(double? rate) {
    if (rate == null) return '0%';
    return '${(rate * 100).round()}%';
  }

  /// Format tax bracket rate
  /// 
  /// Example: 0.22 -> "22%"
  static String taxRate(double? rate) {
    if (rate == null) return '0%';
    return '${(rate * 100).toStringAsFixed(0)}%';
  }

  // ===========================================================================
  // Number Formatting
  // ===========================================================================

  /// Format with thousand separators
  /// 
  /// Example: 1234567 -> "1,234,567"
  static String number(num? value) {
    if (value == null) return '0';
    return NumberFormat('#,##0').format(value);
  }

  /// Format as decimal with specified places
  /// 
  /// Example: 1234.5678 (2 places) -> "1,234.57"
  static String decimal(double? value, {int decimalPlaces = 2}) {
    if (value == null) return '0.00';
    final format = NumberFormat('#,##0.${'0' * decimalPlaces}');
    return format.format(value);
  }

  // ===========================================================================
  // Tax-Specific Formatting
  // ===========================================================================

  /// Format SSN for display (masked)
  /// 
  /// Example: "123456789" -> "***-**-6789"
  static String maskedSsn(String? ssn) {
    if (ssn == null || ssn.isEmpty) return '***-**-****';
    final cleaned = ssn.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length != 9) return '***-**-****';
    return '***-**-${cleaned.substring(5)}';
  }

  /// Format SSN for data entry (partial masking while typing)
  /// 
  /// Example: "12345" -> "123-45-"
  static String partialSsn(String ssn) {
    final cleaned = ssn.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length <= 3) return cleaned;
    if (cleaned.length <= 5) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3)}';
    }
    return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 5)}-${cleaned.substring(5)}';
  }

  /// Format EIN for display
  /// 
  /// Example: "123456789" -> "12-3456789"
  static String ein(String? ein) {
    if (ein == null || ein.isEmpty) return '';
    final cleaned = ein.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length != 9) return ein;
    return '${cleaned.substring(0, 2)}-${cleaned.substring(2)}';
  }

  /// Format phone number
  /// 
  /// Example: "1234567890" -> "(123) 456-7890"
  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) return phone;
    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
  }

  /// Format ZIP code
  /// 
  /// Example: "123456789" -> "12345-6789"
  static String zipCode(String? zip) {
    if (zip == null || zip.isEmpty) return '';
    final cleaned = zip.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length == 5) return cleaned;
    if (cleaned.length == 9) {
      return '${cleaned.substring(0, 5)}-${cleaned.substring(5)}';
    }
    return zip;
  }

  /// Format routing number for display (partial mask)
  /// 
  /// Example: "123456789" -> "****56789"
  static String maskedRouting(String? routing) {
    if (routing == null || routing.isEmpty) return '****';
    final cleaned = routing.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 5) return '****';
    return '****${cleaned.substring(4)}';
  }

  /// Format account number for display (last 4 digits)
  /// 
  /// Example: "1234567890" -> "****7890"
  static String maskedAccount(String? account) {
    if (account == null || account.isEmpty) return '****';
    final cleaned = account.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length <= 4) return '****';
    return '****${cleaned.substring(cleaned.length - 4)}';
  }

  // ===========================================================================
  // Date Formatting
  // ===========================================================================

  /// Format date for tax forms (MM/DD/YYYY)
  /// 
  /// Example: DateTime(2024, 4, 15) -> "04/15/2024"
  static String dateForForm(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Format date for display (Month DD, YYYY)
  /// 
  /// Example: DateTime(2024, 4, 15) -> "April 15, 2024"
  static String dateDisplay(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Format date short (MMM DD, YYYY)
  /// 
  /// Example: DateTime(2024, 4, 15) -> "Apr 15, 2024"
  static String dateShort(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format timestamp
  /// 
  /// Example: DateTime(2024, 4, 15, 14, 30) -> "Apr 15, 2024 2:30 PM"
  static String timestamp(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  /// Format tax year display
  /// 
  /// Example: 2024 -> "Tax Year 2024"
  static String taxYear(int? year) {
    if (year == null) return '';
    return 'Tax Year $year';
  }

  // ===========================================================================
  // File Size Formatting
  // ===========================================================================

  /// Format file size
  /// 
  /// Example: 1536000 -> "1.5 MB"
  static String fileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${units[unitIndex]}';
  }

  // ===========================================================================
  // Address Formatting
  // ===========================================================================

  /// Format address for single line display
  static String addressSingleLine({
    String? street1,
    String? street2,
    String? city,
    String? state,
    String? zip,
  }) {
    final parts = <String>[];

    if (street1?.isNotEmpty == true) parts.add(street1!);
    if (street2?.isNotEmpty == true) parts.add(street2!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true && zip?.isNotEmpty == true) {
      parts.add('$state $zip');
    } else if (state?.isNotEmpty == true) {
      parts.add(state!);
    } else if (zip?.isNotEmpty == true) {
      parts.add(zip!);
    }

    return parts.join(', ');
  }

  /// Format address for multi-line display
  static String addressMultiLine({
    String? street1,
    String? street2,
    String? city,
    String? state,
    String? zip,
  }) {
    final lines = <String>[];

    if (street1?.isNotEmpty == true) lines.add(street1!);
    if (street2?.isNotEmpty == true) lines.add(street2!);

    final cityStateZip = <String>[];
    if (city?.isNotEmpty == true) cityStateZip.add(city!);
    if (state?.isNotEmpty == true) cityStateZip.add(state!);
    if (zip?.isNotEmpty == true) cityStateZip.add(zip!);

    if (cityStateZip.isNotEmpty) {
      if (city?.isNotEmpty == true && state?.isNotEmpty == true) {
        lines.add('${cityStateZip[0]}, ${cityStateZip.sublist(1).join(' ')}');
      } else {
        lines.add(cityStateZip.join(' '));
      }
    }

    return lines.join('\n');
  }
}
