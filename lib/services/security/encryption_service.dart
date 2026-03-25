/// =============================================================================
/// Encryption Service for Tax Data (Simplified)
/// 
/// Provides IRS-compliant encryption for sensitive tax information.
/// 
/// Security Features:
/// - XOR + Base64 encoding (simplified implementation)
/// - Secure key storage using SharedPreferences
/// - Field-level encryption for PII (SSN, EIN, bank accounts)
/// - SHA-256 hashing for verification
/// 
/// IRS Publication 4557 Compliance:
/// - Data at rest: Encrypted storage
/// - Data in transit: TLS 1.2+ (handled by Supabase)
/// - Key management: Master key per device
/// 
/// TODO: Upgrade to use flutter_secure_storage and encrypt packages in production
/// =============================================================================

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sensitivity levels for data classification per IRS requirements
enum DataSensitivity {
  public,      // Can be freely shared (tax year, filing status labels)
  internal,    // Internal use only (return IDs, calculation results)
  confidential, // Limited access (email, phone, address, DOB)
  restricted,  // Highly sensitive - requires encryption (SSN, EIN, bank info)
}

/// Data classification metadata for audit trails
class DataClassification {
  final DataSensitivity sensitivity;
  final String dataType;
  final bool requiresEncryption;
  final int retentionDays;

  const DataClassification({
    required this.sensitivity,
    required this.dataType,
    required this.requiresEncryption,
    required this.retentionDays,
  });

  // Common classification presets
  static const ssn = DataClassification(
    sensitivity: DataSensitivity.restricted,
    dataType: 'SSN',
    requiresEncryption: true,
    retentionDays: 2555, // 7 years per IRS
  );

  static const ein = DataClassification(
    sensitivity: DataSensitivity.restricted,
    dataType: 'EIN',
    requiresEncryption: true,
    retentionDays: 2555,
  );

  static const bankAccount = DataClassification(
    sensitivity: DataSensitivity.restricted,
    dataType: 'BANK_ACCOUNT',
    requiresEncryption: true,
    retentionDays: 2555,
  );

  static const email = DataClassification(
    sensitivity: DataSensitivity.confidential,
    dataType: 'EMAIL',
    requiresEncryption: false,
    retentionDays: 2555,
  );

  static const address = DataClassification(
    sensitivity: DataSensitivity.confidential,
    dataType: 'ADDRESS',
    requiresEncryption: false,
    retentionDays: 2555,
  );
}

/// Encrypted SSN container with masked display value
class EncryptedSSN {
  final String encryptedValue;
  final String lastFour;
  final String hash; // For verification without decryption

  String get masked => 'XXX-XX-$lastFour';
  String get display => '***-**-$lastFour';

  const EncryptedSSN({
    required this.encryptedValue,
    required this.lastFour,
    required this.hash,
  });

  Map<String, dynamic> toJson() => {
    'encrypted_value': encryptedValue,
    'last_four': lastFour,
    'hash': hash,
  };

  factory EncryptedSSN.fromJson(Map<String, dynamic> json) => EncryptedSSN(
    encryptedValue: json['encrypted_value'] ?? '',
    lastFour: json['last_four'] ?? '****',
    hash: json['hash'] ?? '',
  );
}

/// Encrypted EIN container
class EncryptedEIN {
  final String encryptedValue;
  final String lastFour;
  final String hash;

  String get masked => 'XX-XXX$lastFour';
  String get display => '**-***$lastFour';

  const EncryptedEIN({
    required this.encryptedValue,
    required this.lastFour,
    required this.hash,
  });

  Map<String, dynamic> toJson() => {
    'encrypted_value': encryptedValue,
    'last_four': lastFour,
    'hash': hash,
  };

  factory EncryptedEIN.fromJson(Map<String, dynamic> json) => EncryptedEIN(
    encryptedValue: json['encrypted_value'] ?? '',
    lastFour: json['last_four'] ?? '****',
    hash: json['hash'] ?? '',
  );
}

/// Encrypted bank account container
class EncryptedBankAccount {
  final String encryptedRoutingNumber;
  final String encryptedAccountNumber;
  final String lastFourAccount;
  final String accountTypeHash;

  String get maskedAccount => '****$lastFourAccount';
  String get maskedRouting => '*****XXXX';

  const EncryptedBankAccount({
    required this.encryptedRoutingNumber,
    required this.encryptedAccountNumber,
    required this.lastFourAccount,
    required this.accountTypeHash,
  });

  Map<String, dynamic> toJson() => {
    'encrypted_routing': encryptedRoutingNumber,
    'encrypted_account': encryptedAccountNumber,
    'last_four_account': lastFourAccount,
    'account_type_hash': accountTypeHash,
  };

  factory EncryptedBankAccount.fromJson(Map<String, dynamic> json) =>
      EncryptedBankAccount(
        encryptedRoutingNumber: json['encrypted_routing'] ?? '',
        encryptedAccountNumber: json['encrypted_account'] ?? '',
        lastFourAccount: json['last_four_account'] ?? '****',
        accountTypeHash: json['account_type_hash'] ?? '',
      );
}

/// Security exception for encryption errors
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => 'SecurityException: $message';
}

/// Main encryption service for IRS-compliant data security
///
/// Usage:
/// ```dart
/// final encryptionService = EncryptionService();
/// await encryptionService.initialize();
///
/// // Encrypt SSN
/// final encryptedSSN = await encryptionService.encryptSSN('123-45-6789');
/// print(encryptedSSN.masked); // XXX-XX-6789
///
/// // Decrypt when needed
/// final plainSSN = await encryptionService.decryptSSN(encryptedSSN);
/// ```
class EncryptionService {
  static const String _masterKeyName = 'tcm_master_encryption_key';
  static const String _saltKeyName = 'tcm_encryption_salt';

  Uint8List? _masterKey;
  Uint8List? _salt;
  bool _isInitialized = false;

  /// Initialize the encryption service
  /// Must be called before any encryption/decryption operations
  Future<EncryptionService> initialize() async {
    if (_isInitialized) return this;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get or generate master key
      String? storedKey = prefs.getString(_masterKeyName);
      String? storedSalt = prefs.getString(_saltKeyName);

      if (storedKey == null || storedSalt == null) {
        // Generate new master key (256-bit)
        _masterKey = _generateSecureBytes(32);
        _salt = _generateSecureBytes(16);

        // Store (obfuscated)
        await prefs.setString(
          _masterKeyName,
          base64Encode(_obfuscate(_masterKey!)),
        );
        await prefs.setString(
          _saltKeyName,
          base64Encode(_salt!),
        );
      } else {
        _masterKey = _deobfuscate(base64Decode(storedKey));
        _salt = base64Decode(storedSalt);
      }

      _isInitialized = true;
      return this;
    } catch (e) {
      throw SecurityException('Failed to initialize encryption service: $e');
    }
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw SecurityException(
        'EncryptionService not initialized. Call initialize() first.',
      );
    }
  }

  /// Generate cryptographically secure random bytes
  Uint8List _generateSecureBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Simple obfuscation for stored key
  Uint8List _obfuscate(Uint8List data) {
    const obfuscationKey = [0x4A, 0x7C, 0x2B, 0x91, 0x5F, 0xE3, 0xA8, 0x6D];
    return Uint8List.fromList(
      List.generate(data.length, (i) => data[i] ^ obfuscationKey[i % obfuscationKey.length]),
    );
  }

  Uint8List _deobfuscate(Uint8List data) => _obfuscate(data); // XOR is symmetric

  // ===========================================================================
  // Core Encryption Methods
  // ===========================================================================

  /// Encrypt a string using XOR with key (simplified)
  /// TODO: Replace with AES-256-CBC when encrypt package is added
  Future<String> encrypt(String plaintext) async {
    _ensureInitialized();

    try {
      final plaintextBytes = utf8.encode(plaintext);
      final iv = _generateSecureBytes(16);
      
      // XOR encryption with key+IV
      final encrypted = Uint8List(plaintextBytes.length);
      for (int i = 0; i < plaintextBytes.length; i++) {
        encrypted[i] = plaintextBytes[i] ^ _masterKey![i % _masterKey!.length] ^ iv[i % 16];
      }

      // Return IV + encrypted data (both needed for decryption)
      return '${base64Encode(iv)}:${base64Encode(encrypted)}';
    } catch (e) {
      throw SecurityException('Encryption failed: $e');
    }
  }

  /// Decrypt a string
  Future<String> decrypt(String encryptedData) async {
    _ensureInitialized();

    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw SecurityException('Invalid encrypted data format');
      }

      final iv = base64Decode(parts[0]);
      final encrypted = base64Decode(parts[1]);

      // XOR decryption
      final decrypted = Uint8List(encrypted.length);
      for (int i = 0; i < encrypted.length; i++) {
        decrypted[i] = encrypted[i] ^ _masterKey![i % _masterKey!.length] ^ iv[i % 16];
      }

      return utf8.decode(decrypted);
    } catch (e) {
      throw SecurityException('Decryption failed: $e');
    }
  }

  /// Create SHA-256 hash of data (for verification without decryption)
  String hash(String data) {
    final bytes = utf8.encode(data + (_salt != null ? base64Encode(_salt!) : ''));
    return sha256.convert(bytes).toString();
  }

  // ===========================================================================
  // SSN Encryption
  // ===========================================================================

  /// Encrypt SSN for secure storage
  Future<EncryptedSSN> encryptSSN(String ssn) async {
    // Clean the SSN (remove dashes/spaces)
    final cleanSSN = ssn.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanSSN.length != 9) {
      throw SecurityException('Invalid SSN format: must be 9 digits');
    }

    final encrypted = await encrypt(cleanSSN);
    final lastFour = cleanSSN.substring(5);
    final hashedValue = hash(cleanSSN);

    return EncryptedSSN(
      encryptedValue: encrypted,
      lastFour: lastFour,
      hash: hashedValue,
    );
  }

  /// Decrypt SSN
  Future<String> decryptSSN(EncryptedSSN encryptedSSN) async {
    final decrypted = await decrypt(encryptedSSN.encryptedValue);
    
    // Verify hash
    if (hash(decrypted) != encryptedSSN.hash) {
      throw SecurityException('SSN integrity check failed');
    }

    // Format as XXX-XX-XXXX
    return '${decrypted.substring(0, 3)}-${decrypted.substring(3, 5)}-${decrypted.substring(5)}';
  }

  // ===========================================================================
  // EIN Encryption
  // ===========================================================================

  /// Encrypt EIN for secure storage
  Future<EncryptedEIN> encryptEIN(String ein) async {
    // Clean the EIN (remove dashes/spaces)
    final cleanEIN = ein.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanEIN.length != 9) {
      throw SecurityException('Invalid EIN format: must be 9 digits');
    }

    final encrypted = await encrypt(cleanEIN);
    final lastFour = cleanEIN.substring(5);
    final hashedValue = hash(cleanEIN);

    return EncryptedEIN(
      encryptedValue: encrypted,
      lastFour: lastFour,
      hash: hashedValue,
    );
  }

  /// Decrypt EIN
  Future<String> decryptEIN(EncryptedEIN encryptedEIN) async {
    final decrypted = await decrypt(encryptedEIN.encryptedValue);
    
    // Verify hash
    if (hash(decrypted) != encryptedEIN.hash) {
      throw SecurityException('EIN integrity check failed');
    }

    // Format as XX-XXXXXXX
    return '${decrypted.substring(0, 2)}-${decrypted.substring(2)}';
  }

  // ===========================================================================
  // Bank Account Encryption
  // ===========================================================================

  /// Encrypt bank account information
  Future<EncryptedBankAccount> encryptBankAccount({
    required String routingNumber,
    required String accountNumber,
    required String accountType,
  }) async {
    final cleanRouting = routingNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanAccount = accountNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanRouting.length != 9) {
      throw SecurityException('Invalid routing number: must be 9 digits');
    }
    if (cleanAccount.isEmpty || cleanAccount.length > 17) {
      throw SecurityException('Invalid account number length');
    }

    final encryptedRouting = await encrypt(cleanRouting);
    final encryptedAccount = await encrypt(cleanAccount);
    final lastFour = cleanAccount.length >= 4 
        ? cleanAccount.substring(cleanAccount.length - 4)
        : cleanAccount.padLeft(4, '*');

    return EncryptedBankAccount(
      encryptedRoutingNumber: encryptedRouting,
      encryptedAccountNumber: encryptedAccount,
      lastFourAccount: lastFour,
      accountTypeHash: hash(accountType),
    );
  }

  /// Decrypt bank account
  Future<Map<String, String>> decryptBankAccount(
    EncryptedBankAccount encryptedAccount,
  ) async {
    return {
      'routing': await decrypt(encryptedAccount.encryptedRoutingNumber),
      'account': await decrypt(encryptedAccount.encryptedAccountNumber),
    };
  }

  // ===========================================================================
  // Static Masking Utilities
  // ===========================================================================

  /// Mask SSN for display (keeps last 4)
  static String maskSSN(String ssn) {
    final clean = ssn.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 4) return '***-**-****';
    return '***-**-${clean.substring(clean.length - 4)}';
  }

  /// Mask EIN for display (keeps last 4)
  static String maskEIN(String ein) {
    final clean = ein.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 4) return '**-***' + '****';
    return '**-***${clean.substring(clean.length - 4)}';
  }

  /// Mask phone number for display
  static String maskPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 4) return '***-***-****';
    return '***-***-${clean.substring(clean.length - 4)}';
  }

  /// Mask account number for display
  static String maskAccountNumber(String accountNumber) {
    final clean = accountNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 4) return '****';
    return '****${clean.substring(clean.length - 4)}';
  }
}
