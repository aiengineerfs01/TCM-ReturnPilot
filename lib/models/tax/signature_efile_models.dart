/// =============================================================================
/// Signature, E-File, and Refund Models
/// 
/// Models for tax return signatures, e-file submissions, and refund preferences.
/// These are required for final submission to the IRS.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

// =============================================================================
// Return Signatures
// =============================================================================

/// E-signature record for tax return filing
/// 
/// IRS requires signatures from:
/// - Primary taxpayer (always)
/// - Spouse (if filing jointly)
/// - Tax preparer (if applicable)
/// 
/// Signature authentication options:
/// - Self-Select PIN: Uses prior year AGI or PIN
/// - Practitioner PIN: Preparer enters PIN
class ReturnSignature {
  final String? id;
  final String returnId;

  /// Who is signing (primary, spouse, preparer, ero)
  final SignerType signerType;

  /// Method of signature authentication
  final SignatureMethod signatureMethod;

  // ---------------------------------------------------------------------------
  // PIN-based Authentication
  // ---------------------------------------------------------------------------
  
  /// 5-digit self-select PIN (encrypted in database)
  final String? pin;

  /// Prior year AGI for authentication
  final String? priorYearAgi;

  /// Prior year PIN alternative
  final String? priorYearPin;

  // ---------------------------------------------------------------------------
  // E-Signature Capture
  // ---------------------------------------------------------------------------
  
  /// Path to captured signature image
  final String? signatureImagePath;

  // ---------------------------------------------------------------------------
  // Consent & Authorization
  // ---------------------------------------------------------------------------
  
  /// Consent to disclose return info to third parties
  final bool consentToDisclose;

  /// Consent to use return info for specified purposes
  final bool consentToUseInfo;

  // ---------------------------------------------------------------------------
  // Audit Trail
  // ---------------------------------------------------------------------------
  
  /// IP address when signature was captured
  final String? ipAddress;

  /// User agent/browser info
  final String? userAgent;

  /// Device fingerprint for fraud detection
  final String? deviceFingerprint;

  /// When signature was captured
  final DateTime signedAt;

  // ---------------------------------------------------------------------------
  // Form 8879 (E-File Authorization)
  // ---------------------------------------------------------------------------
  
  /// Whether Form 8879 was signed
  final bool form8879Signed;

  /// Date Form 8879 was signed
  final DateTime? form8879Date;

  final DateTime? createdAt;

  const ReturnSignature({
    this.id,
    required this.returnId,
    required this.signerType,
    required this.signatureMethod,
    this.pin,
    this.priorYearAgi,
    this.priorYearPin,
    this.signatureImagePath,
    this.consentToDisclose = false,
    this.consentToUseInfo = false,
    this.ipAddress,
    this.userAgent,
    this.deviceFingerprint,
    required this.signedAt,
    this.form8879Signed = false,
    this.form8879Date,
    this.createdAt,
  });

  /// Check if all required consents are given
  bool get hasAllConsents => consentToDisclose && consentToUseInfo;

  /// Check if signature is complete
  bool get isComplete =>
      hasAllConsents && (pin != null || signatureImagePath != null);

  factory ReturnSignature.fromJson(Map<String, dynamic> json) {
    return ReturnSignature(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      signerType: SignerType.fromString(json['signer_type'] as String?),
      signatureMethod: SignatureMethod.fromString(json['signature_method'] as String?),
      pin: json['pin'] as String?, // Decrypted by service
      priorYearAgi: json['prior_year_agi'] as String?, // Decrypted
      priorYearPin: json['prior_year_pin'] as String?, // Decrypted
      signatureImagePath: json['signature_image_path'] as String?,
      consentToDisclose: json['consent_to_disclose'] as bool? ?? false,
      consentToUseInfo: json['consent_to_use_info'] as bool? ?? false,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      deviceFingerprint: json['device_fingerprint'] as String?,
      signedAt: DateTime.parse(json['signed_at'] as String),
      form8879Signed: json['form_8879_signed'] as bool? ?? false,
      form8879Date: json['form_8879_date'] != null
          ? DateTime.parse(json['form_8879_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'signer_type': signerType.value,
      'signature_method': signatureMethod.value,
      'pin': pin, // Will be encrypted by service
      'prior_year_agi': priorYearAgi, // Will be encrypted
      'prior_year_pin': priorYearPin, // Will be encrypted
      'signature_image_path': signatureImagePath,
      'consent_to_disclose': consentToDisclose,
      'consent_to_use_info': consentToUseInfo,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'device_fingerprint': deviceFingerprint,
      'signed_at': signedAt.toIso8601String(),
      'form_8879_signed': form8879Signed,
      'form_8879_date': form8879Date?.toIso8601String().split('T').first,
    };
  }

  ReturnSignature copyWith({
    String? id,
    String? returnId,
    SignerType? signerType,
    SignatureMethod? signatureMethod,
    String? pin,
    String? priorYearAgi,
    String? priorYearPin,
    String? signatureImagePath,
    bool? consentToDisclose,
    bool? consentToUseInfo,
    String? ipAddress,
    String? userAgent,
    String? deviceFingerprint,
    DateTime? signedAt,
    bool? form8879Signed,
    DateTime? form8879Date,
    DateTime? createdAt,
  }) {
    return ReturnSignature(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      signerType: signerType ?? this.signerType,
      signatureMethod: signatureMethod ?? this.signatureMethod,
      pin: pin ?? this.pin,
      priorYearAgi: priorYearAgi ?? this.priorYearAgi,
      priorYearPin: priorYearPin ?? this.priorYearPin,
      signatureImagePath: signatureImagePath ?? this.signatureImagePath,
      consentToDisclose: consentToDisclose ?? this.consentToDisclose,
      consentToUseInfo: consentToUseInfo ?? this.consentToUseInfo,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      signedAt: signedAt ?? this.signedAt,
      form8879Signed: form8879Signed ?? this.form8879Signed,
      form8879Date: form8879Date ?? this.form8879Date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// =============================================================================
// E-File Submission
// =============================================================================

/// E-file submission record with IRS acknowledgment tracking
/// 
/// Tracks the complete lifecycle of an e-filed return:
/// 1. Pending: Return prepared, not yet transmitted
/// 2. Transmitted: Sent to IRS
/// 3. Accepted: IRS accepted the return
/// 4. Rejected: IRS rejected (includes error codes)
class EFileSubmission {
  final String? id;
  final String returnId;

  /// IRS-assigned submission ID
  final String submissionId;

  /// Type of submission
  final SubmissionType submissionType;

  /// Current status
  final EFileStatus status;

  /// SHA-256 hash of XML for integrity verification
  final String xmlHash;

  /// Storage path for XML file
  final String? xmlStoragePath;

  // ---------------------------------------------------------------------------
  // Timestamps
  // ---------------------------------------------------------------------------
  
  /// When return was submitted
  final DateTime submittedAt;

  /// When IRS acknowledgment was received
  final DateTime? acknowledgmentReceivedAt;

  /// When IRS accepted the return
  final DateTime? acceptedAt;

  /// When IRS rejected the return
  final DateTime? rejectedAt;

  // ---------------------------------------------------------------------------
  // Rejection Details
  // ---------------------------------------------------------------------------
  
  /// IRS rejection error code
  final String? rejectionCode;

  /// Human-readable rejection message
  final String? rejectionMessage;

  /// Category of rejection
  final RejectionCategory? rejectionCategory;

  // ---------------------------------------------------------------------------
  // IRS Response
  // ---------------------------------------------------------------------------
  
  /// Raw acknowledgment data from IRS
  final Map<String, dynamic>? rawAcknowledgment;

  // ---------------------------------------------------------------------------
  // Retry Information
  // ---------------------------------------------------------------------------
  
  /// Number of retry attempts
  final int retryCount;

  /// Last retry timestamp
  final DateTime? lastRetryAt;

  final DateTime? createdAt;

  const EFileSubmission({
    this.id,
    required this.returnId,
    required this.submissionId,
    required this.submissionType,
    this.status = EFileStatus.pending,
    required this.xmlHash,
    this.xmlStoragePath,
    required this.submittedAt,
    this.acknowledgmentReceivedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.rejectionCode,
    this.rejectionMessage,
    this.rejectionCategory,
    this.rawAcknowledgment,
    this.retryCount = 0,
    this.lastRetryAt,
    this.createdAt,
  });

  /// Check if submission is still pending
  bool get isPending => status == EFileStatus.pending || status == EFileStatus.transmitted;

  /// Check if submission failed
  bool get isRejected => status == EFileStatus.rejected;

  /// Check if submission succeeded
  bool get isAccepted => status == EFileStatus.accepted;

  /// Check if can retry
  bool get canRetry => isRejected && retryCount < 3;

  /// Get display-friendly status message
  String get statusMessage {
    switch (status) {
      case EFileStatus.notSubmitted:
        return 'Not yet submitted';
      case EFileStatus.pending:
        return 'Pending IRS review';
      case EFileStatus.transmitted:
        return 'Transmitted to IRS';
      case EFileStatus.accepted:
        return 'Accepted by IRS';
      case EFileStatus.rejected:
        return 'Rejected - $rejectionMessage';
    }
  }

  factory EFileSubmission.fromJson(Map<String, dynamic> json) {
    return EFileSubmission(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      submissionId: json['submission_id'] as String,
      submissionType: SubmissionType.fromString(json['submission_type'] as String?),
      status: EFileStatus.fromString(json['status'] as String?),
      xmlHash: json['xml_hash'] as String,
      xmlStoragePath: json['xml_storage_path'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      acknowledgmentReceivedAt: json['acknowledgment_received_at'] != null
          ? DateTime.parse(json['acknowledgment_received_at'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      rejectionCode: json['rejection_code'] as String?,
      rejectionMessage: json['rejection_message'] as String?,
      rejectionCategory: json['rejection_category'] != null
          ? RejectionCategory.fromString(json['rejection_category'] as String?)
          : null,
      rawAcknowledgment: json['raw_acknowledgment'] as Map<String, dynamic>?,
      retryCount: json['retry_count'] as int? ?? 0,
      lastRetryAt: json['last_retry_at'] != null
          ? DateTime.parse(json['last_retry_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'submission_id': submissionId,
      'submission_type': submissionType.value,
      'status': status.value,
      'xml_hash': xmlHash,
      'xml_storage_path': xmlStoragePath,
      'submitted_at': submittedAt.toIso8601String(),
      'acknowledgment_received_at': acknowledgmentReceivedAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'rejection_code': rejectionCode,
      'rejection_message': rejectionMessage,
      'rejection_category': rejectionCategory?.value,
      'raw_acknowledgment': rawAcknowledgment,
      'retry_count': retryCount,
      'last_retry_at': lastRetryAt?.toIso8601String(),
    };
  }

  EFileSubmission copyWith({
    String? id,
    String? returnId,
    String? submissionId,
    SubmissionType? submissionType,
    EFileStatus? status,
    String? xmlHash,
    String? xmlStoragePath,
    DateTime? submittedAt,
    DateTime? acknowledgmentReceivedAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    String? rejectionCode,
    String? rejectionMessage,
    RejectionCategory? rejectionCategory,
    Map<String, dynamic>? rawAcknowledgment,
    int? retryCount,
    DateTime? lastRetryAt,
    DateTime? createdAt,
  }) {
    return EFileSubmission(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      submissionId: submissionId ?? this.submissionId,
      submissionType: submissionType ?? this.submissionType,
      status: status ?? this.status,
      xmlHash: xmlHash ?? this.xmlHash,
      xmlStoragePath: xmlStoragePath ?? this.xmlStoragePath,
      submittedAt: submittedAt ?? this.submittedAt,
      acknowledgmentReceivedAt: acknowledgmentReceivedAt ?? this.acknowledgmentReceivedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionCode: rejectionCode ?? this.rejectionCode,
      rejectionMessage: rejectionMessage ?? this.rejectionMessage,
      rejectionCategory: rejectionCategory ?? this.rejectionCategory,
      rawAcknowledgment: rawAcknowledgment ?? this.rawAcknowledgment,
      retryCount: retryCount ?? this.retryCount,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// =============================================================================
// Refund Preferences
// =============================================================================

/// How the taxpayer wants to receive their refund
/// 
/// Options:
/// - Direct deposit (fastest - 21 days)
/// - Paper check (4-6 weeks)
/// - Apply to next year's taxes
/// - Split between multiple accounts
class RefundPreferences {
  final String? id;
  final String returnId;

  /// Selected refund method
  final RefundOption refundOption;

  // ---------------------------------------------------------------------------
  // Primary Bank Account (for direct deposit)
  // ---------------------------------------------------------------------------
  
  /// Bank routing number (encrypted)
  final String? routingNumber;

  /// Bank account number (encrypted)
  final String? accountNumber;

  /// Account type
  final BankAccountType? accountType;

  /// Last 4 digits of account (for display)
  final String? accountLastFour;

  // ---------------------------------------------------------------------------
  // Split Refund (Form 8888)
  // ---------------------------------------------------------------------------
  
  /// Split account destinations
  /// Each item: {routing, account, type, amount}
  final List<SplitAccount>? splitAccounts;

  // ---------------------------------------------------------------------------
  // Apply to Next Year
  // ---------------------------------------------------------------------------
  
  /// Amount to apply to next year's estimated taxes
  final double applyToEstimated;

  // ---------------------------------------------------------------------------
  // Savings Bonds
  // ---------------------------------------------------------------------------
  
  /// Amount to purchase I Bonds with refund
  final double savingsBondPurchase;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RefundPreferences({
    this.id,
    required this.returnId,
    required this.refundOption,
    this.routingNumber,
    this.accountNumber,
    this.accountType,
    this.accountLastFour,
    this.splitAccounts,
    this.applyToEstimated = 0,
    this.savingsBondPurchase = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if bank info is complete for direct deposit
  bool get hasCompleteBankInfo =>
      routingNumber != null &&
      accountNumber != null &&
      accountType != null;

  /// Get masked account number for display
  String get maskedAccountNumber {
    if (accountLastFour != null) {
      return '****${accountLastFour}';
    }
    return '********';
  }

  factory RefundPreferences.fromJson(Map<String, dynamic> json) {
    List<SplitAccount>? splits;
    if (json['split_accounts'] != null) {
      final splitList = json['split_accounts'] as List;
      splits = splitList.map((e) => SplitAccount.fromJson(e)).toList();
    }

    return RefundPreferences(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      refundOption: RefundOption.fromString(json['refund_option'] as String?),
      routingNumber: json['routing_number'] as String?, // Decrypted
      accountNumber: json['account_number'] as String?, // Decrypted
      accountType: json['account_type'] != null
          ? BankAccountType.fromString(json['account_type'] as String?)
          : null,
      accountLastFour: json['account_last_four'] as String?,
      splitAccounts: splits,
      applyToEstimated: (json['apply_to_estimated'] as num?)?.toDouble() ?? 0,
      savingsBondPurchase: (json['savings_bond_purchase'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'refund_option': refundOption.value,
      'routing_number': routingNumber, // Will be encrypted
      'account_number': accountNumber, // Will be encrypted
      'account_type': accountType?.value,
      'account_last_four': accountLastFour,
      'split_accounts': splitAccounts?.map((e) => e.toJson()).toList(),
      'apply_to_estimated': applyToEstimated,
      'savings_bond_purchase': savingsBondPurchase,
    };
  }

  RefundPreferences copyWith({
    String? id,
    String? returnId,
    RefundOption? refundOption,
    String? routingNumber,
    String? accountNumber,
    BankAccountType? accountType,
    String? accountLastFour,
    List<SplitAccount>? splitAccounts,
    double? applyToEstimated,
    double? savingsBondPurchase,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RefundPreferences(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      refundOption: refundOption ?? this.refundOption,
      routingNumber: routingNumber ?? this.routingNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      accountLastFour: accountLastFour ?? this.accountLastFour,
      splitAccounts: splitAccounts ?? this.splitAccounts,
      applyToEstimated: applyToEstimated ?? this.applyToEstimated,
      savingsBondPurchase: savingsBondPurchase ?? this.savingsBondPurchase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Individual split account for Form 8888
class SplitAccount {
  final String routingNumber;
  final String accountNumber;
  final BankAccountType accountType;
  final double amount;

  const SplitAccount({
    required this.routingNumber,
    required this.accountNumber,
    required this.accountType,
    required this.amount,
  });

  factory SplitAccount.fromJson(Map<String, dynamic> json) {
    return SplitAccount(
      routingNumber: json['routing_number'] as String,
      accountNumber: json['account_number'] as String,
      accountType: BankAccountType.fromString(json['account_type'] as String?),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routing_number': routingNumber,
      'account_number': accountNumber,
      'account_type': accountType.value,
      'amount': amount,
    };
  }
}

// =============================================================================
// Tax Payments
// =============================================================================

/// Tax payments and withholdings applied to the return
class TaxPayments {
  final String? id;
  final String returnId;

  // ---------------------------------------------------------------------------
  // Federal Withholding
  // ---------------------------------------------------------------------------
  
  /// Total federal tax withheld from W-2s
  final double federalWithheldW2;

  /// Total federal tax withheld from 1099s
  final double federalWithheld1099;

  /// Combined withholding total
  final double federalWithheldTotal;

  // ---------------------------------------------------------------------------
  // Estimated Tax Payments
  // ---------------------------------------------------------------------------
  
  /// Q1 estimated payment (April 15)
  final double estimatedQ1;

  /// Q2 estimated payment (June 15)
  final double estimatedQ2;

  /// Q3 estimated payment (September 15)
  final double estimatedQ3;

  /// Q4 estimated payment (January 15 of following year)
  final double estimatedQ4;

  /// Total estimated payments
  final double estimatedTotal;

  // ---------------------------------------------------------------------------
  // Other Payments
  // ---------------------------------------------------------------------------
  
  /// Prior year overpayment applied
  final double priorYearOverpayment;

  /// Extension payment made
  final double extensionPayment;

  /// Excess Social Security tax withheld (if multiple employers)
  final double excessSocialSecurity;

  /// Other payments
  final double otherPayments;

  /// Total all payments
  final double totalPayments;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaxPayments({
    this.id,
    required this.returnId,
    this.federalWithheldW2 = 0,
    this.federalWithheld1099 = 0,
    this.federalWithheldTotal = 0,
    this.estimatedQ1 = 0,
    this.estimatedQ2 = 0,
    this.estimatedQ3 = 0,
    this.estimatedQ4 = 0,
    this.estimatedTotal = 0,
    this.priorYearOverpayment = 0,
    this.extensionPayment = 0,
    this.excessSocialSecurity = 0,
    this.otherPayments = 0,
    this.totalPayments = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculate total estimated payments
  double calculateEstimatedTotal() {
    return estimatedQ1 + estimatedQ2 + estimatedQ3 + estimatedQ4;
  }

  /// Calculate total payments
  double calculateTotalPayments() {
    return federalWithheldTotal +
        estimatedTotal +
        priorYearOverpayment +
        extensionPayment +
        excessSocialSecurity +
        otherPayments;
  }

  factory TaxPayments.fromJson(Map<String, dynamic> json) {
    return TaxPayments(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      federalWithheldW2: (json['federal_withheld_w2'] as num?)?.toDouble() ?? 0,
      federalWithheld1099: (json['federal_withheld_1099'] as num?)?.toDouble() ?? 0,
      federalWithheldTotal: (json['federal_withheld_total'] as num?)?.toDouble() ?? 0,
      estimatedQ1: (json['estimated_q1'] as num?)?.toDouble() ?? 0,
      estimatedQ2: (json['estimated_q2'] as num?)?.toDouble() ?? 0,
      estimatedQ3: (json['estimated_q3'] as num?)?.toDouble() ?? 0,
      estimatedQ4: (json['estimated_q4'] as num?)?.toDouble() ?? 0,
      estimatedTotal: (json['estimated_total'] as num?)?.toDouble() ?? 0,
      priorYearOverpayment: (json['prior_year_overpayment'] as num?)?.toDouble() ?? 0,
      extensionPayment: (json['extension_payment'] as num?)?.toDouble() ?? 0,
      excessSocialSecurity: (json['excess_social_security'] as num?)?.toDouble() ?? 0,
      otherPayments: (json['other_payments'] as num?)?.toDouble() ?? 0,
      totalPayments: (json['total_payments'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'federal_withheld_w2': federalWithheldW2,
      'federal_withheld_1099': federalWithheld1099,
      'federal_withheld_total': federalWithheldTotal,
      'estimated_q1': estimatedQ1,
      'estimated_q2': estimatedQ2,
      'estimated_q3': estimatedQ3,
      'estimated_q4': estimatedQ4,
      'estimated_total': estimatedTotal,
      'prior_year_overpayment': priorYearOverpayment,
      'extension_payment': extensionPayment,
      'excess_social_security': excessSocialSecurity,
      'other_payments': otherPayments,
      'total_payments': totalPayments,
    };
  }

  TaxPayments copyWith({
    String? id,
    String? returnId,
    double? federalWithheldW2,
    double? federalWithheld1099,
    double? federalWithheldTotal,
    double? estimatedQ1,
    double? estimatedQ2,
    double? estimatedQ3,
    double? estimatedQ4,
    double? estimatedTotal,
    double? priorYearOverpayment,
    double? extensionPayment,
    double? excessSocialSecurity,
    double? otherPayments,
    double? totalPayments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxPayments(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      federalWithheldW2: federalWithheldW2 ?? this.federalWithheldW2,
      federalWithheld1099: federalWithheld1099 ?? this.federalWithheld1099,
      federalWithheldTotal: federalWithheldTotal ?? this.federalWithheldTotal,
      estimatedQ1: estimatedQ1 ?? this.estimatedQ1,
      estimatedQ2: estimatedQ2 ?? this.estimatedQ2,
      estimatedQ3: estimatedQ3 ?? this.estimatedQ3,
      estimatedQ4: estimatedQ4 ?? this.estimatedQ4,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      priorYearOverpayment: priorYearOverpayment ?? this.priorYearOverpayment,
      extensionPayment: extensionPayment ?? this.extensionPayment,
      excessSocialSecurity: excessSocialSecurity ?? this.excessSocialSecurity,
      otherPayments: otherPayments ?? this.otherPayments,
      totalPayments: totalPayments ?? this.totalPayments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
