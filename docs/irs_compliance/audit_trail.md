# Audit Trail & Record Retention

## Overview

This document details IRS requirements for audit trails, record retention, and compliance logging per IRS Publications 4164 and 4557. Tax return data must be retained for a minimum of 3 years and all access must be logged.

---

## 1. IRS Record Retention Requirements

### 1.1 Retention Periods

| Record Type | Minimum Retention | Reference |
|-------------|-------------------|-----------|
| Tax Returns | 3 years from filing date | IRC §6501 |
| Supporting Documents | 3 years | Pub 4164 |
| Form 8879 (e-file auth) | 3 years | Pub 4164 |
| Acknowledgments | 3 years | Pub 4164 |
| Audit Logs | 7 years recommended | Pub 4557 |
| Access Logs | 3 years | Pub 4557 |
| Security Incidents | 7 years | Pub 4557 |

### 1.2 Retention Policy Model

```dart
class RetentionPolicy {
  static const taxReturnRetention = Duration(days: 1095);   // 3 years
  static const auditLogRetention = Duration(days: 2555);    // 7 years
  static const sessionLogRetention = Duration(days: 90);    // 90 days
  static const accessLogRetention = Duration(days: 1095);   // 3 years
  static const securityIncidentRetention = Duration(days: 2555); // 7 years
  
  static Duration getRetention(RecordType type) {
    return switch (type) {
      RecordType.taxReturn => taxReturnRetention,
      RecordType.form8879 => taxReturnRetention,
      RecordType.acknowledgment => taxReturnRetention,
      RecordType.supportingDocument => taxReturnRetention,
      RecordType.auditLog => auditLogRetention,
      RecordType.accessLog => accessLogRetention,
      RecordType.sessionLog => sessionLogRetention,
      RecordType.securityIncident => securityIncidentRetention,
    };
  }
  
  static DateTime getExpirationDate(RecordType type, DateTime createdAt) {
    return createdAt.add(getRetention(type));
  }
}

enum RecordType {
  taxReturn,
  form8879,
  acknowledgment,
  supportingDocument,
  auditLog,
  accessLog,
  sessionLog,
  securityIncident,
}
```

---

## 2. Audit Event Types

### 2.1 Required Audit Events

```dart
class AuditEventTypes {
  // ===== AUTHENTICATION =====
  static const authLogin = 'auth.login';
  static const authLogout = 'auth.logout';
  static const authLoginFailed = 'auth.login_failed';
  static const authMFARequested = 'auth.mfa_requested';
  static const authMFAVerified = 'auth.mfa_verified';
  static const authMFAFailed = 'auth.mfa_failed';
  static const authPasswordChanged = 'auth.password_changed';
  static const authPasswordResetRequested = 'auth.password_reset_requested';
  static const authPasswordResetCompleted = 'auth.password_reset_completed';
  static const authSessionExpired = 'auth.session_expired';
  static const authSessionTerminated = 'auth.session_terminated';
  
  // ===== TAX RETURN LIFECYCLE =====
  static const returnCreated = 'return.created';
  static const returnOpened = 'return.opened';
  static const returnSaved = 'return.saved';
  static const returnCalculated = 'return.calculated';
  static const returnValidated = 'return.validated';
  static const returnSigned = 'return.signed';
  static const returnSubmitted = 'return.submitted';
  static const returnAccepted = 'return.accepted';
  static const returnRejected = 'return.rejected';
  static const returnAmended = 'return.amended';
  static const returnDeleted = 'return.deleted';
  static const returnPrinted = 'return.printed';
  static const returnExported = 'return.exported';
  
  // ===== SENSITIVE DATA ACCESS =====
  static const ssnViewed = 'sensitive.ssn_viewed';
  static const ssnEntered = 'sensitive.ssn_entered';
  static const ssnUpdated = 'sensitive.ssn_updated';
  static const ssnDecrypted = 'sensitive.ssn_decrypted';
  static const bankAccountViewed = 'sensitive.bank_account_viewed';
  static const bankAccountEntered = 'sensitive.bank_account_entered';
  static const bankAccountUpdated = 'sensitive.bank_account_updated';
  static const ipPinEntered = 'sensitive.ip_pin_entered';
  
  // ===== DOCUMENT ACTIONS =====
  static const documentUploaded = 'document.uploaded';
  static const documentViewed = 'document.viewed';
  static const documentDownloaded = 'document.downloaded';
  static const documentDeleted = 'document.deleted';
  static const documentOCRProcessed = 'document.ocr_processed';
  
  // ===== FORM ACTIONS =====
  static const formW2Added = 'form.w2_added';
  static const formW2Updated = 'form.w2_updated';
  static const formW2Deleted = 'form.w2_deleted';
  static const form1099Added = 'form.1099_added';
  static const form1099Updated = 'form.1099_updated';
  static const form1099Deleted = 'form.1099_deleted';
  
  // ===== E-FILE ACTIONS =====
  static const efileXMLGenerated = 'efile.xml_generated';
  static const efileTransmitted = 'efile.transmitted';
  static const efileAckReceived = 'efile.ack_received';
  static const efileAckPolled = 'efile.ack_polled';
  
  // ===== CONSENT ACTIONS =====
  static const consentGiven = 'consent.given';
  static const consentRevoked = 'consent.revoked';
  static const signatureCreated = 'signature.created';
  static const signatureVerified = 'signature.verified';
  
  // ===== ADMIN ACTIONS =====
  static const adminUserCreated = 'admin.user_created';
  static const adminUserModified = 'admin.user_modified';
  static const adminUserDeleted = 'admin.user_deleted';
  static const adminUserLocked = 'admin.user_locked';
  static const adminUserUnlocked = 'admin.user_unlocked';
  static const adminRoleChanged = 'admin.role_changed';
  static const adminDataExported = 'admin.data_exported';
  static const adminSystemConfigChanged = 'admin.config_changed';
  
  // ===== SECURITY EVENTS =====
  static const securitySuspiciousActivity = 'security.suspicious_activity';
  static const securityBruteForceDetected = 'security.brute_force';
  static const securityIPBlocked = 'security.ip_blocked';
  static const securityDataBreachDetected = 'security.breach_detected';
}
```

### 2.2 Audit Event Model

```dart
class AuditEvent {
  final String id;
  final DateTime timestamp;
  final String eventType;
  final String userId;
  final String? sessionId;
  final String resourceType;
  final String? resourceId;
  
  // Context information
  final String ipAddress;
  final String? userAgent;
  final String? deviceId;
  final String? geoLocation;
  
  // Event details
  final String? description;
  final Map<String, dynamic>? metadata;
  
  // Change tracking (for modifications)
  final List<FieldChange>? changes;
  
  // Result
  final AuditResult result;
  final String? errorMessage;
  
  const AuditEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.userId,
    this.sessionId,
    required this.resourceType,
    this.resourceId,
    required this.ipAddress,
    this.userAgent,
    this.deviceId,
    this.geoLocation,
    this.description,
    this.metadata,
    this.changes,
    required this.result,
    this.errorMessage,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'event_type': eventType,
    'user_id': userId,
    'session_id': sessionId,
    'resource_type': resourceType,
    'resource_id': resourceId,
    'ip_address': ipAddress,
    'user_agent': userAgent,
    'device_id': deviceId,
    'geo_location': geoLocation,
    'description': description,
    'metadata': metadata,
    'changes': changes?.map((c) => c.toJson()).toList(),
    'result': result.name,
    'error_message': errorMessage,
  };
  
  factory AuditEvent.fromJson(Map<String, dynamic> json) => AuditEvent(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    eventType: json['event_type'],
    userId: json['user_id'],
    sessionId: json['session_id'],
    resourceType: json['resource_type'],
    resourceId: json['resource_id'],
    ipAddress: json['ip_address'],
    userAgent: json['user_agent'],
    deviceId: json['device_id'],
    geoLocation: json['geo_location'],
    description: json['description'],
    metadata: json['metadata'],
    changes: (json['changes'] as List?)
        ?.map((c) => FieldChange.fromJson(c))
        .toList(),
    result: AuditResult.values.byName(json['result']),
    errorMessage: json['error_message'],
  );
}

class FieldChange {
  final String fieldName;
  final String? oldValue;
  final String? newValue;
  final bool isSensitive;
  
  const FieldChange({
    required this.fieldName,
    this.oldValue,
    this.newValue,
    this.isSensitive = false,
  });
  
  Map<String, dynamic> toJson() => {
    'field_name': fieldName,
    'old_value': isSensitive ? '[REDACTED]' : oldValue,
    'new_value': isSensitive ? '[REDACTED]' : newValue,
    'is_sensitive': isSensitive,
  };
  
  factory FieldChange.fromJson(Map<String, dynamic> json) => FieldChange(
    fieldName: json['field_name'],
    oldValue: json['old_value'],
    newValue: json['new_value'],
    isSensitive: json['is_sensitive'] ?? false,
  );
}

enum AuditResult {
  success,
  failure,
  denied,
  error,
}
```

---

## 3. Audit Logging Service

### 3.1 Core Service Implementation

```dart
class AuditLogService {
  final SupabaseClient _supabase;
  final DeviceInfoService _deviceInfo;
  final SessionService _sessionService;
  
  AuditLogService(
    this._supabase,
    this._deviceInfo,
    this._sessionService,
  );
  
  // Main logging method
  Future<void> log({
    required String eventType,
    required String resourceType,
    String? resourceId,
    String? description,
    Map<String, dynamic>? metadata,
    List<FieldChange>? changes,
    AuditResult result = AuditResult.success,
    String? errorMessage,
  }) async {
    try {
      final user = _sessionService.currentUser;
      final session = _sessionService.currentSession;
      final device = await _deviceInfo.getDeviceInfo();
      
      final event = AuditEvent(
        id: const Uuid().v4(),
        timestamp: DateTime.now().toUtc(),
        eventType: eventType,
        userId: user?.id ?? 'anonymous',
        sessionId: session?.id,
        resourceType: resourceType,
        resourceId: resourceId,
        ipAddress: await _getIPAddress(),
        userAgent: device.userAgent,
        deviceId: device.deviceId,
        geoLocation: await _getGeoLocation(),
        description: description,
        metadata: _sanitizeMetadata(metadata),
        changes: changes,
        result: result,
        errorMessage: errorMessage,
      );
      
      await _persistEvent(event);
    } catch (e) {
      // Audit logging should never fail silently but also shouldn't crash app
      _handleLoggingError(e, eventType, resourceType);
    }
  }
  
  // Convenience methods for common events
  Future<void> logLogin({
    required String userId,
    required LoginMethod method,
    required bool success,
    String? failureReason,
  }) => log(
    eventType: success 
        ? AuditEventTypes.authLogin 
        : AuditEventTypes.authLoginFailed,
    resourceType: 'auth',
    resourceId: userId,
    metadata: {'method': method.name},
    result: success ? AuditResult.success : AuditResult.failure,
    errorMessage: failureReason,
  );
  
  Future<void> logSensitiveDataAccess({
    required String dataType,
    required String resourceId,
    required AccessAction action,
  }) => log(
    eventType: 'sensitive.${dataType}_${action.name}',
    resourceType: dataType,
    resourceId: resourceId,
    description: '${action.name} $dataType',
  );
  
  Future<void> logReturnAction({
    required String returnId,
    required String action,
    Map<String, dynamic>? details,
  }) => log(
    eventType: 'return.$action',
    resourceType: 'tax_return',
    resourceId: returnId,
    metadata: details,
  );
  
  Future<void> logDataChange({
    required String resourceType,
    required String resourceId,
    required List<FieldChange> changes,
  }) => log(
    eventType: '$resourceType.updated',
    resourceType: resourceType,
    resourceId: resourceId,
    changes: changes,
  );
  
  // Sanitize metadata to remove sensitive values
  Map<String, dynamic>? _sanitizeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;
    
    final sanitized = Map<String, dynamic>.from(metadata);
    const sensitiveKeys = ['ssn', 'password', 'pin', 'bank_account', 'routing_number'];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }
  
  // Persist to database
  Future<void> _persistEvent(AuditEvent event) async {
    await _supabase.from('audit_logs').insert(event.toJson());
  }
  
  // Handle logging errors
  void _handleLoggingError(dynamic error, String eventType, String resourceType) {
    // Log to local storage as backup
    // Send to error monitoring service
    print('Audit log error for $eventType on $resourceType: $error');
  }
  
  Future<String> _getIPAddress() async {
    // Get client IP from request context or external service
    return '0.0.0.0'; // Placeholder
  }
  
  Future<String?> _getGeoLocation() async {
    // Optional: Geo-locate IP for security
    return null;
  }
}

enum LoginMethod { email, google, apple, phone }
enum AccessAction { viewed, entered, updated, decrypted }
```

### 3.2 Audit Log Query Service

```dart
class AuditQueryService {
  final SupabaseClient _supabase;
  
  AuditQueryService(this._supabase);
  
  // Query audit logs with filters
  Future<List<AuditEvent>> query({
    String? userId,
    String? eventType,
    String? resourceType,
    String? resourceId,
    DateTime? startDate,
    DateTime? endDate,
    AuditResult? result,
    int limit = 100,
    int offset = 0,
  }) async {
    var query = _supabase.from('audit_logs').select();
    
    if (userId != null) query = query.eq('user_id', userId);
    if (eventType != null) query = query.eq('event_type', eventType);
    if (resourceType != null) query = query.eq('resource_type', resourceType);
    if (resourceId != null) query = query.eq('resource_id', resourceId);
    if (startDate != null) {
      query = query.gte('timestamp', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('timestamp', endDate.toIso8601String());
    }
    if (result != null) query = query.eq('result', result.name);
    
    final response = await query
        .order('timestamp', ascending: false)
        .range(offset, offset + limit - 1);
    
    return (response as List)
        .map((e) => AuditEvent.fromJson(e))
        .toList();
  }
  
  // Get activity for a specific return
  Future<List<AuditEvent>> getReturnActivity(String returnId) async {
    return query(
      resourceType: 'tax_return',
      resourceId: returnId,
    );
  }
  
  // Get user activity history
  Future<List<AuditEvent>> getUserActivity(
    String userId, {
    DateTime? since,
    int limit = 50,
  }) async {
    return query(
      userId: userId,
      startDate: since,
      limit: limit,
    );
  }
  
  // Get failed login attempts
  Future<List<AuditEvent>> getFailedLogins({
    String? userId,
    String? ipAddress,
    Duration window = const Duration(hours: 1),
  }) async {
    final since = DateTime.now().subtract(window);
    
    var query = _supabase
        .from('audit_logs')
        .select()
        .eq('event_type', AuditEventTypes.authLoginFailed)
        .gte('timestamp', since.toIso8601String());
    
    if (userId != null) query = query.eq('user_id', userId);
    if (ipAddress != null) query = query.eq('ip_address', ipAddress);
    
    final response = await query.order('timestamp', ascending: false);
    
    return (response as List)
        .map((e) => AuditEvent.fromJson(e))
        .toList();
  }
  
  // Get sensitive data access log
  Future<List<AuditEvent>> getSensitiveDataAccess({
    String? userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return query(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    ).then((events) => events
        .where((e) => e.eventType.startsWith('sensitive.'))
        .toList());
  }
  
  // Generate compliance report
  Future<ComplianceReport> generateComplianceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allEvents = await query(
      startDate: startDate,
      endDate: endDate,
      limit: 10000,
    );
    
    return ComplianceReport(
      periodStart: startDate,
      periodEnd: endDate,
      totalEvents: allEvents.length,
      eventsByType: _groupByEventType(allEvents),
      failedLogins: allEvents
          .where((e) => e.eventType == AuditEventTypes.authLoginFailed)
          .length,
      sensitiveDataAccess: allEvents
          .where((e) => e.eventType.startsWith('sensitive.'))
          .length,
      securityIncidents: allEvents
          .where((e) => e.eventType.startsWith('security.'))
          .length,
    );
  }
  
  Map<String, int> _groupByEventType(List<AuditEvent> events) {
    final counts = <String, int>{};
    for (final event in events) {
      counts[event.eventType] = (counts[event.eventType] ?? 0) + 1;
    }
    return counts;
  }
}

class ComplianceReport {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalEvents;
  final Map<String, int> eventsByType;
  final int failedLogins;
  final int sensitiveDataAccess;
  final int securityIncidents;
  
  const ComplianceReport({
    required this.periodStart,
    required this.periodEnd,
    required this.totalEvents,
    required this.eventsByType,
    required this.failedLogins,
    required this.sensitiveDataAccess,
    required this.securityIncidents,
  });
}
```

---

## 4. Database Schema

```sql
-- Main Audit Logs Table
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY,
  timestamp TIMESTAMPTZ NOT NULL,
  event_type TEXT NOT NULL,
  user_id TEXT NOT NULL,
  session_id TEXT,
  resource_type TEXT NOT NULL,
  resource_id TEXT,
  ip_address INET NOT NULL,
  user_agent TEXT,
  device_id TEXT,
  geo_location TEXT,
  description TEXT,
  metadata JSONB,
  changes JSONB,
  result TEXT NOT NULL,
  error_message TEXT,
  
  -- Auto timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_audit_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_event_type ON audit_logs(event_type);
CREATE INDEX idx_audit_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_result ON audit_logs(result);
CREATE INDEX idx_audit_ip ON audit_logs(ip_address);

-- Composite index for user activity queries
CREATE INDEX idx_audit_user_time ON audit_logs(user_id, timestamp DESC);

-- Index for security event queries
CREATE INDEX idx_audit_security ON audit_logs(event_type) 
  WHERE event_type LIKE 'security.%' OR event_type LIKE 'auth.%failed';

-- Partitioning by month for performance (optional but recommended)
CREATE TABLE audit_logs_2024_01 PARTITION OF audit_logs
  FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE audit_logs_2024_02 PARTITION OF audit_logs
  FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- Continue for each month...

-- RLS Policies
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Users can view their own audit logs
CREATE POLICY audit_user_read ON audit_logs
  FOR SELECT
  USING (user_id = auth.uid()::text);

-- Admins can view all audit logs
CREATE POLICY audit_admin_read ON audit_logs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE user_roles.user_id = auth.uid() 
      AND user_roles.role IN ('admin', 'super_admin', 'auditor')
    )
  );

-- Only system can insert (via service role key)
CREATE POLICY audit_system_insert ON audit_logs
  FOR INSERT
  WITH CHECK (true);

-- Prevent deletion of audit logs
CREATE POLICY audit_no_delete ON audit_logs
  FOR DELETE
  USING (false);

-- Prevent updates to audit logs (immutability)
CREATE POLICY audit_no_update ON audit_logs
  FOR UPDATE
  USING (false);
```

---

## 5. Data Retention Implementation

### 5.1 Retention Enforcement Service

```dart
class RetentionEnforcementService {
  final SupabaseClient _supabase;
  final AuditLogService _auditLog;
  
  RetentionEnforcementService(this._supabase, this._auditLog);
  
  // Run retention cleanup (scheduled job)
  Future<RetentionResult> enforceRetention() async {
    final results = RetentionResult();
    
    // Archive old tax returns (move to archive, don't delete)
    results.taxReturnsArchived = await _archiveOldReturns();
    
    // Delete old session logs
    results.sessionLogsDeleted = await _deleteExpiredRecords(
      'session_logs',
      RetentionPolicy.sessionLogRetention,
    );
    
    // Archive old audit logs (keep summary, remove detail)
    results.auditLogsArchived = await _archiveOldAuditLogs();
    
    // Log retention action
    await _auditLog.log(
      eventType: 'system.retention_enforced',
      resourceType: 'system',
      metadata: results.toJson(),
    );
    
    return results;
  }
  
  Future<int> _archiveOldReturns() async {
    final cutoff = DateTime.now().subtract(RetentionPolicy.taxReturnRetention);
    
    // Move to archive table
    final toArchive = await _supabase
        .from('tax_returns')
        .select('id')
        .lt('filed_at', cutoff.toIso8601String())
        .eq('archived', false);
    
    int count = 0;
    for (final record in toArchive) {
      await _archiveReturn(record['id']);
      count++;
    }
    
    return count;
  }
  
  Future<void> _archiveReturn(String returnId) async {
    // 1. Copy to archive table
    await _supabase.rpc('archive_tax_return', params: {'return_id': returnId});
    
    // 2. Mark as archived in main table
    await _supabase
        .from('tax_returns')
        .update({'archived': true, 'archived_at': DateTime.now().toIso8601String()})
        .eq('id', returnId);
    
    // 3. Delete associated sensitive data
    await _supabase.from('taxpayer_ssn').delete().eq('return_id', returnId);
    await _supabase.from('bank_accounts').delete().eq('return_id', returnId);
  }
  
  Future<int> _deleteExpiredRecords(String table, Duration retention) async {
    final cutoff = DateTime.now().subtract(retention);
    
    final result = await _supabase
        .from(table)
        .delete()
        .lt('created_at', cutoff.toIso8601String());
    
    return result.count ?? 0;
  }
  
  Future<int> _archiveOldAuditLogs() async {
    final cutoff = DateTime.now().subtract(RetentionPolicy.auditLogRetention);
    
    // Summarize and archive old logs
    // Keep event counts but remove detailed metadata
    final result = await _supabase.rpc(
      'archive_audit_logs',
      params: {'cutoff_date': cutoff.toIso8601String()},
    );
    
    return result['archived_count'] ?? 0;
  }
}

class RetentionResult {
  int taxReturnsArchived = 0;
  int sessionLogsDeleted = 0;
  int auditLogsArchived = 0;
  
  Map<String, dynamic> toJson() => {
    'tax_returns_archived': taxReturnsArchived,
    'session_logs_deleted': sessionLogsDeleted,
    'audit_logs_archived': auditLogsArchived,
  };
}
```

---

## 6. Audit Trail UI Components

### 6.1 Activity Log Viewer

```dart
class AuditLogViewerWidget extends StatefulWidget {
  final String? userId;
  final String? returnId;
  
  const AuditLogViewerWidget({
    this.userId,
    this.returnId,
  });
  
  @override
  State<AuditLogViewerWidget> createState() => _AuditLogViewerWidgetState();
}

class _AuditLogViewerWidgetState extends State<AuditLogViewerWidget> {
  final _queryService = Get.find<AuditQueryService>();
  List<AuditEvent> _events = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }
  
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    
    try {
      if (widget.returnId != null) {
        _events = await _queryService.getReturnActivity(widget.returnId!);
      } else if (widget.userId != null) {
        _events = await _queryService.getUserActivity(widget.userId!);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_events.isEmpty) {
      return const Center(child: Text('No activity recorded'));
    }
    
    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _AuditEventTile(event: event);
      },
    );
  }
}

class _AuditEventTile extends StatelessWidget {
  final AuditEvent event;
  
  const _AuditEventTile({required this.event});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildIcon(),
      title: Text(_formatEventType(event.eventType)),
      subtitle: Text(
        '${_formatTimestamp(event.timestamp)} • ${event.ipAddress}',
      ),
      trailing: _buildResultBadge(),
      onTap: () => _showDetails(context),
    );
  }
  
  Widget _buildIcon() {
    final iconData = _getEventIcon(event.eventType);
    final color = _getEventColor(event.result);
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }
  
  Widget _buildResultBadge() {
    final color = _getEventColor(event.result);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        event.result.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  IconData _getEventIcon(String eventType) {
    if (eventType.startsWith('auth.')) return Icons.login;
    if (eventType.startsWith('return.')) return Icons.description;
    if (eventType.startsWith('sensitive.')) return Icons.security;
    if (eventType.startsWith('document.')) return Icons.attach_file;
    if (eventType.startsWith('efile.')) return Icons.send;
    return Icons.history;
  }
  
  Color _getEventColor(AuditResult result) {
    return switch (result) {
      AuditResult.success => Colors.green,
      AuditResult.failure => Colors.orange,
      AuditResult.denied => Colors.red,
      AuditResult.error => Colors.red,
    };
  }
  
  String _formatEventType(String type) {
    return type.replaceAll('.', ' ').replaceAll('_', ' ').toTitleCase();
  }
  
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, yyyy h:mm a').format(timestamp.toLocal());
  }
  
  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AuditEventDetailSheet(event: event),
    );
  }
}
```

---

## 7. Implementation Checklist

- [ ] Create AuditEvent model
- [ ] Implement AuditLogService
- [ ] Create audit_logs database table
- [ ] Set up RLS policies
- [ ] Implement AuditQueryService
- [ ] Create RetentionEnforcementService
- [ ] Build audit log viewer UI
- [ ] Add audit logging to all sensitive operations
- [ ] Create compliance report generator
- [ ] Set up scheduled retention job
- [ ] Test audit trail completeness
- [ ] Document audit log access procedures

---

## 8. Related Documents

- [Security Compliance](./security_compliance.md)
- [Identity Verification](./identity_verification.md)
- [Signature & Consent](./signature_consent.md)
- [E-File Transmission](./efile_transmission.md)
