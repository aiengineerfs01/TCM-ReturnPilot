/// =============================================================================
/// Tax Document and Audit Log Models
/// 
/// Models for document storage and comprehensive audit trail.
/// Required for IRS compliance and fraud detection.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

// =============================================================================
// Tax Document
// =============================================================================

/// Tax document uploaded or generated
/// 
/// Stores metadata about documents like:
/// - Uploaded W-2 images
/// - Generated PDF returns
/// - Form 8879 (e-file authorization)
/// - Supporting documentation
class TaxDocument {
  final String? id;
  final String returnId;

  /// Type of document
  final TaxDocumentType documentType;

  /// Original filename
  final String fileName;

  /// Storage path in Supabase Storage
  final String storagePath;

  /// Public URL (if applicable)
  final String? publicUrl;

  /// File MIME type
  final String mimeType;

  /// File size in bytes
  final int fileSize;

  /// SHA-256 hash for integrity verification
  final String? fileHash;

  /// Processing status
  final ProcessingStatus processingStatus;

  // ---------------------------------------------------------------------------
  // OCR/Extraction Results
  // ---------------------------------------------------------------------------
  
  /// Extracted data from OCR
  final Map<String, dynamic>? extractedData;

  /// OCR confidence score (0-100)
  final double? ocrConfidence;

  /// Whether extraction was verified by user
  final bool extractionVerified;

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------
  
  /// Optional notes about document
  final String? notes;

  /// Date on the document (if applicable)
  final DateTime? documentDate;

  /// Who uploaded (user_id or 'system')
  final String uploadedBy;

  // ---------------------------------------------------------------------------
  // Timestamps
  // ---------------------------------------------------------------------------
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaxDocument({
    this.id,
    required this.returnId,
    required this.documentType,
    required this.fileName,
    required this.storagePath,
    this.publicUrl,
    required this.mimeType,
    required this.fileSize,
    this.fileHash,
    this.processingStatus = ProcessingStatus.pending,
    this.extractedData,
    this.ocrConfidence,
    this.extractionVerified = false,
    this.notes,
    this.documentDate,
    required this.uploadedBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Get human-readable file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if document is an image
  bool get isImage => mimeType.startsWith('image/');

  /// Check if document is a PDF
  bool get isPdf => mimeType == 'application/pdf';

  /// Check if OCR extraction has high confidence
  bool get hasHighConfidence => (ocrConfidence ?? 0) >= 80;

  /// Check if processing is complete
  bool get isProcessed => processingStatus == ProcessingStatus.completed;

  factory TaxDocument.fromJson(Map<String, dynamic> json) {
    return TaxDocument(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      documentType: TaxDocumentType.fromString(json['document_type'] as String?),
      fileName: (json['original_filename'] ?? json['file_name']) as String,
      storagePath: json['storage_path'] as String,
      publicUrl: json['public_url'] as String?,
      mimeType: (json['mime_type'] ?? 'application/octet-stream') as String,
      fileSize: (json['file_size'] ?? 0) as int,
      fileHash: json['file_hash'] as String?,
      processingStatus: ProcessingStatus.fromString(json['processing_status'] as String?),
      extractedData: json['extracted_data'] as Map<String, dynamic>?,
      ocrConfidence: (json['ocr_confidence'] as num?)?.toDouble(),
      extractionVerified: (json['is_verified'] ?? json['extraction_verified']) as bool? ?? false,
      notes: json['notes'] as String?,
      documentDate: json['document_date'] != null
          ? DateTime.parse(json['document_date'] as String)
          : null,
      uploadedBy: (json['uploaded_by'] ?? json['verified_by'] ?? 'user') as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['uploaded_at'] != null 
              ? DateTime.parse(json['uploaded_at'] as String)
              : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'document_type': documentType.value,
      'original_filename': fileName,
      'storage_path': storagePath,
      'file_size': fileSize,
      'mime_type': mimeType,
      'processing_status': processingStatus.value,
      'extracted_data': extractedData,
      'is_verified': extractionVerified,
    };
  }

  TaxDocument copyWith({
    String? id,
    String? returnId,
    TaxDocumentType? documentType,
    String? fileName,
    String? storagePath,
    String? publicUrl,
    String? mimeType,
    int? fileSize,
    String? fileHash,
    ProcessingStatus? processingStatus,
    Map<String, dynamic>? extractedData,
    double? ocrConfidence,
    bool? extractionVerified,
    String? notes,
    DateTime? documentDate,
    String? uploadedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxDocument(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      storagePath: storagePath ?? this.storagePath,
      publicUrl: publicUrl ?? this.publicUrl,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      fileHash: fileHash ?? this.fileHash,
      processingStatus: processingStatus ?? this.processingStatus,
      extractedData: extractedData ?? this.extractedData,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      extractionVerified: extractionVerified ?? this.extractionVerified,
      notes: notes ?? this.notes,
      documentDate: documentDate ?? this.documentDate,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// =============================================================================
// Tax Audit Log
// =============================================================================

/// Comprehensive audit trail for tax return actions
/// 
/// IRS requires detailed logging of:
/// - Who accessed the return
/// - What changes were made
/// - When changes occurred
/// - From what device/location
/// 
/// Retention: 7 years per IRS requirements
class TaxAuditLog {
  final String? id;
  final String returnId;
  final String userId;

  /// Type of audit event
  final AuditEventType eventType;

  /// Human-readable description
  final String eventDescription;

  // ---------------------------------------------------------------------------
  // Change Details
  // ---------------------------------------------------------------------------
  
  /// Previous values (before change)
  final Map<String, dynamic>? previousValues;

  /// New values (after change)
  final Map<String, dynamic>? newValues;

  /// Field(s) that changed
  final List<String>? changedFields;

  // ---------------------------------------------------------------------------
  // Request Context
  // ---------------------------------------------------------------------------
  
  /// IP address of request
  final String? ipAddress;

  /// User agent string
  final String? userAgent;

  /// Device fingerprint
  final String? deviceFingerprint;

  /// Geographic location (derived from IP)
  final String? geoLocation;

  /// Session ID for correlation
  final String? sessionId;

  // ---------------------------------------------------------------------------
  // Additional Context
  // ---------------------------------------------------------------------------
  
  /// Any additional metadata
  final Map<String, dynamic>? metadata;

  /// When the event occurred
  final DateTime timestamp;

  const TaxAuditLog({
    this.id,
    required this.returnId,
    required this.userId,
    required this.eventType,
    required this.eventDescription,
    this.previousValues,
    this.newValues,
    this.changedFields,
    this.ipAddress,
    this.userAgent,
    this.deviceFingerprint,
    this.geoLocation,
    this.sessionId,
    this.metadata,
    required this.timestamp,
  });

  /// Create a log entry for return creation
  factory TaxAuditLog.returnCreated({
    required String returnId,
    required String userId,
    String? ipAddress,
    String? userAgent,
  }) {
    return TaxAuditLog(
      returnId: returnId,
      userId: userId,
      eventType: AuditEventType.returnCreated,
      eventDescription: 'Tax return created',
      ipAddress: ipAddress,
      userAgent: userAgent,
      timestamp: DateTime.now(),
    );
  }

  /// Create a log entry for field update
  factory TaxAuditLog.fieldUpdated({
    required String returnId,
    required String userId,
    required String fieldName,
    required dynamic oldValue,
    required dynamic newValue,
    String? ipAddress,
    String? userAgent,
  }) {
    return TaxAuditLog(
      returnId: returnId,
      userId: userId,
      eventType: AuditEventType.dataModified,
      eventDescription: 'Field "$fieldName" updated',
      previousValues: {fieldName: oldValue},
      newValues: {fieldName: newValue},
      changedFields: [fieldName],
      ipAddress: ipAddress,
      userAgent: userAgent,
      timestamp: DateTime.now(),
    );
  }

  /// Create a log entry for return submission
  factory TaxAuditLog.returnSubmitted({
    required String returnId,
    required String userId,
    required String submissionId,
    String? ipAddress,
    String? userAgent,
  }) {
    return TaxAuditLog(
      returnId: returnId,
      userId: userId,
      eventType: AuditEventType.submissionAttempted,
      eventDescription: 'Return submitted to IRS',
      metadata: {'submission_id': submissionId},
      ipAddress: ipAddress,
      userAgent: userAgent,
      timestamp: DateTime.now(),
    );
  }

  /// Create a log entry for signature
  factory TaxAuditLog.returnSigned({
    required String returnId,
    required String userId,
    required String signerType,
    String? ipAddress,
    String? userAgent,
  }) {
    return TaxAuditLog(
      returnId: returnId,
      userId: userId,
      eventType: AuditEventType.signatureCollected,
      eventDescription: 'Return signed by $signerType',
      metadata: {'signer_type': signerType},
      ipAddress: ipAddress,
      userAgent: userAgent,
      timestamp: DateTime.now(),
    );
  }

  factory TaxAuditLog.fromJson(Map<String, dynamic> json) {
    return TaxAuditLog(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      userId: json['user_id'] as String,
      eventType: AuditEventType.fromString(json['event_type'] as String?),
      // Database uses 'action' column
      eventDescription: (json['action'] ?? json['event_description'] ?? '') as String,
      // Database uses 'old_value'/'new_value' 
      previousValues: (json['old_value'] ?? json['previous_values']) as Map<String, dynamic>?,
      newValues: (json['new_value'] ?? json['new_values']) as Map<String, dynamic>?,
      changedFields: null, // Not in database schema
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      deviceFingerprint: json['device_fingerprint'] as String?,
      geoLocation: null, // Not in database schema
      sessionId: json['session_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : (json['timestamp'] != null 
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    // Match database schema: use 'action' not 'event_description',
    // 'old_value'/'new_value' not 'previous_values'/'new_values',
    // no 'changed_fields', no 'timestamp' (uses created_at default)
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'user_id': userId,
      'event_type': eventType.value,
      'action': eventDescription,
      'old_value': previousValues,
      'new_value': newValues,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'device_fingerprint': deviceFingerprint,
      'session_id': sessionId,
      'metadata': metadata,
    };
  }

  TaxAuditLog copyWith({
    String? id,
    String? returnId,
    String? userId,
    AuditEventType? eventType,
    String? eventDescription,
    Map<String, dynamic>? previousValues,
    Map<String, dynamic>? newValues,
    List<String>? changedFields,
    String? ipAddress,
    String? userAgent,
    String? deviceFingerprint,
    String? geoLocation,
    String? sessionId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return TaxAuditLog(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      userId: userId ?? this.userId,
      eventType: eventType ?? this.eventType,
      eventDescription: eventDescription ?? this.eventDescription,
      previousValues: previousValues ?? this.previousValues,
      newValues: newValues ?? this.newValues,
      changedFields: changedFields ?? this.changedFields,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      geoLocation: geoLocation ?? this.geoLocation,
      sessionId: sessionId ?? this.sessionId,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// =============================================================================
// Validation Error Model
// =============================================================================

/// Represents a validation error from IRS or internal checks
class TaxValidationError {
  /// Error code (IRS code or internal)
  final String errorCode;

  /// Human-readable error message
  final String message;

  /// Field that has the error
  final String? fieldName;

  /// Severity level
  final ValidationSeverity severity;

  /// Whether this is an IRS-defined error
  final bool isIrsError;

  /// Suggested fix
  final String? suggestedFix;

  const TaxValidationError({
    required this.errorCode,
    required this.message,
    this.fieldName,
    this.severity = ValidationSeverity.error,
    this.isIrsError = false,
    this.suggestedFix,
  });

  /// Check if error blocks submission
  bool get blocksSubmission => severity == ValidationSeverity.error;

  factory TaxValidationError.fromJson(Map<String, dynamic> json) {
    return TaxValidationError(
      errorCode: json['error_code'] as String,
      message: json['message'] as String,
      fieldName: json['field_name'] as String?,
      severity: ValidationSeverity.fromString(json['severity'] as String?),
      isIrsError: json['is_irs_error'] as bool? ?? false,
      suggestedFix: json['suggested_fix'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error_code': errorCode,
      'message': message,
      'field_name': fieldName,
      'severity': severity.value,
      'is_irs_error': isIrsError,
      'suggested_fix': suggestedFix,
    };
  }
}

/// Validation error severity
enum ValidationSeverity {
  warning('warning', 'Warning'),
  error('error', 'Error');

  final String value;
  final String displayName;

  const ValidationSeverity(this.value, this.displayName);

  static ValidationSeverity fromString(String? value) {
    return ValidationSeverity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ValidationSeverity.error,
    );
  }
}
