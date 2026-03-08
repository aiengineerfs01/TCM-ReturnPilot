# API & System Integration Guide

## Overview

This document provides comprehensive guidance for integrating with IRS systems, third-party tax services, and building internal APIs for the tax return application.

---

## 1. IRS MeF API Integration

### 1.1 MeF Connection Overview

```dart
/// IRS Modernized e-File (MeF) System Integration
/// 
/// MeF uses SOAP-based web services with MTOM for attachments
/// All communications must be over TLS 1.2+
/// Requires valid EFIN and software credentials

class MeFAPIConfiguration {
  // IRS Production Endpoints
  static const productionEndpoint = 'https://mef.prod.irs.gov/MeFSASService/MeFSASService';
  static const productionAckEndpoint = 'https://mef.prod.irs.gov/MeFAckService/MeFAckService';
  
  // IRS Test Endpoints (ATS/ATES)
  static const testEndpoint = 'https://la.www4.irs.gov/a2a/MeFSASService/MeFSASService';
  static const testAckEndpoint = 'https://la.www4.irs.gov/a2a/MeFAckService/MeFAckService';
  
  // Required credentials
  final String efin;              // 6-digit EFIN
  final String softwareId;        // IRS-assigned software ID
  final String applicationId;     // IRS-assigned application ID
  final X509Certificate certificate;  // PKI certificate for signing
  
  final bool isProduction;
  
  MeFAPIConfiguration({
    required this.efin,
    required this.softwareId,
    required this.applicationId,
    required this.certificate,
    this.isProduction = false,
  });
  
  String get submissionEndpoint => 
      isProduction ? productionEndpoint : testEndpoint;
  
  String get acknowledgmentEndpoint =>
      isProduction ? productionAckEndpoint : testAckEndpoint;
}
```

### 1.2 MeF Service Client

```dart
class MeFServiceClient {
  final MeFAPIConfiguration _config;
  final http.Client _httpClient;
  final XMLSigningService _xmlSigner;
  
  MeFServiceClient(this._config, this._httpClient, this._xmlSigner);
  
  /// Submit a return to IRS MeF
  Future<MeFSubmissionResponse> submitReturn({
    required String returnXml,
    required String submissionId,
  }) async {
    // 1. Sign the XML
    final signedXml = await _xmlSigner.signXML(
      xml: returnXml,
      certificate: _config.certificate,
    );
    
    // 2. Build SOAP envelope
    final soapRequest = _buildSubmissionSOAP(
      signedXml: signedXml,
      submissionId: submissionId,
    );
    
    // 3. Send request
    final response = await _httpClient.post(
      Uri.parse(_config.submissionEndpoint),
      headers: {
        'Content-Type': 'application/soap+xml; charset=utf-8',
        'SOAPAction': 'SubmitReturn',
      },
      body: soapRequest,
    );
    
    // 4. Parse response
    return _parseSubmissionResponse(response.body);
  }
  
  /// Check acknowledgment status
  Future<MeFAcknowledgment> getAcknowledgment(String submissionId) async {
    final soapRequest = _buildAckRequestSOAP(submissionId);
    
    final response = await _httpClient.post(
      Uri.parse(_config.acknowledgmentEndpoint),
      headers: {
        'Content-Type': 'application/soap+xml; charset=utf-8',
        'SOAPAction': 'GetAcknowledgment',
      },
      body: soapRequest,
    );
    
    return _parseAcknowledgmentResponse(response.body);
  }
  
  String _buildSubmissionSOAP({
    required String signedXml,
    required String submissionId,
  }) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:mef="http://www.irs.gov/efile">
  <soap:Header>
    <mef:TransmitterInfo>
      <mef:EFIN>${_config.efin}</mef:EFIN>
      <mef:SoftwareId>${_config.softwareId}</mef:SoftwareId>
      <mef:ApplicationId>${_config.applicationId}</mef:ApplicationId>
    </mef:TransmitterInfo>
  </soap:Header>
  <soap:Body>
    <mef:SubmitReturn>
      <mef:SubmissionId>$submissionId</mef:SubmissionId>
      <mef:Return>$signedXml</mef:Return>
    </mef:SubmitReturn>
  </soap:Body>
</soap:Envelope>
''';
  }
  
  String _buildAckRequestSOAP(String submissionId) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:mef="http://www.irs.gov/efile">
  <soap:Header>
    <mef:TransmitterInfo>
      <mef:EFIN>${_config.efin}</mef:EFIN>
      <mef:SoftwareId>${_config.softwareId}</mef:SoftwareId>
    </mef:TransmitterInfo>
  </soap:Header>
  <soap:Body>
    <mef:GetAcknowledgment>
      <mef:SubmissionId>$submissionId</mef:SubmissionId>
    </mef:GetAcknowledgment>
  </soap:Body>
</soap:Envelope>
''';
  }
  
  MeFSubmissionResponse _parseSubmissionResponse(String responseXml) {
    final document = xml.XmlDocument.parse(responseXml);
    
    // Extract response data
    final statusCode = document.findAllElements('StatusCode').first.text;
    final statusMessage = document.findAllElements('StatusMessage').firstOrNull?.text;
    
    return MeFSubmissionResponse(
      success: statusCode == '0',
      statusCode: statusCode,
      statusMessage: statusMessage,
    );
  }
  
  MeFAcknowledgment _parseAcknowledgmentResponse(String responseXml) {
    final document = xml.XmlDocument.parse(responseXml);
    
    final status = document.findAllElements('AcceptanceStatus').firstOrNull?.text;
    final errorCode = document.findAllElements('ErrorCode').firstOrNull?.text;
    final errorMessage = document.findAllElements('ErrorMessage').firstOrNull?.text;
    
    return MeFAcknowledgment(
      status: _parseAckStatus(status),
      errorCode: errorCode,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }
  
  AcknowledgmentStatus _parseAckStatus(String? status) {
    return switch (status) {
      'A' => AcknowledgmentStatus.accepted,
      'R' => AcknowledgmentStatus.rejected,
      'P' => AcknowledgmentStatus.pending,
      _ => AcknowledgmentStatus.unknown,
    };
  }
}

class MeFSubmissionResponse {
  final bool success;
  final String statusCode;
  final String? statusMessage;
  
  const MeFSubmissionResponse({
    required this.success,
    required this.statusCode,
    this.statusMessage,
  });
}

class MeFAcknowledgment {
  final AcknowledgmentStatus status;
  final String? errorCode;
  final String? errorMessage;
  final DateTime timestamp;
  
  const MeFAcknowledgment({
    required this.status,
    this.errorCode,
    this.errorMessage,
    required this.timestamp,
  });
}

enum AcknowledgmentStatus {
  accepted,
  rejected,
  pending,
  unknown,
}
```

---

## 2. Internal REST API Design

### 2.1 API Architecture

```dart
/// RESTful API design for tax return management
/// Uses Supabase Edge Functions or separate backend

class APIEndpoints {
  static const baseUrl = '/api/v1';
  
  // Tax Returns
  static const returns = '$baseUrl/returns';
  static const returnById = '$baseUrl/returns/{id}';
  static const returnCalculate = '$baseUrl/returns/{id}/calculate';
  static const returnValidate = '$baseUrl/returns/{id}/validate';
  static const returnSubmit = '$baseUrl/returns/{id}/submit';
  static const returnStatus = '$baseUrl/returns/{id}/status';
  
  // Income Documents
  static const w2s = '$baseUrl/returns/{returnId}/w2s';
  static const form1099s = '$baseUrl/returns/{returnId}/1099s';
  
  // Dependents
  static const dependents = '$baseUrl/returns/{returnId}/dependents';
  
  // User Profile
  static const profile = '$baseUrl/profile';
  static const identityVerify = '$baseUrl/identity/verify';
  
  // Signatures
  static const signatures = '$baseUrl/returns/{returnId}/signatures';
  
  // Refund
  static const refundOptions = '$baseUrl/returns/{returnId}/refund';
  static const refundStatus = '$baseUrl/returns/{returnId}/refund/status';
}
```

### 2.2 API Service Layer

```dart
class TaxReturnAPIService {
  final SupabaseClient _supabase;
  final String _baseUrl;
  
  TaxReturnAPIService(this._supabase, this._baseUrl);
  
  // === Tax Returns ===
  
  Future<TaxReturn> createReturn({
    required int taxYear,
    required FilingStatus filingStatus,
  }) async {
    final response = await _supabase.functions.invoke(
      'create-return',
      body: {
        'tax_year': taxYear,
        'filing_status': filingStatus.name,
      },
    );
    
    if (response.status != 201) {
      throw APIException.fromResponse(response);
    }
    
    return TaxReturn.fromJson(response.data);
  }
  
  Future<TaxReturn> getReturn(String returnId) async {
    final response = await _supabase
        .from('tax_returns')
        .select('''
          *,
          taxpayer_info(*),
          dependents(*),
          w2_forms(*),
          deductions(*),
          credits(*),
          refund_preferences(*)
        ''')
        .eq('id', returnId)
        .single();
    
    return TaxReturn.fromJson(response);
  }
  
  Future<TaxReturn> updateReturn(String returnId, Map<String, dynamic> updates) async {
    final response = await _supabase
        .from('tax_returns')
        .update(updates)
        .eq('id', returnId)
        .select()
        .single();
    
    return TaxReturn.fromJson(response);
  }
  
  // === Calculations ===
  
  Future<TaxCalculation> calculateTax(String returnId) async {
    final response = await _supabase.functions.invoke(
      'calculate-tax',
      body: {'return_id': returnId},
    );
    
    if (response.status != 200) {
      throw APIException.fromResponse(response);
    }
    
    return TaxCalculation.fromJson(response.data);
  }
  
  // === Validation ===
  
  Future<ValidationResult> validateReturn(String returnId) async {
    final response = await _supabase.functions.invoke(
      'validate-return',
      body: {'return_id': returnId},
    );
    
    if (response.status != 200) {
      throw APIException.fromResponse(response);
    }
    
    return ValidationResult.fromJson(response.data);
  }
  
  // === E-File ===
  
  Future<SubmissionResult> submitReturn(String returnId) async {
    final response = await _supabase.functions.invoke(
      'submit-return',
      body: {'return_id': returnId},
    );
    
    if (response.status != 200) {
      throw APIException.fromResponse(response);
    }
    
    return SubmissionResult.fromJson(response.data);
  }
  
  Future<EFileStatus> getSubmissionStatus(String returnId) async {
    final response = await _supabase.functions.invoke(
      'get-submission-status',
      body: {'return_id': returnId},
    );
    
    return EFileStatus.fromJson(response.data);
  }
  
  // === Income Documents ===
  
  Future<W2Form> addW2(String returnId, W2Form w2) async {
    final response = await _supabase
        .from('w2_forms')
        .insert({
          'return_id': returnId,
          ...w2.toJson(),
        })
        .select()
        .single();
    
    return W2Form.fromJson(response);
  }
  
  Future<List<W2Form>> getW2s(String returnId) async {
    final response = await _supabase
        .from('w2_forms')
        .select()
        .eq('return_id', returnId);
    
    return (response as List).map((w) => W2Form.fromJson(w)).toList();
  }
  
  // === Dependents ===
  
  Future<Dependent> addDependent(String returnId, Dependent dependent) async {
    final response = await _supabase
        .from('dependents')
        .insert({
          'return_id': returnId,
          ...dependent.toJson(),
        })
        .select()
        .single();
    
    return Dependent.fromJson(response);
  }
}
```

### 2.3 Supabase Edge Functions

```typescript
// supabase/functions/calculate-tax/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface TaxCalculationRequest {
  return_id: string
}

serve(async (req) => {
  try {
    const { return_id } = await req.json() as TaxCalculationRequest
    
    // Create Supabase client with user's JWT
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )
    
    // Fetch return data
    const { data: taxReturn, error } = await supabase
      .from('tax_returns')
      .select(`
        *,
        taxpayer_info(*),
        dependents(*),
        w2_forms(*),
        form_1099_int(*),
        form_1099_div(*)
      `)
      .eq('id', return_id)
      .single()
    
    if (error) throw error
    
    // Calculate taxes
    const calculation = calculateTaxes(taxReturn)
    
    // Update return with calculations
    await supabase
      .from('tax_returns')
      .update({
        total_income: calculation.totalIncome,
        agi: calculation.agi,
        taxable_income: calculation.taxableIncome,
        total_tax: calculation.totalTax,
        total_payments: calculation.totalPayments,
        refund_or_owed: calculation.refundOrOwed,
      })
      .eq('id', return_id)
    
    return new Response(JSON.stringify(calculation), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

function calculateTaxes(taxReturn: any) {
  // Total income from all sources
  const wages = taxReturn.w2_forms?.reduce((sum: number, w2: any) => 
    sum + parseFloat(w2.box1_wages || 0), 0) || 0
  
  const interest = taxReturn.form_1099_int?.reduce((sum: number, f: any) =>
    sum + parseFloat(f.interest_income || 0), 0) || 0
  
  const dividends = taxReturn.form_1099_div?.reduce((sum: number, f: any) =>
    sum + parseFloat(f.ordinary_dividends || 0), 0) || 0
  
  const totalIncome = wages + interest + dividends
  
  // Adjustments (simplified)
  const adjustments = 0
  const agi = totalIncome - adjustments
  
  // Standard deduction
  const standardDeduction = getStandardDeduction(
    taxReturn.filing_status,
    taxReturn.tax_year
  )
  
  const taxableIncome = Math.max(0, agi - standardDeduction)
  
  // Calculate tax
  const tax = calculateTaxFromBrackets(
    taxableIncome,
    taxReturn.filing_status,
    taxReturn.tax_year
  )
  
  // Withholding
  const federalWithholding = taxReturn.w2_forms?.reduce((sum: number, w2: any) =>
    sum + parseFloat(w2.box2_federal_withheld || 0), 0) || 0
  
  const totalPayments = federalWithholding
  const refundOrOwed = totalPayments - tax
  
  return {
    totalIncome,
    adjustments,
    agi,
    standardDeduction,
    taxableIncome,
    totalTax: tax,
    totalPayments,
    refundOrOwed,
  }
}

function getStandardDeduction(filingStatus: string, taxYear: number): number {
  // 2024 standard deductions
  const deductions: Record<string, number> = {
    'single': 14600,
    'married_filing_jointly': 29200,
    'married_filing_separately': 14600,
    'head_of_household': 21900,
    'qualifying_widow': 29200,
  }
  return deductions[filingStatus] || 14600
}

function calculateTaxFromBrackets(
  taxableIncome: number,
  filingStatus: string,
  taxYear: number
): number {
  // 2024 tax brackets for single filer (simplified)
  const brackets = [
    { min: 0, max: 11600, rate: 0.10 },
    { min: 11600, max: 47150, rate: 0.12 },
    { min: 47150, max: 100525, rate: 0.22 },
    { min: 100525, max: 191950, rate: 0.24 },
    { min: 191950, max: 243725, rate: 0.32 },
    { min: 243725, max: 609350, rate: 0.35 },
    { min: 609350, max: Infinity, rate: 0.37 },
  ]
  
  let tax = 0
  let remainingIncome = taxableIncome
  
  for (const bracket of brackets) {
    if (remainingIncome <= 0) break
    
    const bracketSize = bracket.max - bracket.min
    const taxableInBracket = Math.min(remainingIncome, bracketSize)
    
    tax += taxableInBracket * bracket.rate
    remainingIncome -= taxableInBracket
  }
  
  return Math.round(tax * 100) / 100
}
```

---

## 3. Third-Party Integrations

### 3.1 Identity Verification Provider

```dart
/// Integration with identity verification providers
/// Options: Jumio, Onfido, Persona, Socure

class IdentityVerificationAPI {
  final String _apiKey;
  final String _baseUrl;
  final http.Client _client;
  
  IdentityVerificationAPI({
    required String apiKey,
    required String baseUrl,
    http.Client? client,
  }) : _apiKey = apiKey,
       _baseUrl = baseUrl,
       _client = client ?? http.Client();
  
  /// Create verification session
  Future<VerificationSession> createSession({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/v1/inquiries'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'template_id': 'tmpl_tax_verification',
        'reference_id': oderId,
        'attributes': {
          'name_first': firstName,
          'name_last': lastName,
        },
      }),
    );
    
    if (response.statusCode != 201) {
      throw IdentityAPIException('Failed to create session: ${response.body}');
    }
    
    final data = jsonDecode(response.body);
    return VerificationSession(
      id: data['data']['id'],
      url: data['data']['attributes']['inquiry-url'],
      status: data['data']['attributes']['status'],
    );
  }
  
  /// Get verification result
  Future<VerificationResult> getResult(String sessionId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/v1/inquiries/$sessionId'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );
    
    final data = jsonDecode(response.body);
    final attributes = data['data']['attributes'];
    
    return VerificationResult(
      sessionId: sessionId,
      status: _parseStatus(attributes['status']),
      verifiedName: attributes['name-first'] + ' ' + attributes['name-last'],
      verifiedSSN: attributes['ssn-last-4'],
      verifiedDOB: DateTime.tryParse(attributes['birthdate'] ?? ''),
      documentType: attributes['document-type'],
      selfieMatch: attributes['selfie-match-score'],
    );
  }
  
  /// Handle webhook callback
  VerificationWebhook parseWebhook(Map<String, dynamic> payload) {
    final data = payload['data'];
    return VerificationWebhook(
      eventType: payload['event_type'],
      sessionId: data['id'],
      status: data['attributes']['status'],
      timestamp: DateTime.parse(payload['created_at']),
    );
  }
  
  VerificationStatus _parseStatus(String status) {
    return switch (status) {
      'completed' => VerificationStatus.verified,
      'pending' => VerificationStatus.pending,
      'failed' => VerificationStatus.failed,
      'needs_review' => VerificationStatus.manualReview,
      _ => VerificationStatus.pending,
    };
  }
}
```

### 3.2 Document OCR Service

```dart
/// OCR service for W-2 and 1099 scanning
/// Options: Google Document AI, AWS Textract, ABBYY

class DocumentOCRService {
  final String _apiKey;
  final String _endpoint;
  
  DocumentOCRService({
    required String apiKey,
    required String endpoint,
  }) : _apiKey = apiKey,
       _endpoint = endpoint;
  
  /// Process W-2 image
  Future<W2OCRResult> processW2(Uint8List imageData) async {
    final response = await http.post(
      Uri.parse('$_endpoint/process-w2'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/octet-stream',
      },
      body: imageData,
    );
    
    if (response.statusCode != 200) {
      throw OCRException('Failed to process W-2: ${response.body}');
    }
    
    final data = jsonDecode(response.body);
    return W2OCRResult(
      confidence: data['confidence'],
      employerEIN: data['employer_ein'],
      employerName: data['employer_name'],
      wages: double.tryParse(data['box1_wages'] ?? ''),
      federalWithheld: double.tryParse(data['box2_federal'] ?? ''),
      socialSecurityWages: double.tryParse(data['box3_ss_wages'] ?? ''),
      socialSecurityTax: double.tryParse(data['box4_ss_tax'] ?? ''),
      medicareWages: double.tryParse(data['box5_medicare_wages'] ?? ''),
      medicareTax: double.tryParse(data['box6_medicare_tax'] ?? ''),
      stateCode: data['state_code'],
      stateWages: double.tryParse(data['state_wages'] ?? ''),
      stateWithheld: double.tryParse(data['state_withheld'] ?? ''),
      rawData: data,
    );
  }
  
  /// Process 1099 image
  Future<Form1099OCRResult> process1099(
    Uint8List imageData,
    Form1099Type type,
  ) async {
    final response = await http.post(
      Uri.parse('$_endpoint/process-1099'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/octet-stream',
        'X-Form-Type': type.name,
      },
      body: imageData,
    );
    
    if (response.statusCode != 200) {
      throw OCRException('Failed to process 1099: ${response.body}');
    }
    
    final data = jsonDecode(response.body);
    return Form1099OCRResult(
      formType: type,
      confidence: data['confidence'],
      payerName: data['payer_name'],
      payerTIN: data['payer_tin'],
      amount: double.tryParse(data['amount'] ?? ''),
      federalWithheld: double.tryParse(data['federal_withheld'] ?? ''),
      rawData: data,
    );
  }
}

class W2OCRResult {
  final double confidence;
  final String? employerEIN;
  final String? employerName;
  final double? wages;
  final double? federalWithheld;
  final double? socialSecurityWages;
  final double? socialSecurityTax;
  final double? medicareWages;
  final double? medicareTax;
  final String? stateCode;
  final double? stateWages;
  final double? stateWithheld;
  final Map<String, dynamic> rawData;
  
  const W2OCRResult({
    required this.confidence,
    this.employerEIN,
    this.employerName,
    this.wages,
    this.federalWithheld,
    this.socialSecurityWages,
    this.socialSecurityTax,
    this.medicareWages,
    this.medicareTax,
    this.stateCode,
    this.stateWages,
    this.stateWithheld,
    required this.rawData,
  });
  
  bool get isHighConfidence => confidence >= 0.95;
  
  W2Form toW2Form() {
    // Convert OCR result to W2Form model
    return W2Form(
      id: '', // Will be assigned by database
      employerEIN: employerEIN ?? '',
      employerName: employerName ?? '',
      employerAddress: Address.empty(),
      box1Wages: wages ?? 0,
      box2FederalWithheld: federalWithheld ?? 0,
      box3SocialSecurityWages: socialSecurityWages ?? 0,
      box4SocialSecurityTax: socialSecurityTax ?? 0,
      box5MedicareWages: medicareWages ?? 0,
      box6MedicareTax: medicareTax ?? 0,
      stateCode: stateCode,
      stateWages: stateWages,
      stateIncomeTax: stateWithheld,
    );
  }
}
```

### 3.3 Bank Product API

```dart
/// Integration with refund transfer bank partners
/// TPG, EPS, Republic Bank, etc.

class BankProductAPI {
  final String _apiKey;
  final String _partnerId;
  final String _baseUrl;
  
  BankProductAPI({
    required String apiKey,
    required String partnerId,
    required String baseUrl,
  }) : _apiKey = apiKey,
       _partnerId = partnerId,
       _baseUrl = baseUrl;
  
  /// Create refund transfer application
  Future<RefundTransferApplication> createApplication({
    required String returnId,
    required String taxpayerSSN,
    required String taxpayerName,
    required double expectedRefund,
    required BankProductType productType,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/applications'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'X-Partner-Id': _partnerId,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'return_id': returnId,
        'taxpayer_ssn_last4': taxpayerSSN.substring(5),
        'taxpayer_name': taxpayerName,
        'expected_refund': expectedRefund,
        'product_type': productType.name,
      }),
    );
    
    if (response.statusCode != 201) {
      throw BankProductException('Failed to create application');
    }
    
    final data = jsonDecode(response.body);
    return RefundTransferApplication(
      id: data['application_id'],
      temporaryRoutingNumber: data['routing_number'],
      temporaryAccountNumber: data['account_number'],
      fees: (data['fees'] as List)
          .map((f) => BankFee.fromJson(f))
          .toList(),
      status: data['status'],
    );
  }
  
  /// Get disbursement status
  Future<DisbursementStatus> getDisbursementStatus(String applicationId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/applications/$applicationId/status'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'X-Partner-Id': _partnerId,
      },
    );
    
    final data = jsonDecode(response.body);
    return DisbursementStatus(
      applicationId: applicationId,
      refundReceived: data['refund_received'],
      refundAmount: double.tryParse(data['refund_amount'] ?? '0'),
      feesDeducted: double.tryParse(data['fees_deducted'] ?? '0'),
      netDisbursed: double.tryParse(data['net_disbursed'] ?? '0'),
      disbursementDate: DateTime.tryParse(data['disbursement_date'] ?? ''),
      disbursementMethod: data['disbursement_method'],
    );
  }
}

class RefundTransferApplication {
  final String id;
  final String temporaryRoutingNumber;
  final String temporaryAccountNumber;
  final List<BankFee> fees;
  final String status;
  
  const RefundTransferApplication({
    required this.id,
    required this.temporaryRoutingNumber,
    required this.temporaryAccountNumber,
    required this.fees,
    required this.status,
  });
}

class BankFee {
  final String description;
  final double amount;
  
  const BankFee({required this.description, required this.amount});
  
  factory BankFee.fromJson(Map<String, dynamic> json) => BankFee(
    description: json['description'],
    amount: double.parse(json['amount']),
  );
}
```

---

## 4. API Security

### 4.1 Authentication & Authorization

```dart
/// API security middleware and helpers

class APISecurityService {
  final SupabaseClient _supabase;
  
  APISecurityService(this._supabase);
  
  /// Verify user has access to resource
  Future<bool> verifyAccess({
    required String userId,
    required String resourceType,
    required String resourceId,
    required AccessType accessType,
  }) async {
    // Check RLS will handle most cases via Supabase
    // Additional business logic checks here
    
    switch (resourceType) {
      case 'tax_return':
        return _verifyReturnAccess(userId, resourceId, accessType);
      case 'w2_form':
        return _verifyW2Access(userId, resourceId, accessType);
      default:
        return false;
    }
  }
  
  Future<bool> _verifyReturnAccess(
    String userId,
    String returnId,
    AccessType accessType,
  ) async {
    final response = await _supabase
        .from('tax_returns')
        .select('user_id')
        .eq('id', returnId)
        .maybeSingle();
    
    return response?['user_id'] == userId;
  }
  
  Future<bool> _verifyW2Access(
    String userId,
    String w2Id,
    AccessType accessType,
  ) async {
    final response = await _supabase
        .from('w2_forms')
        .select('return_id, tax_returns!inner(user_id)')
        .eq('id', w2Id)
        .maybeSingle();
    
    return response?['tax_returns']['user_id'] == userId;
  }
}

enum AccessType { read, write, delete }
```

### 4.2 Rate Limiting

```dart
/// Rate limiting for API endpoints

class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  
  final int maxRequests;
  final Duration window;
  
  RateLimiter({
    this.maxRequests = 100,
    this.window = const Duration(minutes: 1),
  });
  
  bool shouldAllowRequest(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    
    // Clean old requests
    _requests[key] = (_requests[key] ?? [])
        .where((t) => t.isAfter(windowStart))
        .toList();
    
    // Check limit
    if ((_requests[key]?.length ?? 0) >= maxRequests) {
      return false;
    }
    
    // Record request
    _requests[key] = [...(_requests[key] ?? []), now];
    return true;
  }
  
  int remainingRequests(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    
    final recentRequests = (_requests[key] ?? [])
        .where((t) => t.isAfter(windowStart))
        .length;
    
    return maxRequests - recentRequests;
  }
}
```

---

## 5. Webhook Handling

### 5.1 Webhook Processor

```dart
/// Process webhooks from third-party services

class WebhookProcessor {
  final SupabaseClient _supabase;
  final NotificationService _notificationService;
  
  WebhookProcessor(this._supabase, this._notificationService);
  
  Future<void> processWebhook({
    required String source,
    required String eventType,
    required Map<String, dynamic> payload,
    required String signature,
  }) async {
    // Verify webhook signature
    if (!_verifySignature(source, payload, signature)) {
      throw WebhookException('Invalid signature');
    }
    
    // Route to appropriate handler
    switch (source) {
      case 'identity_verification':
        await _processIdentityWebhook(eventType, payload);
        break;
      case 'bank_product':
        await _processBankProductWebhook(eventType, payload);
        break;
      case 'mef_acknowledgment':
        await _processMeFWebhook(eventType, payload);
        break;
    }
    
    // Log webhook
    await _logWebhook(source, eventType, payload);
  }
  
  Future<void> _processIdentityWebhook(
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    final sessionId = payload['data']['id'];
    final status = payload['data']['attributes']['status'];
    
    // Update verification record
    await _supabase
        .from('identity_verifications')
        .update({
          'verification_status': status,
          'result': payload['data']['attributes'],
          if (status == 'completed') 'verified_at': DateTime.now().toIso8601String(),
        })
        .eq('provider_session_id', sessionId);
    
    // Notify user
    if (status == 'completed') {
      await _notificationService.send(
        type: NotificationType.identityVerified,
        data: {'session_id': sessionId},
      );
    }
  }
  
  Future<void> _processMeFWebhook(
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    final submissionId = payload['submission_id'];
    final status = payload['status'];
    
    // Update submission record
    await _supabase
        .from('efile_submissions')
        .update({
          'status': status,
          'acknowledgment_received_at': DateTime.now().toIso8601String(),
          if (status == 'accepted') 'accepted_at': DateTime.now().toIso8601String(),
          if (status == 'rejected') ...{
            'rejected_at': DateTime.now().toIso8601String(),
            'rejection_code': payload['error_code'],
            'rejection_message': payload['error_message'],
          },
          'raw_acknowledgment': payload,
        })
        .eq('submission_id', submissionId);
    
    // Notify user
    await _notificationService.send(
      type: status == 'accepted' 
          ? NotificationType.returnAccepted 
          : NotificationType.returnRejected,
      data: {'submission_id': submissionId},
    );
  }
  
  bool _verifySignature(
    String source,
    Map<String, dynamic> payload,
    String signature,
  ) {
    // Implement HMAC verification based on source
    // Each provider has different signing method
    return true; // Simplified
  }
  
  Future<void> _logWebhook(
    String source,
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    await _supabase.from('webhook_logs').insert({
      'source': source,
      'event_type': eventType,
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
```

---

## 6. Implementation Checklist

- [ ] Set up MeF API credentials (EFIN, Software ID)
- [ ] Implement MeF SOAP client
- [ ] Configure Supabase Edge Functions
- [ ] Create internal REST API layer
- [ ] Integrate identity verification provider
- [ ] Set up document OCR service
- [ ] Implement bank product API integration
- [ ] Configure webhook endpoints
- [ ] Add rate limiting
- [ ] Implement API security middleware
- [ ] Set up API monitoring and logging

---

## 7. Related Documents

- [E-File Transmission](./efile_transmission.md)
- [Security Compliance](./security_compliance.md)
- [Identity Verification](./identity_verification.md)
- [Testing & Validation](./testing_validation.md)
