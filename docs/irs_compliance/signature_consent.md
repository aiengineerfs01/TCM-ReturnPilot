# Electronic Signature & Taxpayer Consent

## Overview

This document outlines IRS requirements for electronic signatures, taxpayer consent forms, disclosure authorizations, and the Self-Select PIN process for e-filed returns.

---

## 1. IRS Electronic Signature Requirements

### 1.1 Self-Select PIN Method

```dart
/// Self-Select PIN is the primary method for signing e-filed returns
/// for self-prepared returns (DIY tax software)
class SelfSelectPIN {
  // Requirements:
  // 1. Taxpayer must enter their own PIN
  // 2. PIN must be 5 digits (any 5 digits chosen by taxpayer)
  // 3. Cannot be all zeros (00000)
  // 4. Taxpayer must also provide AGI or prior year PIN for identity verification
  
  final String pin;                    // 5-digit PIN
  final DateTime signatureDate;
  final String ipAddress;
  final String deviceIdentifier;
  
  // Identity verification (one required)
  final double? priorYearAGI;          // From prior year return
  final String? priorYearPIN;          // If signed electronically last year
  final String? ipPIN;                 // IRS Identity Protection PIN
  
  const SelfSelectPIN({
    required this.pin,
    required this.signatureDate,
    required this.ipAddress,
    required this.deviceIdentifier,
    this.priorYearAGI,
    this.priorYearPIN,
    this.ipPIN,
  });
  
  bool get isValid {
    // PIN must be exactly 5 digits
    if (!RegExp(r'^\d{5}$').hasMatch(pin)) return false;
    // Cannot be all zeros
    if (pin == '00000') return false;
    // Must have identity verification
    if (priorYearAGI == null && priorYearPIN == null && ipPIN == null) {
      return false;
    }
    return true;
  }
}
```

### 1.2 Practitioner PIN Method

```dart
/// For returns prepared by tax professionals (EROs)
class PractitionerPIN {
  // The ERO enters both taxpayer and ERO signatures
  // Taxpayer must authorize the ERO to enter their PIN
  
  final String taxpayerPIN;           // 5 digits
  final String eroPIN;                // ERO's PIN
  final String eroSignature;          // ERO's signature
  final DateTime taxpayerAuthDate;    // When taxpayer authorized
  final DateTime eroSignatureDate;
  
  // ERO must retain signed Form 8879 for 3 years
  final Form8879 authorizationForm;
  
  const PractitionerPIN({
    required this.taxpayerPIN,
    required this.eroPIN,
    required this.eroSignature,
    required this.taxpayerAuthDate,
    required this.eroSignatureDate,
    required this.authorizationForm,
  });
}
```

### 1.3 Identity Protection PIN (IP PIN)

```dart
/// IRS-issued IP PIN for identity theft protection
class IdentityProtectionPIN {
  // 6-digit PIN issued annually by IRS
  // Required if taxpayer is enrolled in IP PIN program
  // Prevents fraudulent returns from being filed
  
  final String ipPin;                  // 6 digits
  final int taxYear;                   // IP PIN is year-specific
  
  const IdentityProtectionPIN({
    required this.ipPin,
    required this.taxYear,
  });
  
  static bool isValid(String pin) {
    return RegExp(r'^\d{6}$').hasMatch(pin);
  }
}
```

---

## 2. Consent & Authorization Forms

### 2.1 Form 8879 - IRS e-file Signature Authorization

```dart
/// Form 8879 authorizes ERO to submit return and enter taxpayer's PIN
class Form8879 {
  // Part I - Tax Return Information
  final String taxpayerName;
  final String taxpayerSSN;
  final String? spouseName;
  final String? spouseSSN;
  
  // Tax return summary
  final double adjustedGrossIncome;     // Line 1 (Form 1040, line 11)
  final double totalTax;                // Line 2 (Form 1040, line 24)
  final double? federalWithholding;     // Line 3
  final double? refundAmount;           // Line 4
  final double? amountOwed;             // Line 5
  
  // Part II - Declaration and Signature
  final bool taxpayerConsent;
  final String? taxpayerPIN;            // Line 6
  final DateTime? taxpayerSignDate;
  final String? spousePIN;              // Line 7
  final DateTime? spouseSignDate;
  
  // Part III - ERO Information
  final String eroName;
  final String eroEFIN;
  final String eroPIN;
  final DateTime eroSignDate;
  
  const Form8879({
    required this.taxpayerName,
    required this.taxpayerSSN,
    this.spouseName,
    this.spouseSSN,
    required this.adjustedGrossIncome,
    required this.totalTax,
    this.federalWithholding,
    this.refundAmount,
    this.amountOwed,
    required this.taxpayerConsent,
    this.taxpayerPIN,
    this.taxpayerSignDate,
    this.spousePIN,
    this.spouseSignDate,
    required this.eroName,
    required this.eroEFIN,
    required this.eroPIN,
    required this.eroSignDate,
  });
  
  // Validation rules
  bool get isValidForSubmission {
    // Taxpayer must consent
    if (!taxpayerConsent) return false;
    
    // Taxpayer PIN required
    if (taxpayerPIN == null || !_isValidPIN(taxpayerPIN!)) return false;
    
    // If MFJ, spouse PIN required
    if (spouseSSN != null && (spousePIN == null || !_isValidPIN(spousePIN!))) {
      return false;
    }
    
    // ERO information complete
    if (eroName.isEmpty || eroEFIN.isEmpty || eroPIN.isEmpty) return false;
    
    return true;
  }
  
  bool _isValidPIN(String pin) {
    return RegExp(r'^\d{5}$').hasMatch(pin) && pin != '00000';
  }
}
```

### 2.2 Consent to Disclosure

```dart
/// IRS Regulation on disclosure and consent requirements
class DisclosureConsent {
  // Types of consent
  final bool consentToUseReturnInfo;        // Use for other services
  final bool consentToDiscloseToThirdParty; // Share with third parties
  final bool consentToRetainData;           // Keep data after filing
  final bool consentToMarketingCommunications;
  
  // IRS 7216 Consent Requirements
  final String purpose;                     // Specific purpose of disclosure
  final String? thirdPartyName;            // Who data will be shared with
  final DateTime consentDate;
  final DateTime? expirationDate;          // Consent expiration
  
  // Taxpayer acknowledgment
  final bool taxpayerAcknowledged;
  final String taxpayerName;
  final String taxpayerSignature;
  final DateTime signatureTimestamp;
  
  const DisclosureConsent({
    this.consentToUseReturnInfo = false,
    this.consentToDiscloseToThirdParty = false,
    this.consentToRetainData = false,
    this.consentToMarketingCommunications = false,
    required this.purpose,
    this.thirdPartyName,
    required this.consentDate,
    this.expirationDate,
    required this.taxpayerAcknowledged,
    required this.taxpayerName,
    required this.taxpayerSignature,
    required this.signatureTimestamp,
  });
}
```

### 2.3 Form 2848 - Power of Attorney

```dart
/// Power of Attorney and Declaration of Representative
class Form2848 {
  // Part I - Power of Attorney
  final TaxpayerInfo taxpayer;
  final List<Representative> representatives;
  
  // Part I - Tax Matters
  final List<TaxMatter> taxMatters;
  
  // Part I - Acts Authorized
  final bool receiveRefund;
  final bool substituteRepresentative;
  final String? specificAuthorizationDetails;
  
  // Part II - Declaration of Representative
  final List<RepresentativeDeclaration> declarations;
  
  // Signatures
  final String taxpayerSignature;
  final DateTime taxpayerSignDate;
  final String? spouseSignature;
  final DateTime? spouseSignDate;
  
  const Form2848({
    required this.taxpayer,
    required this.representatives,
    required this.taxMatters,
    this.receiveRefund = false,
    this.substituteRepresentative = false,
    this.specificAuthorizationDetails,
    required this.declarations,
    required this.taxpayerSignature,
    required this.taxpayerSignDate,
    this.spouseSignature,
    this.spouseSignDate,
  });
}

class Representative {
  final String name;
  final String cadNumber;       // CAF number
  final String ptin;            // If applicable
  final String telephone;
  final String faxNumber;
  final String address;
  final bool checkIfNew;
  
  const Representative({
    required this.name,
    required this.cadNumber,
    this.ptin = '',
    required this.telephone,
    this.faxNumber = '',
    required this.address,
    this.checkIfNew = false,
  });
}

class TaxMatter {
  final String formNumber;      // e.g., "1040"
  final String taxPeriod;       // e.g., "2024"
  final String description;
  
  const TaxMatter({
    required this.formNumber,
    required this.taxPeriod,
    this.description = '',
  });
}
```

---

## 3. Signature Capture Implementation

### 3.1 Digital Signature Service

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class DigitalSignatureService {
  
  /// Capture taxpayer's electronic signature
  Future<ElectronicSignature> captureSignature({
    required String taxpayerName,
    required String taxpayerSSN,
    required String pin,
    required SignatureMethod method,
    required String documentHash,
  }) async {
    // Get device and session info
    final deviceInfo = await _getDeviceInfo();
    final sessionInfo = await _getSessionInfo();
    
    // Create signature record
    final signature = ElectronicSignature(
      taxpayerName: taxpayerName,
      taxpayerSSNLastFour: taxpayerSSN.substring(taxpayerSSN.length - 4),
      pin: pin,
      method: method,
      signatureTimestamp: DateTime.now().toUtc(),
      ipAddress: sessionInfo.ipAddress,
      deviceId: deviceInfo.deviceId,
      userAgent: deviceInfo.userAgent,
      documentHash: documentHash,
      signatureHash: _generateSignatureHash(
        pin: pin,
        timestamp: DateTime.now().toUtc(),
        documentHash: documentHash,
      ),
    );
    
    // Log signature event
    await _auditLog.logAction(
      action: 'signature.captured',
      resourceType: 'tax_return',
      metadata: {
        'method': method.toString(),
        'ssn_last_four': signature.taxpayerSSNLastFour,
      },
    );
    
    return signature;
  }
  
  /// Verify signature integrity
  bool verifySignature(ElectronicSignature signature, String documentHash) {
    // Recalculate expected hash
    final expectedHash = _generateSignatureHash(
      pin: signature.pin,
      timestamp: signature.signatureTimestamp,
      documentHash: documentHash,
    );
    
    return signature.signatureHash == expectedHash &&
           signature.documentHash == documentHash;
  }
  
  String _generateSignatureHash({
    required String pin,
    required DateTime timestamp,
    required String documentHash,
  }) {
    final data = '$pin|${timestamp.toIso8601String()}|$documentHash';
    return sha256.convert(utf8.encode(data)).toString();
  }
}

class ElectronicSignature {
  final String taxpayerName;
  final String taxpayerSSNLastFour;
  final String pin;
  final SignatureMethod method;
  final DateTime signatureTimestamp;
  final String ipAddress;
  final String deviceId;
  final String userAgent;
  final String documentHash;
  final String signatureHash;
  
  const ElectronicSignature({
    required this.taxpayerName,
    required this.taxpayerSSNLastFour,
    required this.pin,
    required this.method,
    required this.signatureTimestamp,
    required this.ipAddress,
    required this.deviceId,
    required this.userAgent,
    required this.documentHash,
    required this.signatureHash,
  });
  
  Map<String, dynamic> toJson() => {
    'taxpayer_name': taxpayerName,
    'ssn_last_four': taxpayerSSNLastFour,
    'pin_hash': sha256.convert(utf8.encode(pin)).toString(), // Never store actual PIN
    'method': method.toString(),
    'signature_timestamp': signatureTimestamp.toIso8601String(),
    'ip_address': ipAddress,
    'device_id': deviceId,
    'user_agent': userAgent,
    'document_hash': documentHash,
    'signature_hash': signatureHash,
  };
}

enum SignatureMethod {
  selfSelectPIN,
  practitionerPIN,
  eroSignature,
}
```

### 3.2 PIN Entry UI Component

```dart
class PINEntryWidget extends StatefulWidget {
  final Function(String) onPINEntered;
  final bool isSpouse;
  
  const PINEntryWidget({
    required this.onPINEntered,
    this.isSpouse = false,
  });
  
  @override
  State<PINEntryWidget> createState() => _PINEntryWidgetState();
}

class _PINEntryWidgetState extends State<PINEntryWidget> {
  final _pinController = TextEditingController();
  String? _errorMessage;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isSpouse 
              ? 'Spouse\'s Self-Select PIN' 
              : 'Your Self-Select PIN',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        Text(
          'Enter a 5-digit PIN to sign your return electronically. '
          'You may choose any 5 digits (except 00000).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          maxLength: 5,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '5-Digit PIN',
            hintText: 'XXXXX',
            errorText: _errorMessage,
            counterText: '',
            prefixIcon: const Icon(Icons.lock),
          ),
          onChanged: _validatePIN,
        ),
        const SizedBox(height: 8),
        
        // PIN requirements hint
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your PIN acts as your electronic signature. '
                  'Keep it confidential and remember it for your records.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Confirm button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canSubmit ? _submitPIN : null,
            child: const Text('Confirm PIN'),
          ),
        ),
      ],
    );
  }
  
  bool get _canSubmit => _errorMessage == null && _pinController.text.length == 5;
  
  void _validatePIN(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorMessage = null;
      } else if (!RegExp(r'^\d+$').hasMatch(value)) {
        _errorMessage = 'PIN must contain only numbers';
      } else if (value.length == 5 && value == '00000') {
        _errorMessage = 'PIN cannot be 00000';
      } else if (value.length < 5) {
        _errorMessage = null; // Don't show error while typing
      } else {
        _errorMessage = null;
      }
    });
  }
  
  void _submitPIN() {
    if (_canSubmit) {
      widget.onPINEntered(_pinController.text);
    }
  }
}
```

---

## 4. Identity Verification for Signature

### 4.1 Prior Year AGI Verification

```dart
class AGIVerificationWidget extends StatefulWidget {
  final Function(double) onAGIEntered;
  final int priorTaxYear;
  
  const AGIVerificationWidget({
    required this.onAGIEntered,
    required this.priorTaxYear,
  });
  
  @override
  State<AGIVerificationWidget> createState() => _AGIVerificationWidgetState();
}

class _AGIVerificationWidgetState extends State<AGIVerificationWidget> {
  final _agiController = TextEditingController();
  bool _didNotFile = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identity Verification',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        Text(
          'To verify your identity, please enter your Adjusted Gross Income (AGI) '
          'from your ${widget.priorTaxYear} tax return (Form 1040, Line 11).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        
        if (!_didNotFile) ...[
          TextField(
            controller: _agiController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Prior Year AGI',
              hintText: '0.00',
              prefixText: '\$ ',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Option for first-time filers or didn't file
        CheckboxListTile(
          value: _didNotFile,
          onChanged: (value) {
            setState(() {
              _didNotFile = value ?? false;
              if (_didNotFile) {
                _agiController.text = '0';
              }
            });
          },
          title: const Text('I did not file a tax return last year'),
          subtitle: Text(
            'Select this if ${widget.priorTaxYear} was your first year filing or '
            'you didn\'t file last year.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        // Help section
        ExpansionTile(
          title: const Text('Where do I find my AGI?'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('You can find your prior year AGI:'),
                  SizedBox(height: 8),
                  Text('• Form 1040, Line 11'),
                  Text('• Your IRS online account at irs.gov'),
                  Text('• Your tax software from last year'),
                  Text('• Request a transcript from IRS'),
                  SizedBox(height: 8),
                  Text(
                    'Note: If you filed late or amended your return, '
                    'the AGI may be different than what\'s on your copy.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 4.2 IP PIN Entry

```dart
class IPPINEntryWidget extends StatelessWidget {
  final Function(String) onIPPINEntered;
  final String taxpayerName;
  
  const IPPINEntryWidget({
    required this.onIPPINEntered,
    required this.taxpayerName,
  });
  
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alert banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade700),
          ),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.amber.shade900),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'An Identity Protection PIN is required for $taxpayerName',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Enter the 6-digit IP PIN issued by the IRS. This PIN is sent to you '
          'annually by mail or available in your IRS online account.',
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'IP PIN',
            hintText: 'XXXXXX',
            counterText: '',
            prefixIcon: Icon(Icons.verified_user),
          ),
          onChanged: (value) {
            if (value.length == 6) {
              onIPPINEntered(value);
            }
          },
        ),
        const SizedBox(height: 8),
        
        // Help link
        TextButton.icon(
          onPressed: () {
            // Open IRS IP PIN help page
          },
          icon: const Icon(Icons.help_outline, size: 18),
          label: const Text('Don\'t have your IP PIN?'),
        ),
      ],
    );
  }
}
```

---

## 5. Consent Flow Implementation

### 5.1 Signature Flow Controller

```dart
class SignatureFlowController extends GetxController {
  final TaxReturnRepository _repository;
  final DigitalSignatureService _signatureService;
  final AuditLogService _auditLog;
  
  // Flow state
  final currentStep = 0.obs;
  final isLoading = false.obs;
  
  // Taxpayer signature data
  final taxpayerPIN = ''.obs;
  final taxpayerAGI = 0.0.obs;
  final taxpayerIPPIN = ''.obs;
  final taxpayerSignature = Rxn<ElectronicSignature>();
  
  // Spouse signature data (if MFJ)
  final spousePIN = ''.obs;
  final spouseIPPIN = ''.obs;
  final spouseSignature = Rxn<ElectronicSignature>();
  
  // Consent flags
  final disclosureConsent = false.obs;
  final efileConsent = false.obs;
  final bankInfoConsent = false.obs;
  
  SignatureFlowController(
    this._repository,
    this._signatureService,
    this._auditLog,
  );
  
  // Flow steps
  static const steps = [
    'Review Return',
    'Verify Identity',
    'Enter PIN',
    'Consent & Sign',
    'Confirmation',
  ];
  
  Future<bool> captureSignatures(TaxReturn taxReturn) async {
    try {
      isLoading.value = true;
      
      // Generate document hash for signing
      final documentHash = _generateDocumentHash(taxReturn);
      
      // Capture primary taxpayer signature
      taxpayerSignature.value = await _signatureService.captureSignature(
        taxpayerName: taxReturn.taxpayer.fullName,
        taxpayerSSN: taxReturn.taxpayer.ssn,
        pin: taxpayerPIN.value,
        method: SignatureMethod.selfSelectPIN,
        documentHash: documentHash,
      );
      
      // Capture spouse signature if MFJ
      if (taxReturn.filingStatus == FilingStatus.marriedFilingJointly &&
          taxReturn.spouse != null) {
        spouseSignature.value = await _signatureService.captureSignature(
          taxpayerName: taxReturn.spouse!.fullName,
          taxpayerSSN: taxReturn.spouse!.ssn,
          pin: spousePIN.value,
          method: SignatureMethod.selfSelectPIN,
          documentHash: documentHash,
        );
      }
      
      // Save signatures to return
      await _repository.saveSignatures(
        returnId: taxReturn.id,
        primarySignature: taxpayerSignature.value!,
        spouseSignature: spouseSignature.value,
        identityVerification: IdentityVerification(
          method: taxpayerIPPIN.value.isNotEmpty 
              ? VerificationMethod.ipPIN 
              : VerificationMethod.priorYearAGI,
          priorYearAGI: taxpayerAGI.value,
          ipPIN: taxpayerIPPIN.value.isNotEmpty ? taxpayerIPPIN.value : null,
        ),
      );
      
      // Log completion
      await _auditLog.logAction(
        action: 'signature.completed',
        resourceType: 'tax_return',
        resourceId: taxReturn.id,
      );
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture signature: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  String _generateDocumentHash(TaxReturn taxReturn) {
    // Hash critical return values for tamper detection
    final data = [
      taxReturn.taxpayer.ssn,
      taxReturn.filingStatus.toString(),
      taxReturn.calculations.agi.toString(),
      taxReturn.calculations.totalTax.toString(),
      taxReturn.calculations.refundAmount.toString(),
    ].join('|');
    
    return sha256.convert(utf8.encode(data)).toString();
  }
  
  bool validateAllConsents() {
    return disclosureConsent.value && efileConsent.value;
  }
  
  void goToStep(int step) {
    if (step >= 0 && step < steps.length) {
      currentStep.value = step;
    }
  }
  
  void nextStep() => goToStep(currentStep.value + 1);
  void previousStep() => goToStep(currentStep.value - 1);
}
```

### 5.2 Consent Agreement Screen

```dart
class ConsentAgreementScreen extends GetView<SignatureFlowController> {
  const ConsentAgreementScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review & Sign')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // E-File Authorization
            _buildConsentCard(
              title: 'Authorization to E-File',
              content: '''
By signing below, I authorize the electronic filing of my federal income tax return with the Internal Revenue Service.

I declare that I have examined this return, including all schedules and attachments, and to the best of my knowledge and belief, it is true, correct, and complete.

I consent to the use of my Self-Select PIN as my signature on my electronically filed return.
''',
              consentValue: controller.efileConsent,
              required: true,
            ),
            
            const SizedBox(height: 16),
            
            // Disclosure Consent
            _buildConsentCard(
              title: 'Disclosure Consent',
              content: '''
I consent to the disclosure of my tax return information to the IRS for the purpose of processing my electronically filed return.

I understand that my return will be transmitted securely to the IRS and that my information is protected under federal privacy laws.
''',
              consentValue: controller.disclosureConsent,
              required: true,
            ),
            
            const SizedBox(height: 16),
            
            // Direct Deposit Authorization (if applicable)
            Obx(() {
              if (controller.hasDirectDeposit) {
                return _buildConsentCard(
                  title: 'Direct Deposit Authorization',
                  content: '''
I authorize the IRS and its designated Financial Agent to initiate an electronic funds transfer to the financial institution and account indicated on this return.

I understand that if the refund is unable to be deposited, the IRS will mail a paper check.
''',
                  consentValue: controller.bankInfoConsent,
                  required: true,
                );
              }
              return const SizedBox.shrink();
            }),
            
            const SizedBox(height: 24),
            
            // Penalties of Perjury Statement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Declaration Under Penalties of Perjury',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Under penalties of perjury, I declare that I have examined this '
                    'return and accompanying schedules and statements, and to the best '
                    'of my knowledge and belief, they are true, correct, and complete.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Continue button
            Obx(() {
              final canContinue = controller.validateAllConsents();
              
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canContinue ? controller.nextStep : null,
                  child: const Text('Continue to Sign'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConsentCard({
    required String title,
    required String content,
    required RxBool consentValue,
    required bool required,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (required)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Obx(() => CheckboxListTile(
              value: consentValue.value,
              onChanged: (value) => consentValue.value = value ?? false,
              title: const Text('I have read and agree'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. Database Schema

```sql
-- Electronic Signatures
CREATE TABLE electronic_signatures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  signer_type TEXT NOT NULL, -- 'primary', 'spouse', 'preparer'
  signer_name TEXT NOT NULL,
  ssn_last_four TEXT NOT NULL,
  pin_hash TEXT NOT NULL, -- Hashed PIN, never store plain
  signature_method TEXT NOT NULL,
  signature_timestamp TIMESTAMPTZ NOT NULL,
  ip_address INET NOT NULL,
  device_id TEXT NOT NULL,
  user_agent TEXT,
  document_hash TEXT NOT NULL,
  signature_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Identity Verifications for Signing
CREATE TABLE signature_verifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  signature_id UUID NOT NULL REFERENCES electronic_signatures(id),
  verification_method TEXT NOT NULL, -- 'prior_year_agi', 'ip_pin', 'prior_year_pin'
  prior_year_agi DECIMAL(12,2),
  ip_pin_used BOOLEAN DEFAULT FALSE,
  verification_successful BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Consent Records
CREATE TABLE consent_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  consent_type TEXT NOT NULL, -- 'efile', 'disclosure', 'bank_info', 'marketing'
  consent_given BOOLEAN NOT NULL,
  consent_text TEXT NOT NULL, -- Store exact text shown
  consent_timestamp TIMESTAMPTZ NOT NULL,
  ip_address INET NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE electronic_signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE consent_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY signature_owner_access ON electronic_signatures
  FOR ALL USING (
    return_id IN (SELECT id FROM tax_returns WHERE user_id = auth.uid())
  );

CREATE POLICY consent_owner_access ON consent_records
  FOR ALL USING (user_id = auth.uid());
```

---

## 7. Implementation Checklist

- [ ] Implement SelfSelectPIN validation
- [ ] Build PIN entry UI component
- [ ] Implement AGI verification flow
- [ ] Add IP PIN entry and validation
- [ ] Create DigitalSignatureService
- [ ] Build consent agreement screens
- [ ] Create SignatureFlowController
- [ ] Implement signature capture and storage
- [ ] Add document hashing for tamper detection
- [ ] Create database tables and RLS policies
- [ ] Build audit logging for signatures
- [ ] Add signature verification service

---

## 8. Related Documents

- [Security Compliance](./security_compliance.md)
- [Identity Verification](./identity_verification.md)
- [E-File Transmission](./efile_transmission.md)
- [Audit Trail](./audit_trail.md)
