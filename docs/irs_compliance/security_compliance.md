# Security, Compliance & Data Protection

## Overview

This document outlines security requirements for IRS e-file compliance, including encryption, access controls, audit logging, and data protection standards per IRS Publication 4557.

---

## 1. IRS Publication 4557 Requirements

### 1.1 Required Security Controls

The IRS requires all Authorized e-file Providers to implement:

| Control Area | Requirement | Implementation |
|--------------|-------------|----------------|
| Written Security Plan | Document security policies | See Section 2 |
| Employee Training | Annual security awareness | Training module |
| Data Encryption | Encrypt sensitive data | AES-256, TLS 1.2+ |
| Access Controls | Limit data access | RBAC, MFA |
| Secure Storage | Protect stored data | Encrypted databases |
| Audit Logging | Log all access | Comprehensive logging |
| Incident Response | Handle breaches | Response plan |
| Data Disposal | Securely delete data | Secure wipe |

### 1.2 Compliance Checklist

```dart
enum ComplianceStatus {
  compliant,
  partiallyCompliant,
  nonCompliant,
  notApplicable,
}

class ComplianceChecklist {
  // Written Information Security Plan (WISP)
  ComplianceStatus wispDocumented = ComplianceStatus.nonCompliant;
  ComplianceStatus wispReviewedAnnually = ComplianceStatus.nonCompliant;
  
  // Employee Security
  ComplianceStatus backgroundChecks = ComplianceStatus.nonCompliant;
  ComplianceStatus securityTraining = ComplianceStatus.nonCompliant;
  ComplianceStatus accessTermination = ComplianceStatus.nonCompliant;
  
  // Physical Security
  ComplianceStatus secureFacility = ComplianceStatus.nonCompliant;
  ComplianceStatus lockedStorage = ComplianceStatus.nonCompliant;
  
  // System Security
  ComplianceStatus firewall = ComplianceStatus.nonCompliant;
  ComplianceStatus antivirus = ComplianceStatus.nonCompliant;
  ComplianceStatus patchManagement = ComplianceStatus.nonCompliant;
  ComplianceStatus encryption = ComplianceStatus.nonCompliant;
  
  // Data Protection
  ComplianceStatus dataClassification = ComplianceStatus.nonCompliant;
  ComplianceStatus dataRetention = ComplianceStatus.nonCompliant;
  ComplianceStatus dataDisposal = ComplianceStatus.nonCompliant;
  
  // Access Control
  ComplianceStatus multiFactorAuth = ComplianceStatus.compliant; // Already implemented
  ComplianceStatus roleBasedAccess = ComplianceStatus.nonCompliant;
  ComplianceStatus minimumPrivilege = ComplianceStatus.nonCompliant;
  
  // Audit & Monitoring
  ComplianceStatus auditLogging = ComplianceStatus.nonCompliant;
  ComplianceStatus intrusionDetection = ComplianceStatus.nonCompliant;
  ComplianceStatus incidentResponse = ComplianceStatus.nonCompliant;
}
```

---

## 2. Data Classification

### 2.1 Sensitivity Levels

```dart
enum DataSensitivity {
  public,           // Can be freely shared
  internal,         // Internal use only
  confidential,     // Limited access
  restricted,       // Highly sensitive - PII, SSN
}

class DataClassification {
  static const classifications = {
    // Public data
    'tax_year': DataSensitivity.public,
    'filing_status_label': DataSensitivity.public,
    
    // Internal data
    'tax_return_id': DataSensitivity.internal,
    'calculation_results': DataSensitivity.internal,
    
    // Confidential data
    'email': DataSensitivity.confidential,
    'phone': DataSensitivity.confidential,
    'address': DataSensitivity.confidential,
    'date_of_birth': DataSensitivity.confidential,
    'employer_name': DataSensitivity.confidential,
    
    // Restricted data (requires encryption)
    'ssn': DataSensitivity.restricted,
    'ein': DataSensitivity.restricted,
    'itin': DataSensitivity.restricted,
    'bank_account_number': DataSensitivity.restricted,
    'bank_routing_number': DataSensitivity.restricted,
    'ip_pin': DataSensitivity.restricted,
    'identity_documents': DataSensitivity.restricted,
  };
  
  static bool requiresEncryption(String fieldName) {
    return classifications[fieldName] == DataSensitivity.restricted;
  }
  
  static bool requiresMasking(String fieldName) {
    return classifications[fieldName] == DataSensitivity.restricted ||
           classifications[fieldName] == DataSensitivity.confidential;
  }
}
```

### 2.2 Data Handling Rules

```dart
class DataHandlingRules {
  // SSN Handling
  static const ssnRules = DataHandlingPolicy(
    encryption: EncryptionRequirement.required,
    encryptionAlgorithm: 'AES-256',
    masking: MaskingRule.lastFour,
    logging: LoggingRule.accessOnly, // Never log actual value
    retention: Duration(days: 1095), // 3 years per IRS
    disposal: DisposalMethod.secureWipe,
  );
  
  // Bank Account Handling
  static const bankAccountRules = DataHandlingPolicy(
    encryption: EncryptionRequirement.required,
    encryptionAlgorithm: 'AES-256',
    masking: MaskingRule.lastFour,
    logging: LoggingRule.accessOnly,
    retention: Duration(days: 1095),
    disposal: DisposalMethod.secureWipe,
  );
  
  // Address Handling
  static const addressRules = DataHandlingPolicy(
    encryption: EncryptionRequirement.atRest,
    encryptionAlgorithm: 'AES-256',
    masking: MaskingRule.partial,
    logging: LoggingRule.full,
    retention: Duration(days: 1095),
    disposal: DisposalMethod.standard,
  );
}

class DataHandlingPolicy {
  final EncryptionRequirement encryption;
  final String encryptionAlgorithm;
  final MaskingRule masking;
  final LoggingRule logging;
  final Duration retention;
  final DisposalMethod disposal;
  
  const DataHandlingPolicy({
    required this.encryption,
    required this.encryptionAlgorithm,
    required this.masking,
    required this.logging,
    required this.retention,
    required this.disposal,
  });
}

enum EncryptionRequirement { none, atRest, inTransit, required }
enum MaskingRule { none, partial, lastFour, full }
enum LoggingRule { none, accessOnly, full }
enum DisposalMethod { standard, secureWipe, physicalDestruction }
```

---

## 3. Encryption Implementation

### 3.1 Encryption Service

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'app_encryption_key';
  
  // Initialize or retrieve encryption key
  static Future<Key> _getKey() async {
    String? keyString = await _storage.read(key: _keyStorageKey);
    
    if (keyString == null) {
      // Generate new key
      final key = Key.fromSecureRandom(32); // 256-bit
      await _storage.write(key: _keyStorageKey, value: key.base64);
      return key;
    }
    
    return Key.fromBase64(keyString);
  }
  
  // Encrypt sensitive data
  static Future<String> encrypt(String plaintext) async {
    final key = await _getKey();
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    
    // Return IV + encrypted data (both needed for decryption)
    return '${iv.base64}:${encrypted.base64}';
  }
  
  // Decrypt sensitive data
  static Future<String> decrypt(String encryptedData) async {
    final key = await _getKey();
    
    final parts = encryptedData.split(':');
    if (parts.length != 2) throw FormatException('Invalid encrypted data format');
    
    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt(encrypted, iv: iv);
  }
  
  // Hash data (one-way, for verification)
  static String hash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Encrypt SSN specifically
  static Future<EncryptedSSN> encryptSSN(String ssn) async {
    final cleaned = ssn.replaceAll(RegExp(r'[^0-9]'), '');
    final encrypted = await encrypt(cleaned);
    final lastFour = cleaned.length >= 4 
        ? cleaned.substring(cleaned.length - 4) 
        : '****';
    
    return EncryptedSSN(
      encrypted: encrypted,
      lastFour: lastFour,
    );
  }
  
  // Encrypt bank account
  static Future<EncryptedBankAccount> encryptBankAccount({
    required String routingNumber,
    required String accountNumber,
  }) async {
    final encryptedRouting = await encrypt(routingNumber);
    final encryptedAccount = await encrypt(accountNumber);
    final lastFour = accountNumber.length >= 4
        ? accountNumber.substring(accountNumber.length - 4)
        : '****';
    
    return EncryptedBankAccount(
      encryptedRoutingNumber: encryptedRouting,
      encryptedAccountNumber: encryptedAccount,
      lastFourAccount: lastFour,
    );
  }
}

class EncryptedSSN {
  final String encrypted;
  final String lastFour;
  
  String get masked => 'XXX-XX-$lastFour';
  
  const EncryptedSSN({
    required this.encrypted,
    required this.lastFour,
  });
}

class EncryptedBankAccount {
  final String encryptedRoutingNumber;
  final String encryptedAccountNumber;
  final String lastFourAccount;
  
  String get maskedAccount => '****$lastFourAccount';
  
  const EncryptedBankAccount({
    required this.encryptedRoutingNumber,
    required this.encryptedAccountNumber,
    required this.lastFourAccount,
  });
}
```

### 3.2 Supabase Column-Level Encryption

```sql
-- Enable pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encryption key (in practice, use Supabase Vault)
-- This key should be stored securely, not in SQL

-- Encrypted SSN storage
CREATE OR REPLACE FUNCTION encrypt_ssn(ssn TEXT, key TEXT)
RETURNS BYTEA AS $$
BEGIN
  RETURN pgp_sym_encrypt(ssn, key);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION decrypt_ssn(encrypted_ssn BYTEA, key TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN pgp_sym_decrypt(encrypted_ssn, key);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Example: Insert encrypted SSN
-- INSERT INTO taxpayers (ssn_encrypted, ssn_last_four)
-- VALUES (encrypt_ssn('123456789', 'encryption_key'), '6789');

-- Row-Level Security for sensitive data
ALTER TABLE taxpayers ENABLE ROW LEVEL SECURITY;

CREATE POLICY taxpayer_access_policy ON taxpayers
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

---

## 4. Access Control

### 4.1 Role-Based Access Control (RBAC)

```dart
enum UserRole {
  taxpayer,        // End user filing their return
  preparer,        // Tax professional preparing returns
  reviewer,        // QA/review role
  admin,           // System administrator
  superAdmin,      // Full access
}

class Permission {
  static const viewOwnReturn = 'view_own_return';
  static const editOwnReturn = 'edit_own_return';
  static const submitOwnReturn = 'submit_own_return';
  static const viewClientReturns = 'view_client_returns';
  static const editClientReturns = 'edit_client_returns';
  static const submitClientReturns = 'submit_client_returns';
  static const viewAllReturns = 'view_all_returns';
  static const viewAuditLogs = 'view_audit_logs';
  static const manageUsers = 'manage_users';
  static const systemSettings = 'system_settings';
  static const viewDecryptedSSN = 'view_decrypted_ssn';
  static const exportData = 'export_data';
}

class RolePermissions {
  static const rolePermissions = {
    UserRole.taxpayer: [
      Permission.viewOwnReturn,
      Permission.editOwnReturn,
      Permission.submitOwnReturn,
    ],
    UserRole.preparer: [
      Permission.viewOwnReturn,
      Permission.editOwnReturn,
      Permission.submitOwnReturn,
      Permission.viewClientReturns,
      Permission.editClientReturns,
      Permission.submitClientReturns,
    ],
    UserRole.reviewer: [
      Permission.viewAllReturns,
      Permission.viewAuditLogs,
    ],
    UserRole.admin: [
      Permission.viewAllReturns,
      Permission.viewAuditLogs,
      Permission.manageUsers,
    ],
    UserRole.superAdmin: [
      Permission.viewAllReturns,
      Permission.viewAuditLogs,
      Permission.manageUsers,
      Permission.systemSettings,
      Permission.viewDecryptedSSN,
      Permission.exportData,
    ],
  };
  
  static bool hasPermission(UserRole role, String permission) {
    return rolePermissions[role]?.contains(permission) ?? false;
  }
}
```

### 4.2 Access Control Middleware

```dart
class AccessControlService {
  final AuthService _authService;
  final AuditLogService _auditLog;
  
  AccessControlService(this._authService, this._auditLog);
  
  Future<bool> canAccess({
    required String permission,
    required String resourceId,
    required String resourceType,
  }) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return false;
    
    // Check permission
    final hasPermission = RolePermissions.hasPermission(user.role, permission);
    
    // Log access attempt
    await _auditLog.log(AuditEvent(
      userId: user.id,
      action: 'access_check',
      resourceType: resourceType,
      resourceId: resourceId,
      permission: permission,
      granted: hasPermission,
      timestamp: DateTime.now(),
    ));
    
    return hasPermission;
  }
  
  Future<void> enforceAccess({
    required String permission,
    required String resourceId,
    required String resourceType,
  }) async {
    final canAccess = await this.canAccess(
      permission: permission,
      resourceId: resourceId,
      resourceType: resourceType,
    );
    
    if (!canAccess) {
      throw AccessDeniedException(
        'Access denied: $permission on $resourceType/$resourceId',
      );
    }
  }
}

class AccessDeniedException implements Exception {
  final String message;
  AccessDeniedException(this.message);
}
```

---

## 5. Audit Logging

### 5.1 Audit Event Model

```dart
class AuditEvent {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String? sessionId;
  final String action;
  final String resourceType;
  final String? resourceId;
  final String? permission;
  final bool? granted;
  final Map<String, dynamic>? metadata;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceId;
  
  // What changed (for modifications)
  final Map<String, dynamic>? previousValue;
  final Map<String, dynamic>? newValue;
  
  // Do NOT log sensitive data values
  // Only log that field was accessed/modified
  
  const AuditEvent({
    String? id,
    required this.timestamp,
    required this.userId,
    this.sessionId,
    required this.action,
    required this.resourceType,
    this.resourceId,
    this.permission,
    this.granted,
    this.metadata,
    this.ipAddress,
    this.userAgent,
    this.deviceId,
    this.previousValue,
    this.newValue,
  }) : id = id ?? uuid.v4();
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'user_id': userId,
    'session_id': sessionId,
    'action': action,
    'resource_type': resourceType,
    'resource_id': resourceId,
    'permission': permission,
    'granted': granted,
    'metadata': metadata,
    'ip_address': ipAddress,
    'user_agent': userAgent,
    'device_id': deviceId,
    'previous_value': previousValue,
    'new_value': newValue,
  };
}

// Audit actions that must be logged
class AuditActions {
  // Authentication
  static const login = 'auth.login';
  static const logout = 'auth.logout';
  static const loginFailed = 'auth.login_failed';
  static const mfaVerified = 'auth.mfa_verified';
  static const passwordChanged = 'auth.password_changed';
  static const passwordReset = 'auth.password_reset';
  
  // Tax Return Actions
  static const returnCreated = 'return.created';
  static const returnViewed = 'return.viewed';
  static const returnUpdated = 'return.updated';
  static const returnSubmitted = 'return.submitted';
  static const returnDeleted = 'return.deleted';
  
  // Sensitive Data Access
  static const ssnViewed = 'sensitive.ssn_viewed';
  static const ssnUpdated = 'sensitive.ssn_updated';
  static const bankAccountViewed = 'sensitive.bank_viewed';
  static const bankAccountUpdated = 'sensitive.bank_updated';
  
  // Document Actions
  static const documentUploaded = 'document.uploaded';
  static const documentViewed = 'document.viewed';
  static const documentDeleted = 'document.deleted';
  
  // E-File Actions
  static const efileSubmitted = 'efile.submitted';
  static const efileAccepted = 'efile.accepted';
  static const efileRejected = 'efile.rejected';
  
  // Admin Actions
  static const userCreated = 'admin.user_created';
  static const userModified = 'admin.user_modified';
  static const userDeleted = 'admin.user_deleted';
  static const roleChanged = 'admin.role_changed';
  static const dataExported = 'admin.data_exported';
}
```

### 5.2 Audit Log Service

```dart
class AuditLogService {
  final SupabaseClient _supabase;
  
  AuditLogService(this._supabase);
  
  Future<void> log(AuditEvent event) async {
    try {
      await _supabase.from('audit_logs').insert(event.toJson());
    } catch (e) {
      // Audit logging should never fail silently
      // but also shouldn't break the app
      print('Audit log error: $e');
      // Send to backup logging (e.g., local storage, remote service)
      await _backupLog(event);
    }
  }
  
  // Log with automatic context
  Future<void> logAction({
    required String action,
    required String resourceType,
    String? resourceId,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
  }) async {
    final user = await _getCurrentUser();
    final deviceInfo = await _getDeviceInfo();
    
    await log(AuditEvent(
      timestamp: DateTime.now(),
      userId: user?.id ?? 'anonymous',
      sessionId: user?.sessionId,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      metadata: metadata,
      ipAddress: await _getIPAddress(),
      userAgent: deviceInfo.userAgent,
      deviceId: deviceInfo.deviceId,
      previousValue: _sanitizeForLogging(previousValue),
      newValue: _sanitizeForLogging(newValue),
    ));
  }
  
  // Remove sensitive values before logging
  Map<String, dynamic>? _sanitizeForLogging(Map<String, dynamic>? data) {
    if (data == null) return null;
    
    final sanitized = Map<String, dynamic>.from(data);
    
    // Replace sensitive fields with indicators
    const sensitiveFields = ['ssn', 'bank_account', 'routing_number', 'ip_pin'];
    for (final field in sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }
  
  // Query audit logs with filters
  Future<List<AuditEvent>> query({
    String? userId,
    String? action,
    String? resourceType,
    String? resourceId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    var query = _supabase.from('audit_logs').select();
    
    if (userId != null) query = query.eq('user_id', userId);
    if (action != null) query = query.eq('action', action);
    if (resourceType != null) query = query.eq('resource_type', resourceType);
    if (resourceId != null) query = query.eq('resource_id', resourceId);
    if (startDate != null) query = query.gte('timestamp', startDate.toIso8601String());
    if (endDate != null) query = query.lte('timestamp', endDate.toIso8601String());
    
    final response = await query.order('timestamp', ascending: false).limit(limit);
    
    return (response as List).map((e) => AuditEvent.fromJson(e)).toList();
  }
}
```

### 5.3 Supabase Audit Table

```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_id TEXT NOT NULL,
  session_id TEXT,
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id TEXT,
  permission TEXT,
  granted BOOLEAN,
  metadata JSONB,
  ip_address INET,
  user_agent TEXT,
  device_id TEXT,
  previous_value JSONB,
  new_value JSONB,
  
  -- Indexes for common queries
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_audit_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_resource ON audit_logs(resource_type, resource_id);

-- RLS: Only admins can query audit logs
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY audit_admin_read ON audit_logs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE user_roles.user_id = auth.uid() 
      AND user_roles.role IN ('admin', 'super_admin')
    )
  );

-- Prevent deletion of audit logs
CREATE POLICY audit_no_delete ON audit_logs
  FOR DELETE
  USING (false);

-- Prevent updates to audit logs
CREATE POLICY audit_no_update ON audit_logs
  FOR UPDATE
  USING (false);
```

---

## 6. Data Retention & Disposal

### 6.1 Retention Policy

```dart
class DataRetentionPolicy {
  // IRS requires 3 years minimum for tax records
  static const taxReturnRetention = Duration(days: 1095); // 3 years
  static const auditLogRetention = Duration(days: 2555);  // 7 years
  static const sessionLogRetention = Duration(days: 90);  // 90 days
  
  // Automated cleanup job
  static Future<void> enforceRetention(SupabaseClient supabase) async {
    final now = DateTime.now();
    
    // Delete old session logs
    final sessionCutoff = now.subtract(sessionLogRetention);
    await supabase.from('session_logs')
        .delete()
        .lt('created_at', sessionCutoff.toIso8601String());
    
    // Archive old tax returns (don't delete, move to archive)
    final taxCutoff = now.subtract(taxReturnRetention);
    // Implementation: Move to archive table, then delete from main
  }
}
```

### 6.2 Secure Disposal

```dart
class SecureDisposalService {
  // Securely delete user data
  static Future<void> deleteUserData(String userId) async {
    // 1. Delete all tax returns
    await _deleteAndOverwrite('tax_returns', 'user_id', userId);
    
    // 2. Delete all documents from storage
    await _deleteStorageFiles('user_documents/$userId');
    
    // 3. Delete all income forms
    await _deleteAndOverwrite('w2_forms', 'user_id', userId);
    await _deleteAndOverwrite('form_1099_int', 'user_id', userId);
    // ... other forms
    
    // 4. Delete taxpayer records (this cascades)
    await _deleteAndOverwrite('taxpayers', 'user_id', userId);
    
    // 5. Log the deletion
    await _logDeletion(userId);
  }
  
  // Overwrite before delete for sensitive data
  static Future<void> _deleteAndOverwrite(
    String table, 
    String column, 
    String value,
  ) async {
    // For tables with encrypted fields, no overwrite needed
    // Just delete - encryption key destruction handles security
    await supabase.from(table).delete().eq(column, value);
  }
}
```

---

## 7. Session Security

### 7.1 Session Management

```dart
class SessionSecurityService {
  static const sessionTimeout = Duration(minutes: 30);
  static const maxConcurrentSessions = 3;
  
  // Validate session
  Future<bool> validateSession(String sessionId) async {
    final session = await _getSession(sessionId);
    if (session == null) return false;
    
    // Check timeout
    final lastActivity = session.lastActivityAt;
    if (DateTime.now().difference(lastActivity) > sessionTimeout) {
      await _invalidateSession(sessionId);
      return false;
    }
    
    // Check for suspicious activity
    if (await _detectSuspiciousActivity(session)) {
      await _invalidateSession(sessionId);
      await _notifyUser(session.userId, 'Suspicious activity detected');
      return false;
    }
    
    // Update last activity
    await _updateLastActivity(sessionId);
    return true;
  }
  
  // Detect suspicious activity
  Future<bool> _detectSuspiciousActivity(Session session) async {
    // IP address change mid-session
    // Unusual access patterns
    // Multiple failed sensitive operations
    return false;
  }
  
  // Force re-authentication for sensitive operations
  Future<void> requireReauth({
    required String operation,
    required Function onSuccess,
  }) async {
    // Show MFA verification dialog
    final verified = await _verifyMFA();
    if (verified) {
      await onSuccess();
      await _auditLog.logAction(
        action: 'reauth.verified',
        resourceType: 'session',
        metadata: {'operation': operation},
      );
    }
  }
}
```

---

## 8. Implementation Checklist

### 8.1 Phase 1: Foundation
- [ ] Implement EncryptionService
- [ ] Update Supabase schema with encrypted columns
- [ ] Implement AuditLogService
- [ ] Create audit_logs table

### 8.2 Phase 2: Access Control
- [ ] Define roles and permissions
- [ ] Implement RBAC service
- [ ] Add RLS policies to Supabase
- [ ] Create access middleware

### 8.3 Phase 3: Compliance
- [ ] Document security policies
- [ ] Implement data retention
- [ ] Create secure disposal procedures
- [ ] Set up session management

### 8.4 Phase 4: Monitoring
- [ ] Set up audit log dashboard
- [ ] Configure alerts for suspicious activity
- [ ] Implement intrusion detection
- [ ] Create compliance reports

---

## 9. Related Documents

- [Audit Trail](./audit_trail.md)
- [Identity Verification](./identity_verification.md)
- [E-File Transmission](./efile_transmission.md)
- [Testing & Validation](./testing_validation.md)
