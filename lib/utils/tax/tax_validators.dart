/// =============================================================================
/// Tax Validators
/// 
/// Comprehensive validation utilities for tax-related data including:
/// - SSN (Social Security Number)
/// - EIN (Employer Identification Number)
/// - Routing numbers
/// - Account numbers
/// - ZIP codes
/// - Tax amounts
/// =============================================================================

/// Collection of tax-related validation functions
class TaxValidators {
  TaxValidators._(); // Private constructor - use static methods

  // ===========================================================================
  // SSN Validation
  // ===========================================================================

  /// Validates SSN format (XXX-XX-XXXX)
  /// 
  /// IRS SSN Rules:
  /// - Must be exactly 9 digits
  /// - First 3 digits (area number): Cannot be 000, 666, or 900-999
  /// - Middle 2 digits (group number): Cannot be 00
  /// - Last 4 digits (serial number): Cannot be 0000
  /// 
  /// Returns true if valid, false otherwise
  static bool isValidSsn(String? ssn) {
    if (ssn == null || ssn.isEmpty) return false;

    // Remove any dashes or spaces
    final cleaned = ssn.replaceAll(RegExp(r'[-\s]'), '');

    // Must be exactly 9 digits
    if (cleaned.length != 9 || !RegExp(r'^\d{9}$').hasMatch(cleaned)) {
      return false;
    }

    // Extract parts
    final area = int.parse(cleaned.substring(0, 3));
    final group = int.parse(cleaned.substring(3, 5));
    final serial = int.parse(cleaned.substring(5, 9));

    // Validate area number (first 3 digits)
    // Cannot be 000, 666, or 900-999
    if (area == 0 || area == 666 || area >= 900) {
      return false;
    }

    // Group number cannot be 00
    if (group == 0) {
      return false;
    }

    // Serial number cannot be 0000
    if (serial == 0) {
      return false;
    }

    return true;
  }

  /// Formats SSN as XXX-XX-XXXX
  static String formatSsn(String ssn) {
    final cleaned = ssn.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length != 9) return ssn;
    return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 5)}-${cleaned.substring(5, 9)}';
  }

  /// Masks SSN showing only last 4 digits (XXX-XX-1234)
  static String maskSsn(String ssn) {
    final cleaned = ssn.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length != 9) return '***-**-****';
    return '***-**-${cleaned.substring(5, 9)}';
  }

  /// Returns validation error message for SSN, or null if valid
  static String? validateSsnWithMessage(String? ssn) {
    if (ssn == null || ssn.isEmpty) {
      return 'SSN is required';
    }

    final cleaned = ssn.replaceAll(RegExp(r'[-\s]'), '');

    if (cleaned.length != 9) {
      return 'SSN must be 9 digits';
    }

    if (!RegExp(r'^\d{9}$').hasMatch(cleaned)) {
      return 'SSN must contain only numbers';
    }

    if (!isValidSsn(ssn)) {
      return 'Invalid SSN format';
    }

    return null;
  }

  // ===========================================================================
  // EIN Validation
  // ===========================================================================

  /// Validates EIN format (XX-XXXXXXX)
  /// 
  /// IRS EIN Rules:
  /// - Must be exactly 9 digits
  /// - First 2 digits are the prefix (campus code)
  /// - Valid prefixes: 01-06, 10-16, 20-27, 30-39, 40-48, 50-59, 60-68, 71-77, 80-88, 90-99
  /// - Cannot be all zeros
  static bool isValidEin(String? ein) {
    if (ein == null || ein.isEmpty) return false;

    // Remove any dashes or spaces
    final cleaned = ein.replaceAll(RegExp(r'[-\s]'), '');

    // Must be exactly 9 digits
    if (cleaned.length != 9 || !RegExp(r'^\d{9}$').hasMatch(cleaned)) {
      return false;
    }

    // Cannot be all zeros
    if (cleaned == '000000000') {
      return false;
    }

    // Get prefix (first 2 digits)
    final prefix = int.parse(cleaned.substring(0, 2));

    // Valid EIN prefixes (IRS campus codes)
    final validPrefixes = <int>{
      ...List.generate(6, (i) => i + 1), // 01-06
      ...List.generate(7, (i) => i + 10), // 10-16
      ...List.generate(8, (i) => i + 20), // 20-27
      ...List.generate(10, (i) => i + 30), // 30-39
      ...List.generate(9, (i) => i + 40), // 40-48
      ...List.generate(10, (i) => i + 50), // 50-59
      ...List.generate(9, (i) => i + 60), // 60-68
      ...List.generate(7, (i) => i + 71), // 71-77
      ...List.generate(9, (i) => i + 80), // 80-88
      ...List.generate(10, (i) => i + 90), // 90-99
    };

    return validPrefixes.contains(prefix);
  }

  /// Formats EIN as XX-XXXXXXX
  static String formatEin(String ein) {
    final cleaned = ein.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length != 9) return ein;
    return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 9)}';
  }

  /// Masks EIN showing only last 4 digits (XX-XXX1234)
  static String maskEin(String ein) {
    final cleaned = ein.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length != 9) return '**-***1234';
    return '**-***${cleaned.substring(5, 9)}';
  }

  /// Returns validation error message for EIN, or null if valid
  static String? validateEinWithMessage(String? ein) {
    if (ein == null || ein.isEmpty) {
      return 'EIN is required';
    }

    final cleaned = ein.replaceAll(RegExp(r'[-\s]'), '');

    if (cleaned.length != 9) {
      return 'EIN must be 9 digits';
    }

    if (!RegExp(r'^\d{9}$').hasMatch(cleaned)) {
      return 'EIN must contain only numbers';
    }

    if (!isValidEin(ein)) {
      return 'Invalid EIN format';
    }

    return null;
  }

  // ===========================================================================
  // Bank Routing Number Validation
  // ===========================================================================

  /// Validates bank routing number using ABA checksum algorithm
  /// 
  /// ABA Routing Number Rules:
  /// - Must be exactly 9 digits
  /// - First digit indicates Federal Reserve district (0-9)
  /// - Must pass checksum: 3(d1 + d4 + d7) + 7(d2 + d5 + d8) + (d3 + d6 + d9) ≡ 0 (mod 10)
  static bool isValidRoutingNumber(String? routing) {
    if (routing == null || routing.isEmpty) return false;

    // Remove any spaces
    final cleaned = routing.replaceAll(RegExp(r'\s'), '');

    // Must be exactly 9 digits
    if (cleaned.length != 9 || !RegExp(r'^\d{9}$').hasMatch(cleaned)) {
      return false;
    }

    // Cannot be all zeros
    if (cleaned == '000000000') {
      return false;
    }

    // Parse digits
    final digits = cleaned.split('').map((d) => int.parse(d)).toList();

    // ABA checksum algorithm
    // 3(d1 + d4 + d7) + 7(d2 + d5 + d8) + (d3 + d6 + d9) must be divisible by 10
    final checksum = 3 * (digits[0] + digits[3] + digits[6]) +
        7 * (digits[1] + digits[4] + digits[7]) +
        (digits[2] + digits[5] + digits[8]);

    return checksum % 10 == 0;
  }

  /// Returns validation error message for routing number, or null if valid
  static String? validateRoutingNumberWithMessage(String? routing) {
    if (routing == null || routing.isEmpty) {
      return 'Routing number is required';
    }

    final cleaned = routing.replaceAll(RegExp(r'\s'), '');

    if (cleaned.length != 9) {
      return 'Routing number must be 9 digits';
    }

    if (!RegExp(r'^\d{9}$').hasMatch(cleaned)) {
      return 'Routing number must contain only numbers';
    }

    if (!isValidRoutingNumber(routing)) {
      return 'Invalid routing number';
    }

    return null;
  }

  // ===========================================================================
  // Bank Account Number Validation
  // ===========================================================================

  /// Validates bank account number
  /// 
  /// Basic Rules:
  /// - Must be between 4 and 17 digits
  /// - Must contain only numbers
  /// - Cannot be all zeros
  static bool isValidAccountNumber(String? account) {
    if (account == null || account.isEmpty) return false;

    // Remove any spaces
    final cleaned = account.replaceAll(RegExp(r'\s'), '');

    // Must be 4-17 digits
    if (cleaned.length < 4 || cleaned.length > 17) {
      return false;
    }

    // Must be all digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return false;
    }

    // Cannot be all zeros
    if (cleaned.replaceAll('0', '').isEmpty) {
      return false;
    }

    return true;
  }

  /// Masks account number showing only last 4 digits
  static String maskAccountNumber(String account) {
    final cleaned = account.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length <= 4) return '****';
    return '****${cleaned.substring(cleaned.length - 4)}';
  }

  /// Returns validation error message for account number, or null if valid
  static String? validateAccountNumberWithMessage(String? account) {
    if (account == null || account.isEmpty) {
      return 'Account number is required';
    }

    final cleaned = account.replaceAll(RegExp(r'\s'), '');

    if (cleaned.length < 4) {
      return 'Account number must be at least 4 digits';
    }

    if (cleaned.length > 17) {
      return 'Account number must be 17 digits or less';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Account number must contain only numbers';
    }

    if (cleaned.replaceAll('0', '').isEmpty) {
      return 'Account number cannot be all zeros';
    }

    return null;
  }

  // ===========================================================================
  // ZIP Code Validation
  // ===========================================================================

  /// Validates US ZIP code (5 digits or 5+4 format)
  static bool isValidZipCode(String? zip) {
    if (zip == null || zip.isEmpty) return false;

    // Remove any spaces or dashes
    final cleaned = zip.replaceAll(RegExp(r'[-\s]'), '');

    // Must be 5 or 9 digits
    if (cleaned.length != 5 && cleaned.length != 9) {
      return false;
    }

    // Must be all digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return false;
    }

    // Cannot be 00000
    if (cleaned.substring(0, 5) == '00000') {
      return false;
    }

    return true;
  }

  /// Formats ZIP code as 5 or 5+4
  static String formatZipCode(String zip) {
    final cleaned = zip.replaceAll(RegExp(r'[-\s]'), '');
    if (cleaned.length == 9) {
      return '${cleaned.substring(0, 5)}-${cleaned.substring(5, 9)}';
    }
    return cleaned.length >= 5 ? cleaned.substring(0, 5) : cleaned;
  }

  /// Returns validation error message for ZIP code, or null if valid
  static String? validateZipCodeWithMessage(String? zip) {
    if (zip == null || zip.isEmpty) {
      return 'ZIP code is required';
    }

    final cleaned = zip.replaceAll(RegExp(r'[-\s]'), '');

    if (cleaned.length != 5 && cleaned.length != 9) {
      return 'ZIP code must be 5 or 9 digits';
    }

    if (!isValidZipCode(zip)) {
      return 'Invalid ZIP code';
    }

    return null;
  }

  // ===========================================================================
  // Tax Amount Validation
  // ===========================================================================

  /// Validates tax amount (non-negative, reasonable range)
  static bool isValidTaxAmount(double? amount) {
    if (amount == null) return false;
    
    // Must be non-negative
    if (amount < 0) return false;
    
    // Cap at $10 billion (reasonable maximum for any tax amount)
    if (amount > 10000000000) return false;
    
    return true;
  }

  /// Validates percentage (0-100)
  static bool isValidPercentage(double? percentage) {
    if (percentage == null) return false;
    return percentage >= 0 && percentage <= 100;
  }

  /// Validates tax year (reasonable range)
  static bool isValidTaxYear(int? year) {
    if (year == null) return false;
    final currentYear = DateTime.now().year;
    // Allow years from 1900 to current year + 1
    return year >= 1900 && year <= currentYear + 1;
  }

  // ===========================================================================
  // IP PIN Validation
  // ===========================================================================

  /// Validates IRS Identity Protection PIN
  /// 
  /// IP PIN Rules:
  /// - Exactly 6 digits
  /// - Cannot be all zeros or sequential
  static bool isValidIpPin(String? pin) {
    if (pin == null || pin.isEmpty) return false;

    // Must be exactly 6 digits
    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      return false;
    }

    // Cannot be all zeros
    if (pin == '000000') {
      return false;
    }

    // Cannot be sequential (123456, 654321)
    if (pin == '123456' || pin == '654321') {
      return false;
    }

    return true;
  }

  /// Returns validation error message for IP PIN, or null if valid
  static String? validateIpPinWithMessage(String? pin) {
    if (pin == null || pin.isEmpty) {
      return null; // IP PIN is optional
    }

    if (pin.length != 6) {
      return 'IP PIN must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return 'IP PIN must contain only numbers';
    }

    if (!isValidIpPin(pin)) {
      return 'Invalid IP PIN';
    }

    return null;
  }

  // ===========================================================================
  // Name Validation
  // ===========================================================================

  /// Validates name for tax purposes
  /// 
  /// IRS Name Rules:
  /// - Required (non-empty)
  /// - 1-35 characters
  /// - Letters, spaces, hyphens, apostrophes allowed
  /// - No numbers or special characters
  static bool isValidName(String? name) {
    if (name == null || name.isEmpty) return false;

    final trimmed = name.trim();

    // Length check (1-35 characters)
    if (trimmed.isEmpty || trimmed.length > 35) {
      return false;
    }

    // Must contain at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return false;
    }

    // Only allow letters, spaces, hyphens, apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(trimmed)) {
      return false;
    }

    return true;
  }

  /// Returns validation error message for name, or null if valid
  static String? validateNameWithMessage(String? name, {String fieldName = 'Name'}) {
    if (name == null || name.isEmpty) {
      return '$fieldName is required';
    }

    final trimmed = name.trim();

    if (trimmed.length > 35) {
      return '$fieldName must be 35 characters or less';
    }

    if (!isValidName(name)) {
      return '$fieldName contains invalid characters';
    }

    return null;
  }

  // ===========================================================================
  // Email Validation
  // ===========================================================================

  /// Validates email address format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;

    // Basic email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  /// Returns validation error message for email, or null if valid
  static String? validateEmailWithMessage(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    if (!isValidEmail(email)) {
      return 'Invalid email format';
    }

    return null;
  }

  // ===========================================================================
  // Phone Number Validation
  // ===========================================================================

  /// Validates US phone number
  /// 
  /// Accepts formats: (XXX) XXX-XXXX, XXX-XXX-XXXX, XXXXXXXXXX
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Remove all non-digits
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Must be 10 digits (US phone number)
    if (cleaned.length != 10) {
      return false;
    }

    // First digit cannot be 0 or 1
    if (cleaned[0] == '0' || cleaned[0] == '1') {
      return false;
    }

    // Area code cannot start with 0 or 1
    // Exchange cannot start with 0 or 1
    if (cleaned[3] == '0' || cleaned[3] == '1') {
      return false;
    }

    return true;
  }

  /// Formats phone number as (XXX) XXX-XXXX
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) return phone;
    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6, 10)}';
  }

  /// Returns validation error message for phone number, or null if valid
  static String? validatePhoneNumberWithMessage(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Phone is often optional
    }

    if (!isValidPhoneNumber(phone)) {
      return 'Invalid phone number format';
    }

    return null;
  }

  // ===========================================================================
  // Date Validation
  // ===========================================================================

  /// Validates date of birth
  /// 
  /// Rules:
  /// - Cannot be in the future
  /// - Cannot be more than 150 years ago
  static bool isValidDateOfBirth(DateTime? dob) {
    if (dob == null) return false;

    final now = DateTime.now();
    final minDate = DateTime(now.year - 150, now.month, now.day);

    // Cannot be in the future
    if (dob.isAfter(now)) {
      return false;
    }

    // Cannot be more than 150 years ago
    if (dob.isBefore(minDate)) {
      return false;
    }

    return true;
  }

  /// Returns validation error message for date of birth, or null if valid
  static String? validateDateOfBirthWithMessage(DateTime? dob) {
    if (dob == null) {
      return 'Date of birth is required';
    }

    if (!isValidDateOfBirth(dob)) {
      final now = DateTime.now();
      if (dob.isAfter(now)) {
        return 'Date of birth cannot be in the future';
      }
      return 'Invalid date of birth';
    }

    return null;
  }
}
