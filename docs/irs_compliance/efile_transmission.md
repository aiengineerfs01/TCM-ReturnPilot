# E-File Transmission & MeF Integration

## Overview

This document details the IRS Modernized e-File (MeF) system integration requirements, XML generation, transmission protocols, acknowledgment processing, and error handling for electronic tax return filing.

---

## 1. MeF System Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                      TCM Return Pilot App                       │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Backend API Server                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │  XML Generator  │  │  Transmission   │  │  Ack Processor │  │
│  │                 │  │    Service      │  │                │  │
│  └────────┬────────┘  └────────┬────────┘  └───────┬────────┘  │
│           │                    │                   │            │
│  ┌────────▼────────────────────▼───────────────────▼────────┐  │
│  │                    Message Queue                          │  │
│  │              (Submission Processing)                      │  │
│  └────────────────────────┬─────────────────────────────────┘  │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                  IRS MeF System                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │  A2A Gateway    │  │  Return         │  │  Ack Service   │  │
│  │  (SOAP/MTOM)    │  │  Processing     │  │                │  │
│  └─────────────────┘  └─────────────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Transmission Flow

```dart
enum TransmissionState {
  draft,           // Return being prepared
  validated,       // Passed all validations
  queued,          // In submission queue
  transmitting,    // Being sent to IRS
  pending,         // Awaiting acknowledgment
  accepted,        // IRS accepted
  rejected,        // IRS rejected
  error,           // Transmission error
}

class TransmissionFlow {
  /*
   * Flow:
   * 1. User completes return → draft
   * 2. Run validations → validated
   * 3. User signs & submits → queued
   * 4. Backend picks up → transmitting
   * 5. Sent to IRS → pending
   * 6. Poll for ack → accepted/rejected
   */
  
  static const maxTransmissionAttempts = 3;
  static const ackPollInterval = Duration(minutes: 5);
  static const ackPollTimeout = Duration(hours: 48);
}
```

---

## 2. XML Schema Compliance

### 2.1 IRS Schema Structure

```dart
class IRSSchemaVersion {
  static const taxYear2024 = '2024v5.0';
  static const taxYear2023 = '2023v5.0';
  
  // Schema namespaces
  static const efile = 'http://www.irs.gov/efile';
  static const common = 'http://www.irs.gov/efile/common';
  static const individual = 'http://www.irs.gov/efile/individual';
}

// Form 1040 XML Structure
class Form1040XMLStructure {
  static const structure = '''
<?xml version="1.0" encoding="UTF-8"?>
<Return xmlns="http://www.irs.gov/efile" returnVersion="2024v5.0">
  <ReturnHeader binaryAttachmentCnt="0">
    <ReturnTs>2024-01-15T10:30:00-05:00</ReturnTs>
    <TaxYr>2024</TaxYr>
    <TaxPeriodBeginDt>2024-01-01</TaxPeriodBeginDt>
    <TaxPeriodEndDt>2024-12-31</TaxPeriodEndDt>
    <SoftwareId>XXXXXXXXX</SoftwareId>
    <SoftwareVersionNum>1.0</SoftwareVersionNum>
    <OriginatorGrp>
      <EFIN>123456</EFIN>
      <OriginatorTypeCd>OnlineFiler</OriginatorTypeCd>
    </OriginatorGrp>
    <Filer>
      <PrimarySSN>123456789</PrimarySSN>
      <NameLine1Txt>JOHN DOE</NameLine1Txt>
      <PrimaryNameControlTxt>DOE</PrimaryNameControlTxt>
      <USAddress>
        <AddressLine1Txt>123 MAIN ST</AddressLine1Txt>
        <CityNm>ANYTOWN</CityNm>
        <StateAbbreviationCd>CA</StateAbbreviationCd>
        <ZIPCd>90210</ZIPCd>
      </USAddress>
    </Filer>
    <IPAddress>192.168.1.1</IPAddress>
    <IPDt>2024-01-15</IPDt>
    <IPTm>10:30:00</IPTm>
    <DeviceId>DeviceID12345</DeviceId>
  </ReturnHeader>
  
  <ReturnData documentCnt="1">
    <IRS1040 documentId="IRS1040" documentName="IRS1040">
      <!-- Form 1040 content -->
    </IRS1040>
  </ReturnData>
</Return>
''';
}
```

### 2.2 XML Generator Service

```dart
import 'package:xml/xml.dart';

class XMLGeneratorService {
  final TaxReturn taxReturn;
  
  XMLGeneratorService(this.taxReturn);
  
  String generateReturnXML() {
    final builder = XmlBuilder();
    
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    
    builder.element('Return', nest: () {
      builder.attribute('xmlns', IRSSchemaVersion.efile);
      builder.attribute('returnVersion', IRSSchemaVersion.taxYear2024);
      
      // Return Header
      _buildReturnHeader(builder);
      
      // Return Data
      _buildReturnData(builder);
    });
    
    return builder.buildDocument().toXmlString(pretty: true);
  }
  
  void _buildReturnHeader(XmlBuilder builder) {
    builder.element('ReturnHeader', nest: () {
      builder.attribute('binaryAttachmentCnt', 
          taxReturn.attachments.length.toString());
      
      // Timestamp
      builder.element('ReturnTs', nest: DateTime.now().toIso8601String());
      
      // Tax Year
      builder.element('TaxYr', nest: taxReturn.taxYear.toString());
      builder.element('TaxPeriodBeginDt', nest: '${taxReturn.taxYear}-01-01');
      builder.element('TaxPeriodEndDt', nest: '${taxReturn.taxYear}-12-31');
      
      // Software Info
      builder.element('SoftwareId', nest: AppConfig.softwareId);
      builder.element('SoftwareVersionNum', nest: AppConfig.version);
      
      // Originator
      _buildOriginatorGroup(builder);
      
      // Filer
      _buildFilerInfo(builder);
      
      // IP/Device Info
      _buildDeviceInfo(builder);
    });
  }
  
  void _buildOriginatorGroup(XmlBuilder builder) {
    builder.element('OriginatorGrp', nest: () {
      builder.element('EFIN', nest: AppConfig.efin);
      builder.element('OriginatorTypeCd', nest: 'OnlineFiler');
    });
  }
  
  void _buildFilerInfo(XmlBuilder builder) {
    final taxpayer = taxReturn.taxpayer;
    
    builder.element('Filer', nest: () {
      builder.element('PrimarySSN', nest: taxpayer.ssnDecrypted);
      builder.element('NameLine1Txt', 
          nest: '${taxpayer.firstName} ${taxpayer.lastName}'.toUpperCase());
      builder.element('PrimaryNameControlTxt', 
          nest: _getNameControl(taxpayer.lastName));
      
      if (taxpayer.spouseSSN != null) {
        builder.element('SpouseSSN', nest: taxpayer.spouse!.ssnDecrypted);
        builder.element('SpouseNameLine1Txt',
            nest: '${taxpayer.spouse!.firstName} ${taxpayer.spouse!.lastName}'.toUpperCase());
        builder.element('SpouseNameControlTxt',
            nest: _getNameControl(taxpayer.spouse!.lastName));
      }
      
      _buildAddress(builder, taxpayer.address);
    });
  }
  
  void _buildAddress(XmlBuilder builder, Address address) {
    if (address.isForeign) {
      builder.element('ForeignAddress', nest: () {
        builder.element('AddressLine1Txt', nest: address.line1.toUpperCase());
        if (address.line2 != null) {
          builder.element('AddressLine2Txt', nest: address.line2!.toUpperCase());
        }
        builder.element('CityNm', nest: address.city.toUpperCase());
        builder.element('ProvinceOrStateNm', nest: address.stateProvince);
        builder.element('CountryCd', nest: address.countryCode);
        builder.element('ForeignPostalCd', nest: address.postalCode);
      });
    } else {
      builder.element('USAddress', nest: () {
        builder.element('AddressLine1Txt', nest: address.line1.toUpperCase());
        if (address.line2 != null) {
          builder.element('AddressLine2Txt', nest: address.line2!.toUpperCase());
        }
        builder.element('CityNm', nest: address.city.toUpperCase());
        builder.element('StateAbbreviationCd', nest: address.state);
        builder.element('ZIPCd', nest: address.zipCode);
      });
    }
  }
  
  void _buildDeviceInfo(XmlBuilder builder) {
    builder.element('IPAddress', nest: taxReturn.submissionInfo.ipAddress);
    builder.element('IPDt', nest: taxReturn.submissionInfo.ipDate);
    builder.element('IPTm', nest: taxReturn.submissionInfo.ipTime);
    builder.element('DeviceId', nest: taxReturn.submissionInfo.deviceId);
  }
  
  void _buildReturnData(XmlBuilder builder) {
    builder.element('ReturnData', nest: () {
      builder.attribute('documentCnt', _getDocumentCount().toString());
      
      // Main Form 1040
      _buildForm1040(builder);
      
      // Schedules
      if (taxReturn.hasSchedule1) _buildSchedule1(builder);
      if (taxReturn.hasSchedule2) _buildSchedule2(builder);
      if (taxReturn.hasSchedule3) _buildSchedule3(builder);
      if (taxReturn.hasScheduleA) _buildScheduleA(builder);
      if (taxReturn.hasScheduleB) _buildScheduleB(builder);
      if (taxReturn.hasScheduleC) _buildScheduleC(builder);
      if (taxReturn.hasScheduleD) _buildScheduleD(builder);
      if (taxReturn.hasScheduleE) _buildScheduleE(builder);
      
      // Supporting Forms
      for (final w2 in taxReturn.w2Forms) {
        _buildW2(builder, w2);
      }
      
      for (final form1099 in taxReturn.forms1099) {
        _buildForm1099(builder, form1099);
      }
    });
  }
  
  void _buildForm1040(XmlBuilder builder) {
    final calc = taxReturn.calculations;
    
    builder.element('IRS1040', nest: () {
      builder.attribute('documentId', 'IRS1040');
      builder.attribute('documentName', 'IRS1040');
      
      // Filing Status
      builder.element('IndividualReturnFilingStatusCd', 
          nest: taxReturn.filingStatus.code);
      
      // Virtual Currency Question (Required)
      builder.element('VirtualCurAcquiredDurTYInd', 
          nest: taxReturn.hasVirtualCurrency ? 'X' : '');
      
      // Name and SSN (if not in header)
      builder.element('NameLine1Txt', 
          nest: taxReturn.taxpayer.fullName.toUpperCase());
      
      // Dependents
      if (taxReturn.dependents.isNotEmpty) {
        for (final dep in taxReturn.dependents) {
          _buildDependentLine(builder, dep);
        }
      }
      
      // Income Section
      builder.element('WagesAmt', nest: calc.totalWages.toStringAsFixed(0));
      builder.element('TaxExemptInterestAmt', 
          nest: calc.taxExemptInterest.toStringAsFixed(0));
      builder.element('TaxableInterestAmt', 
          nest: calc.taxableInterest.toStringAsFixed(0));
      builder.element('QualifiedDividendsAmt',
          nest: calc.qualifiedDividends.toStringAsFixed(0));
      builder.element('OrdinaryDividendsAmt',
          nest: calc.ordinaryDividends.toStringAsFixed(0));
      
      // ... additional income lines
      
      builder.element('TotalIncomeAmt', 
          nest: calc.totalIncome.toStringAsFixed(0));
      builder.element('AdjustedGrossIncomeAmt',
          nest: calc.agi.toStringAsFixed(0));
      
      // Deductions
      if (taxReturn.itemizedDeductions) {
        builder.element('ItemizedDeductionsAmt',
            nest: calc.itemizedDeductions.toStringAsFixed(0));
      } else {
        builder.element('StandardDeductionAmt',
            nest: calc.standardDeduction.toStringAsFixed(0));
      }
      
      builder.element('TaxableIncomeAmt',
          nest: calc.taxableIncome.toStringAsFixed(0));
      
      // Tax Computation
      builder.element('TaxAmt', nest: calc.taxBeforeCredits.toStringAsFixed(0));
      
      // Credits
      builder.element('ChildTaxCreditAmt',
          nest: calc.childTaxCredit.toStringAsFixed(0));
      
      // Payments
      builder.element('WithholdingTaxAmt',
          nest: calc.totalWithholding.toStringAsFixed(0));
      
      // Refund or Amount Owed
      if (calc.refundAmount > 0) {
        builder.element('RefundAmt', 
            nest: calc.refundAmount.toStringAsFixed(0));
        _buildRefundInfo(builder);
      } else if (calc.amountOwed > 0) {
        builder.element('OwedAmt',
            nest: calc.amountOwed.toStringAsFixed(0));
      }
      
      // Signature
      _buildSignatureSection(builder);
    });
  }
  
  void _buildRefundInfo(XmlBuilder builder) {
    final refund = taxReturn.refundPreferences;
    
    builder.element('RoutingTransitNum', 
        nest: refund.routingNumber);
    builder.element('BankAccountTypeCd',
        nest: refund.accountType == BankAccountType.checking ? '1' : '2');
    builder.element('DepositorAccountNum',
        nest: refund.accountNumber);
    builder.element('RefundProductCd', 
        nest: refund.directDeposit ? 'NO FINANCIAL PRODUCT' : '');
  }
  
  void _buildSignatureSection(XmlBuilder builder) {
    final sig = taxReturn.signature;
    
    builder.element('PrimarySignaturePIN', nest: sig.primaryPIN);
    builder.element('PrimarySignatureDt', nest: sig.signatureDate);
    
    if (sig.hasSpouseSignature) {
      builder.element('SpouseSignaturePIN', nest: sig.spousePIN);
      builder.element('SpouseSignatureDt', nest: sig.spouseSignatureDate);
    }
    
    // ERO signature if applicable
    if (taxReturn.hasPreparer) {
      builder.element('PaidPreparerInformationGrp', nest: () {
        builder.element('PreparerPersonNm', nest: sig.preparerName);
        builder.element('PTIN', nest: sig.preparerPTIN);
        builder.element('PreparerFirmEIN', nest: sig.firmEIN);
        builder.element('PreparerFirmName', nest: sig.firmName);
      });
    }
  }
  
  // Name control: First 4 characters of last name
  String _getNameControl(String lastName) {
    final cleaned = lastName.replaceAll(RegExp(r'[^A-Za-z]'), '');
    return cleaned.substring(0, min(4, cleaned.length)).toUpperCase();
  }
}
```

---

## 3. XML Validation

### 3.1 Schema Validator

```dart
class XMLValidator {
  // Validate against IRS schemas
  Future<ValidationResult> validate(String xml) async {
    final results = <ValidationError>[];
    
    // 1. Well-formed XML check
    try {
      XmlDocument.parse(xml);
    } catch (e) {
      return ValidationResult.failed([
        ValidationError(
          code: 'XML-001',
          message: 'Malformed XML: $e',
          severity: ErrorSeverity.fatal,
        ),
      ]);
    }
    
    // 2. Schema validation
    final schemaErrors = await _validateAgainstSchema(xml);
    results.addAll(schemaErrors);
    
    // 3. Business rule validation
    final businessErrors = await _validateBusinessRules(xml);
    results.addAll(businessErrors);
    
    return ValidationResult(
      isValid: results.every((e) => e.severity != ErrorSeverity.fatal),
      errors: results,
    );
  }
  
  Future<List<ValidationError>> _validateAgainstSchema(String xml) async {
    final errors = <ValidationError>[];
    
    // Validate required elements
    final doc = XmlDocument.parse(xml);
    
    // Check required header elements
    final requiredElements = [
      'ReturnTs',
      'TaxYr',
      'SoftwareId',
      'EFIN',
      'PrimarySSN',
    ];
    
    for (final element in requiredElements) {
      if (doc.findAllElements(element).isEmpty) {
        errors.add(ValidationError(
          code: 'SCHEMA-001',
          message: 'Required element missing: $element',
          severity: ErrorSeverity.fatal,
        ));
      }
    }
    
    return errors;
  }
  
  Future<List<ValidationError>> _validateBusinessRules(String xml) async {
    final errors = <ValidationError>[];
    final doc = XmlDocument.parse(xml);
    
    // Rule: SSN format (9 digits)
    final ssn = doc.findAllElements('PrimarySSN').firstOrNull?.innerText;
    if (ssn != null && !RegExp(r'^\d{9}$').hasMatch(ssn)) {
      errors.add(ValidationError(
        code: 'RULE-001',
        message: 'Invalid SSN format',
        severity: ErrorSeverity.fatal,
      ));
    }
    
    // Rule: Tax year matches current filing season
    final taxYear = doc.findAllElements('TaxYr').firstOrNull?.innerText;
    if (taxYear != null && taxYear != '2024') {
      errors.add(ValidationError(
        code: 'RULE-002',
        message: 'Tax year does not match current filing season',
        severity: ErrorSeverity.warning,
      ));
    }
    
    // Rule: Wages match W-2 total
    // Rule: Filing status valid for dependents claimed
    // ... additional rules
    
    return errors;
  }
}

class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  
  ValidationResult({required this.isValid, required this.errors});
  
  factory ValidationResult.failed(List<ValidationError> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }
}

class ValidationError {
  final String code;
  final String message;
  final ErrorSeverity severity;
  final String? element;
  
  ValidationError({
    required this.code,
    required this.message,
    required this.severity,
    this.element,
  });
}

enum ErrorSeverity { info, warning, error, fatal }
```

---

## 4. Transmission Service

### 4.1 MeF Transmission Client

```dart
class MeFTransmissionService {
  final String _mefEndpoint;
  final String _efin;
  final String _etin;
  
  MeFTransmissionService({
    required String efin,
    required String etin,
    bool isProduction = false,
  }) : _efin = efin,
       _etin = etin,
       _mefEndpoint = isProduction
           ? 'https://la.www4.irs.gov/a2a/mef'
           : 'https://la.tst.www4.irs.gov/a2a/mef';
  
  // Submit return to IRS
  Future<SubmissionResult> submitReturn(String returnXml) async {
    try {
      // 1. Create SOAP envelope
      final soapEnvelope = _createSOAPEnvelope(returnXml);
      
      // 2. Sign the submission
      final signedEnvelope = await _signSubmission(soapEnvelope);
      
      // 3. Transmit via MTOM
      final response = await _transmit(signedEnvelope);
      
      // 4. Parse response
      return _parseSubmissionResponse(response);
    } catch (e) {
      return SubmissionResult.error(e.toString());
    }
  }
  
  String _createSOAPEnvelope(String returnXml) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope 
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
    xmlns:mef="http://www.irs.gov/a2a/mef">
  <soap:Header>
    <mef:TransmitterHeader>
      <mef:ETIN>$_etin</mef:ETIN>
      <mef:Timestamp>${DateTime.now().toIso8601String()}</mef:Timestamp>
    </mef:TransmitterHeader>
  </soap:Header>
  <soap:Body>
    <mef:TransmitRequest>
      <mef:Submission>
        ${base64Encode(utf8.encode(returnXml))}
      </mef:Submission>
    </mef:TransmitRequest>
  </soap:Body>
</soap:Envelope>
''';
  }
  
  Future<String> _signSubmission(String envelope) async {
    // XML Digital Signature (XML-DSig)
    // Uses certificate issued by IRS
    // Implementation depends on crypto library
    return envelope; // Placeholder
  }
  
  Future<http.Response> _transmit(String signedEnvelope) async {
    final response = await http.post(
      Uri.parse(_mefEndpoint),
      headers: {
        'Content-Type': 'application/xop+xml; charset=UTF-8; type="application/soap+xml"',
        'SOAPAction': '"TransmitReturn"',
      },
      body: signedEnvelope,
    );
    
    return response;
  }
  
  SubmissionResult _parseSubmissionResponse(http.Response response) {
    if (response.statusCode == 200) {
      final doc = XmlDocument.parse(response.body);
      final submissionId = doc.findAllElements('SubmissionId').firstOrNull?.innerText;
      
      return SubmissionResult.success(
        submissionId: submissionId!,
        timestamp: DateTime.now(),
      );
    } else {
      return SubmissionResult.error('HTTP ${response.statusCode}: ${response.body}');
    }
  }
  
  // Poll for acknowledgment
  Future<AcknowledgmentResult> getAcknowledgment(String submissionId) async {
    final response = await http.post(
      Uri.parse('$_mefEndpoint/GetAck'),
      headers: {
        'Content-Type': 'application/soap+xml; charset=UTF-8',
        'SOAPAction': '"GetAcknowledgment"',
      },
      body: _createAckRequest(submissionId),
    );
    
    return _parseAckResponse(response);
  }
  
  String _createAckRequest(String submissionId) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Header>
    <mef:TransmitterHeader xmlns:mef="http://www.irs.gov/a2a/mef">
      <mef:ETIN>$_etin</mef:ETIN>
    </mef:TransmitterHeader>
  </soap:Header>
  <soap:Body>
    <mef:GetAckRequest xmlns:mef="http://www.irs.gov/a2a/mef">
      <mef:SubmissionId>$submissionId</mef:SubmissionId>
    </mef:GetAckRequest>
  </soap:Body>
</soap:Envelope>
''';
  }
  
  AcknowledgmentResult _parseAckResponse(http.Response response) {
    final doc = XmlDocument.parse(response.body);
    
    final status = doc.findAllElements('AcceptanceStatusTxt').firstOrNull?.innerText;
    
    if (status == 'A') {
      return AcknowledgmentResult.accepted(
        submissionId: doc.findAllElements('SubmissionId').first.innerText,
        acceptanceDate: DateTime.parse(
          doc.findAllElements('AcceptanceStatusDt').first.innerText,
        ),
      );
    } else if (status == 'R') {
      final errors = doc.findAllElements('ErrorMessageTxt')
          .map((e) => e.innerText)
          .toList();
      
      return AcknowledgmentResult.rejected(
        submissionId: doc.findAllElements('SubmissionId').first.innerText,
        errors: errors,
      );
    } else {
      return AcknowledgmentResult.pending();
    }
  }
}
```

### 4.2 Submission Models

```dart
class SubmissionResult {
  final bool success;
  final String? submissionId;
  final DateTime? timestamp;
  final String? error;
  
  SubmissionResult._({
    required this.success,
    this.submissionId,
    this.timestamp,
    this.error,
  });
  
  factory SubmissionResult.success({
    required String submissionId,
    required DateTime timestamp,
  }) => SubmissionResult._(
    success: true,
    submissionId: submissionId,
    timestamp: timestamp,
  );
  
  factory SubmissionResult.error(String error) => SubmissionResult._(
    success: false,
    error: error,
  );
}

class AcknowledgmentResult {
  final AcknowledgmentStatus status;
  final String? submissionId;
  final DateTime? acceptanceDate;
  final List<String>? errors;
  final List<IrsError>? rejectionCodes;
  
  AcknowledgmentResult._({
    required this.status,
    this.submissionId,
    this.acceptanceDate,
    this.errors,
    this.rejectionCodes,
  });
  
  factory AcknowledgmentResult.accepted({
    required String submissionId,
    required DateTime acceptanceDate,
  }) => AcknowledgmentResult._(
    status: AcknowledgmentStatus.accepted,
    submissionId: submissionId,
    acceptanceDate: acceptanceDate,
  );
  
  factory AcknowledgmentResult.rejected({
    required String submissionId,
    required List<String> errors,
    List<IrsError>? rejectionCodes,
  }) => AcknowledgmentResult._(
    status: AcknowledgmentStatus.rejected,
    submissionId: submissionId,
    errors: errors,
    rejectionCodes: rejectionCodes,
  );
  
  factory AcknowledgmentResult.pending() => AcknowledgmentResult._(
    status: AcknowledgmentStatus.pending,
  );
}

enum AcknowledgmentStatus { pending, accepted, rejected }
```

---

## 5. Submission Queue Management

### 5.1 Queue Service

```dart
class SubmissionQueueService {
  final SupabaseClient _supabase;
  final MeFTransmissionService _mef;
  final AuditLogService _auditLog;
  
  // Add return to submission queue
  Future<void> queueSubmission(TaxReturn taxReturn) async {
    await _supabase.from('submission_queue').insert({
      'return_id': taxReturn.id,
      'user_id': taxReturn.userId,
      'status': 'queued',
      'priority': _calculatePriority(taxReturn),
      'xml_content': taxReturn.generatedXml,
      'queued_at': DateTime.now().toIso8601String(),
    });
    
    await _auditLog.logAction(
      action: AuditActions.returnSubmitted,
      resourceType: 'tax_return',
      resourceId: taxReturn.id,
    );
  }
  
  // Process submission queue (called by background job)
  Future<void> processQueue() async {
    final queuedItems = await _supabase
        .from('submission_queue')
        .select()
        .eq('status', 'queued')
        .order('priority', ascending: false)
        .order('queued_at')
        .limit(10);
    
    for (final item in queuedItems) {
      await _processSubmission(item);
    }
  }
  
  Future<void> _processSubmission(Map<String, dynamic> item) async {
    final id = item['id'];
    
    try {
      // Update status
      await _updateStatus(id, 'transmitting');
      
      // Submit to IRS
      final result = await _mef.submitReturn(item['xml_content']);
      
      if (result.success) {
        await _updateStatus(id, 'pending', {
          'submission_id': result.submissionId,
          'transmitted_at': DateTime.now().toIso8601String(),
        });
        
        // Start polling for acknowledgment
        await _scheduleAckPolling(id, result.submissionId!);
      } else {
        await _handleTransmissionError(id, result.error!);
      }
    } catch (e) {
      await _handleTransmissionError(id, e.toString());
    }
  }
  
  Future<void> _scheduleAckPolling(String queueId, String submissionId) async {
    // Add to ack polling queue
    await _supabase.from('ack_polling_queue').insert({
      'queue_id': queueId,
      'submission_id': submissionId,
      'next_poll_at': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
      'poll_count': 0,
    });
  }
  
  // Process acknowledgment polling
  Future<void> processAckPolling() async {
    final items = await _supabase
        .from('ack_polling_queue')
        .select()
        .lte('next_poll_at', DateTime.now().toIso8601String())
        .limit(20);
    
    for (final item in items) {
      await _pollForAck(item);
    }
  }
  
  Future<void> _pollForAck(Map<String, dynamic> item) async {
    final submissionId = item['submission_id'];
    final pollCount = item['poll_count'] as int;
    
    // Check timeout (48 hours)
    if (pollCount > 576) { // 48 hours at 5-min intervals
      await _handleAckTimeout(item);
      return;
    }
    
    final result = await _mef.getAcknowledgment(submissionId);
    
    switch (result.status) {
      case AcknowledgmentStatus.accepted:
        await _handleAccepted(item, result);
        break;
      case AcknowledgmentStatus.rejected:
        await _handleRejected(item, result);
        break;
      case AcknowledgmentStatus.pending:
        // Schedule next poll
        await _supabase.from('ack_polling_queue')
            .update({
              'next_poll_at': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
              'poll_count': pollCount + 1,
            })
            .eq('id', item['id']);
        break;
    }
  }
  
  Future<void> _handleAccepted(
    Map<String, dynamic> item, 
    AcknowledgmentResult result,
  ) async {
    // Update queue status
    await _updateStatus(item['queue_id'], 'accepted', {
      'accepted_at': result.acceptanceDate?.toIso8601String(),
    });
    
    // Update tax return status
    await _supabase.from('tax_returns')
        .update({'status': 'accepted'})
        .eq('id', item['return_id']);
    
    // Remove from polling queue
    await _supabase.from('ack_polling_queue')
        .delete()
        .eq('id', item['id']);
    
    // Send notification to user
    await _notifyUser(item['user_id'], 'accepted');
    
    // Log audit event
    await _auditLog.logAction(
      action: AuditActions.efileAccepted,
      resourceType: 'tax_return',
      resourceId: item['return_id'],
    );
  }
  
  Future<void> _handleRejected(
    Map<String, dynamic> item,
    AcknowledgmentResult result,
  ) async {
    await _updateStatus(item['queue_id'], 'rejected', {
      'rejection_errors': result.errors,
      'rejected_at': DateTime.now().toIso8601String(),
    });
    
    await _supabase.from('tax_returns')
        .update({
          'status': 'rejected',
          'rejection_errors': result.errors,
        })
        .eq('id', item['return_id']);
    
    await _supabase.from('ack_polling_queue')
        .delete()
        .eq('id', item['id']);
    
    await _notifyUser(item['user_id'], 'rejected', result.errors);
    
    await _auditLog.logAction(
      action: AuditActions.efileRejected,
      resourceType: 'tax_return',
      resourceId: item['return_id'],
      metadata: {'errors': result.errors},
    );
  }
}
```

---

## 6. Error Handling & Rejection Codes

### 6.1 IRS Error Codes

```dart
class IRSErrorCodes {
  // Common rejection codes
  static const errorDatabase = {
    'R0000-500-01': IRSError(
      code: 'R0000-500-01',
      description: 'SSN has already been used on another return',
      resolution: 'Verify SSN is correct or file paper return',
      userMessage: 'This SSN has already been used to file a return for this tax year.',
    ),
    'R0000-902-01': IRSError(
      code: 'R0000-902-01',
      description: 'Name control does not match IRS records',
      resolution: 'Verify name spelling matches Social Security card',
      userMessage: 'Please verify your name matches exactly as shown on your Social Security card.',
    ),
    'R0000-504-02': IRSError(
      code: 'R0000-504-02',
      description: 'Spouse SSN already used',
      resolution: 'Verify spouse SSN or file MFS',
      userMessage: 'Your spouse\'s SSN has already been used on another return.',
    ),
    'F1040-004-01': IRSError(
      code: 'F1040-004-01',
      description: 'Standard deduction amount incorrect',
      resolution: 'Recalculate based on filing status and age',
      userMessage: 'There\'s an issue with your deduction amount. We\'ll recalculate it.',
    ),
    'F1040-070': IRSError(
      code: 'F1040-070',
      description: 'IP PIN required but not provided',
      resolution: 'Enter Identity Protection PIN',
      userMessage: 'The IRS requires your Identity Protection PIN to file this return.',
    ),
    // Add more error codes...
  };
  
  static IRSError? lookup(String code) => errorDatabase[code];
}

class IRSError {
  final String code;
  final String description;
  final String resolution;
  final String userMessage;
  final bool canAutoFix;
  
  const IRSError({
    required this.code,
    required this.description,
    required this.resolution,
    required this.userMessage,
    this.canAutoFix = false,
  });
}
```

### 6.2 Error Handler

```dart
class EFileErrorHandler {
  // Parse and categorize errors
  static List<CategorizedError> categorizeErrors(List<String> errors) {
    return errors.map((error) {
      // Extract error code
      final codeMatch = RegExp(r'([A-Z]\d{4}-\d{3}(?:-\d{2})?)').firstMatch(error);
      final code = codeMatch?.group(1);
      
      if (code != null) {
        final irsError = IRSErrorCodes.lookup(code);
        if (irsError != null) {
          return CategorizedError(
            category: _categorize(code),
            irsError: irsError,
            rawMessage: error,
          );
        }
      }
      
      return CategorizedError(
        category: ErrorCategory.unknown,
        rawMessage: error,
      );
    }).toList();
  }
  
  static ErrorCategory _categorize(String code) {
    if (code.startsWith('R0000-5')) return ErrorCategory.identity;
    if (code.startsWith('R0000-9')) return ErrorCategory.nameControl;
    if (code.startsWith('F1040')) return ErrorCategory.form1040;
    if (code.startsWith('FPYMT')) return ErrorCategory.payment;
    if (code.startsWith('FBANK')) return ErrorCategory.bankInfo;
    return ErrorCategory.other;
  }
  
  // Attempt automatic fixes
  static Future<AutoFixResult> attemptAutoFix(
    TaxReturn taxReturn,
    CategorizedError error,
  ) async {
    switch (error.category) {
      case ErrorCategory.nameControl:
        // Try reformatting name
        return AutoFixResult(
          fixed: true,
          description: 'Reformatted name to match IRS format',
        );
      case ErrorCategory.form1040:
        // Recalculate values
        return AutoFixResult(
          fixed: true,
          description: 'Recalculated form values',
        );
      default:
        return AutoFixResult(
          fixed: false,
          requiresUserAction: true,
          actionRequired: error.irsError?.resolution,
        );
    }
  }
}

enum ErrorCategory {
  identity,
  nameControl,
  form1040,
  payment,
  bankInfo,
  other,
  unknown,
}

class CategorizedError {
  final ErrorCategory category;
  final IRSError? irsError;
  final String rawMessage;
  
  CategorizedError({
    required this.category,
    this.irsError,
    required this.rawMessage,
  });
  
  String get userFriendlyMessage => 
      irsError?.userMessage ?? 'An error occurred. Please review and try again.';
}

class AutoFixResult {
  final bool fixed;
  final String? description;
  final bool requiresUserAction;
  final String? actionRequired;
  
  AutoFixResult({
    required this.fixed,
    this.description,
    this.requiresUserAction = false,
    this.actionRequired,
  });
}
```

---

## 7. Database Schema

```sql
-- Submission Queue
CREATE TABLE submission_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  status TEXT NOT NULL DEFAULT 'queued',
  priority INTEGER DEFAULT 0,
  xml_content TEXT NOT NULL,
  submission_id TEXT,
  queued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  transmitted_at TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ,
  rejected_at TIMESTAMPTZ,
  rejection_errors JSONB,
  transmission_attempts INTEGER DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_queue_status ON submission_queue(status);
CREATE INDEX idx_queue_user ON submission_queue(user_id);

-- Acknowledgment Polling Queue
CREATE TABLE ack_polling_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  queue_id UUID NOT NULL REFERENCES submission_queue(id),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  submission_id TEXT NOT NULL,
  next_poll_at TIMESTAMPTZ NOT NULL,
  poll_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ack_poll_next ON ack_polling_queue(next_poll_at);
```

---

## 8. Implementation Checklist

### Phase 1: XML Generation
- [ ] Implement XMLGeneratorService
- [ ] Add Form 1040 XML builder
- [ ] Add Schedule builders (A, B, C, etc.)
- [ ] Add W-2 and 1099 XML builders
- [ ] Implement XML validation

### Phase 2: Transmission
- [ ] Set up MeF test environment access
- [ ] Implement SOAP/MTOM client
- [ ] Add XML digital signature
- [ ] Create submission service

### Phase 3: Queue & Polling
- [ ] Create submission queue table
- [ ] Implement queue service
- [ ] Create background job for processing
- [ ] Implement acknowledgment polling

### Phase 4: Error Handling
- [ ] Build IRS error code database
- [ ] Implement error categorization
- [ ] Create auto-fix logic
- [ ] Build user-friendly error messages

---

## 9. Related Documents

- [Tax Forms](./tax_forms.md)
- [Calculations](./calculations.md)
- [Security Compliance](./security_compliance.md)
- [Error Handling](./error_handling.md)
