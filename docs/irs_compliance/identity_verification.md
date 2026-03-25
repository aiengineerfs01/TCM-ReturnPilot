# Identity Verification Requirements

## Overview

This document details IRS identity verification requirements for e-file, including taxpayer identity proofing, preparer identification, and fraud prevention measures per IRS Publications 1345 and 4557.

---

## 1. IRS Identity Proofing Requirements

### 1.1 NIST IAL2 Standards

```dart
/// IRS requires Identity Assurance Level 2 (IAL2) per NIST 800-63A
/// This involves identity proofing through:
/// 1. Evidence collection
/// 2. Evidence validation
/// 3. Identity verification
/// 4. Address confirmation

enum IdentityAssuranceLevel {
  ial1,  // Self-asserted identity (not sufficient for IRS)
  ial2,  // Remote or in-person identity proofing (IRS minimum)
  ial3,  // In-person identity proofing with physical presence
}

class IdentityProofingRequirements {
  // IRS requires either:
  // 1. Knowledge-Based Verification (KBV) with credit history
  // 2. Document verification with biometric matching
  // 3. Video call verification
  
  static const minimumRequirements = {
    'ssnVerification': true,
    'addressVerification': true,
    'dateOfBirthVerification': true,
    'photoIdRequired': true,
    'selfieMatchRequired': true,
  };
}
```

### 1.2 Identity Verification Model

```dart
enum VerificationMethod {
  documentVerification,  // Photo ID + selfie
  knowledgeBased,        // Credit history questions (KBA)
  videoVerification,     // Live video call
  inPerson,              // In-person verification
}

enum VerificationStatus {
  pending,
  inProgress,
  verified,
  failed,
  expired,
  manualReview,
}

class IdentityVerification {
  final String id;
  final String oderId;
  final VerificationMethod method;
  final VerificationStatus status;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final String? verificationProvider;
  final String? referenceId;
  final IdentityVerificationResult? result;
  
  const IdentityVerification({
    required this.id,
    required this.oderId,
    required this.method,
    required this.status,
    required this.initiatedAt,
    this.completedAt,
    this.expiresAt,
    this.verificationProvider,
    this.referenceId,
    this.result,
  });
  
  bool get isValid {
    if (status != VerificationStatus.verified) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    return true;
  }
  
  // IRS requires re-verification after 24 months
  static const verificationValidityPeriod = Duration(days: 730);
}

class IdentityVerificationResult {
  final bool ssnVerified;
  final bool nameVerified;
  final bool dateOfBirthVerified;
  final bool addressVerified;
  final bool photoIdVerified;
  final bool selfieMatched;
  final double? confidenceScore;
  final List<VerificationWarning> warnings;
  final Map<String, dynamic>? providerResponse;
  
  const IdentityVerificationResult({
    required this.ssnVerified,
    required this.nameVerified,
    required this.dateOfBirthVerified,
    required this.addressVerified,
    required this.photoIdVerified,
    required this.selfieMatched,
    this.confidenceScore,
    this.warnings = const [],
    this.providerResponse,
  });
  
  bool get passesIrsRequirements {
    return ssnVerified && 
           nameVerified && 
           dateOfBirthVerified && 
           photoIdVerified &&
           selfieMatched;
  }
}

class VerificationWarning {
  final String code;
  final String message;
  final WarningLevel level;
  
  const VerificationWarning({
    required this.code,
    required this.message,
    required this.level,
  });
}

enum WarningLevel { info, warning, critical }
```

---

## 2. Document Verification

### 2.1 Accepted Identity Documents

```dart
enum DocumentType {
  // Primary Documents (Photo ID)
  driversLicense,
  stateId,
  passport,
  passportCard,
  militaryId,
  
  // Secondary Documents (Supporting)
  socialSecurityCard,
  birthCertificate,
  utilityBill,
  bankStatement,
  w2Form,
}

class AcceptedDocument {
  final DocumentType type;
  final bool isPrimaryId;
  final bool requiresPhoto;
  final List<String> requiredFields;
  final List<String> securityFeatures;
  
  const AcceptedDocument({
    required this.type,
    required this.isPrimaryId,
    required this.requiresPhoto,
    required this.requiredFields,
    required this.securityFeatures,
  });
  
  static const primaryDocuments = {
    DocumentType.driversLicense: AcceptedDocument(
      type: DocumentType.driversLicense,
      isPrimaryId: true,
      requiresPhoto: true,
      requiredFields: ['fullName', 'dateOfBirth', 'address', 'expirationDate', 'documentNumber'],
      securityFeatures: ['hologram', 'barcode', 'microprint'],
    ),
    DocumentType.stateId: AcceptedDocument(
      type: DocumentType.stateId,
      isPrimaryId: true,
      requiresPhoto: true,
      requiredFields: ['fullName', 'dateOfBirth', 'address', 'expirationDate', 'documentNumber'],
      securityFeatures: ['hologram', 'barcode'],
    ),
    DocumentType.passport: AcceptedDocument(
      type: DocumentType.passport,
      isPrimaryId: true,
      requiresPhoto: true,
      requiredFields: ['fullName', 'dateOfBirth', 'nationality', 'expirationDate', 'passportNumber'],
      securityFeatures: ['mrz', 'chip', 'watermark'],
    ),
  };
}
```

### 2.2 Document Capture Service

```dart
class DocumentCaptureService {
  final ImagePicker _imagePicker;
  final DocumentValidator _validator;
  
  DocumentCaptureService(this._imagePicker, this._validator);
  
  Future<DocumentCaptureResult> captureDocument({
    required DocumentType documentType,
    required DocumentSide side,
  }) async {
    // Capture image with camera
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 95,
    );
    
    if (image == null) {
      return DocumentCaptureResult.cancelled();
    }
    
    // Validate image quality
    final qualityCheck = await _validateImageQuality(image);
    if (!qualityCheck.isAcceptable) {
      return DocumentCaptureResult.qualityError(qualityCheck.issues);
    }
    
    return DocumentCaptureResult.success(
      imagePath: image.path,
      documentType: documentType,
      side: side,
    );
  }
  
  Future<ImageQualityCheck> _validateImageQuality(XFile image) async {
    final bytes = await image.readAsBytes();
    final decoded = img.decodeImage(bytes);
    
    final issues = <String>[];
    
    // Check resolution
    if (decoded!.width < 640 || decoded.height < 480) {
      issues.add('Image resolution too low');
    }
    
    // Check file size
    if (bytes.length < 50000) {
      issues.add('Image may be too compressed');
    }
    
    // Check blur (would use ML model in production)
    // Check lighting
    // Check glare
    
    return ImageQualityCheck(
      isAcceptable: issues.isEmpty,
      issues: issues,
    );
  }
}

enum DocumentSide { front, back }

class DocumentCaptureResult {
  final bool success;
  final bool cancelled;
  final String? imagePath;
  final DocumentType? documentType;
  final DocumentSide? side;
  final List<String>? errors;
  
  DocumentCaptureResult._({
    required this.success,
    required this.cancelled,
    this.imagePath,
    this.documentType,
    this.side,
    this.errors,
  });
  
  factory DocumentCaptureResult.success({
    required String imagePath,
    required DocumentType documentType,
    required DocumentSide side,
  }) => DocumentCaptureResult._(
    success: true,
    cancelled: false,
    imagePath: imagePath,
    documentType: documentType,
    side: side,
  );
  
  factory DocumentCaptureResult.cancelled() => DocumentCaptureResult._(
    success: false,
    cancelled: true,
  );
  
  factory DocumentCaptureResult.qualityError(List<String> issues) => DocumentCaptureResult._(
    success: false,
    cancelled: false,
    errors: issues,
  );
}
```

### 2.3 Document Verification Provider Integration

```dart
/// Integration with identity verification providers
/// Examples: Jumio, Onfido, Persona, Socure
abstract class IdentityVerificationProvider {
  Future<VerificationSession> createSession({
    required String userId,
    required VerificationMethod method,
  });
  
  Future<VerificationStatus> checkStatus(String sessionId);
  
  Future<IdentityVerificationResult> getResult(String sessionId);
}

class DocumentVerificationService implements IdentityVerificationProvider {
  final String _apiKey;
  final String _baseUrl;
  final http.Client _client;
  
  DocumentVerificationService({
    required String apiKey,
    required String baseUrl,
    http.Client? client,
  }) : _apiKey = apiKey,
       _baseUrl = baseUrl,
       _client = client ?? http.Client();
  
  @override
  Future<VerificationSession> createSession({
    required String userId,
    required VerificationMethod method,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/v1/sessions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'verification_type': method.name,
        'required_documents': _getRequiredDocuments(method),
        'callback_url': 'https://api.yourapp.com/webhooks/identity',
      }),
    );
    
    if (response.statusCode != 201) {
      throw VerificationException('Failed to create session');
    }
    
    final data = jsonDecode(response.body);
    return VerificationSession(
      id: data['session_id'],
      url: data['verification_url'],
      expiresAt: DateTime.parse(data['expires_at']),
    );
  }
  
  List<String> _getRequiredDocuments(VerificationMethod method) {
    return switch (method) {
      VerificationMethod.documentVerification => ['photo_id', 'selfie'],
      VerificationMethod.knowledgeBased => ['ssn_last4'],
      _ => ['photo_id'],
    };
  }
  
  @override
  Future<VerificationStatus> checkStatus(String sessionId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/v1/sessions/$sessionId/status'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );
    
    final data = jsonDecode(response.body);
    return VerificationStatus.values.byName(data['status']);
  }
  
  @override
  Future<IdentityVerificationResult> getResult(String sessionId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/v1/sessions/$sessionId/result'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );
    
    final data = jsonDecode(response.body);
    return IdentityVerificationResult(
      ssnVerified: data['ssn_verified'] ?? false,
      nameVerified: data['name_verified'] ?? false,
      dateOfBirthVerified: data['dob_verified'] ?? false,
      addressVerified: data['address_verified'] ?? false,
      photoIdVerified: data['document_verified'] ?? false,
      selfieMatched: data['selfie_matched'] ?? false,
      confidenceScore: data['confidence_score']?.toDouble(),
      providerResponse: data,
    );
  }
}

class VerificationSession {
  final String id;
  final String url;
  final DateTime expiresAt;
  
  const VerificationSession({
    required this.id,
    required this.url,
    required this.expiresAt,
  });
}
```

---

## 3. SSN Verification

### 3.1 SSN Validation

```dart
class SSNValidator {
  // SSN format validation
  static bool isValidFormat(String ssn) {
    // Remove any formatting
    final cleanSSN = ssn.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Must be exactly 9 digits
    if (cleanSSN.length != 9) return false;
    
    // Cannot be all zeros
    if (cleanSSN == '000000000') return false;
    
    // Area number (first 3 digits) cannot be 000, 666, or 900-999
    final area = int.parse(cleanSSN.substring(0, 3));
    if (area == 0 || area == 666 || area >= 900) return false;
    
    // Group number (middle 2 digits) cannot be 00
    final group = int.parse(cleanSSN.substring(3, 5));
    if (group == 0) return false;
    
    // Serial number (last 4 digits) cannot be 0000
    final serial = int.parse(cleanSSN.substring(5, 9));
    if (serial == 0) return false;
    
    // Check for known invalid SSNs (advertising range)
    if (_isAdvertisingSSN(cleanSSN)) return false;
    
    return true;
  }
  
  // SSNs used in advertisements are invalid
  static bool _isAdvertisingSSN(String ssn) {
    const advertisingSSNs = [
      '078051120', // Wallet insert SSN
      '219099999', // Woolworth wallet insert
    ];
    return advertisingSSNs.contains(ssn);
  }
  
  // Format SSN for display (XXX-XX-XXXX)
  static String format(String ssn) {
    final clean = ssn.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length != 9) return ssn;
    return '${clean.substring(0, 3)}-${clean.substring(3, 5)}-${clean.substring(5)}';
  }
  
  // Mask SSN for display (XXX-XX-1234)
  static String mask(String ssn) {
    final clean = ssn.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length != 9) return '***-**-****';
    return '***-**-${clean.substring(5)}';
  }
}
```

### 3.2 SSN Verification Service

```dart
/// SSN verification against SSA database
/// Typically done through authorized verification services
class SSNVerificationService {
  // IRS TIN Matching Program or similar service
  
  Future<SSNVerificationResult> verifySSN({
    required String ssn,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
  }) async {
    // Validate format first
    if (!SSNValidator.isValidFormat(ssn)) {
      return SSNVerificationResult(
        isValid: false,
        matchStatus: SSNMatchStatus.invalidFormat,
        message: 'SSN format is invalid',
      );
    }
    
    // In production, this would call IRS TIN Matching or SSA verification
    // For demo purposes, showing the expected interface
    
    return SSNVerificationResult(
      isValid: true,
      matchStatus: SSNMatchStatus.match,
      message: 'SSN verified successfully',
    );
  }
}

enum SSNMatchStatus {
  match,              // SSN matches name/DOB
  noMatch,            // SSN exists but doesn't match
  notFound,           // SSN not in database
  invalidFormat,      // SSN format invalid
  unavailable,        // Verification service unavailable
}

class SSNVerificationResult {
  final bool isValid;
  final SSNMatchStatus matchStatus;
  final String message;
  final String? tinMatchCode;  // IRS TIN Match code if applicable
  
  const SSNVerificationResult({
    required this.isValid,
    required this.matchStatus,
    required this.message,
    this.tinMatchCode,
  });
}
```

---

## 4. Knowledge-Based Authentication (KBA)

### 4.1 KBA Question Service

```dart
/// Knowledge-Based Authentication (KBA)
/// Questions derived from credit history and public records
class KBAService {
  final String _providerApiKey;
  
  KBAService(this._providerApiKey);
  
  Future<KBASession> startSession({
    required String ssn,
    required String firstName,
    required String lastName,
    required String address,
    required DateTime dateOfBirth,
  }) async {
    // Provider generates questions based on credit/public records
    // Returns session with questions
    
    return KBASession(
      sessionId: 'kba_session_123',
      questions: [
        KBAQuestion(
          id: 'q1',
          text: 'Which of the following addresses have you been associated with?',
          answers: [
            '123 Main St, Springfield',
            '456 Oak Ave, Riverside',
            '789 Pine Rd, Lakewood',
            'None of the above',
          ],
          timeLimit: Duration(seconds: 60),
        ),
        // Additional questions...
      ],
      timeLimit: Duration(minutes: 5),
      maxAttempts: 3,
    );
  }
  
  Future<KBAResult> submitAnswers({
    required String sessionId,
    required Map<String, String> answers,
  }) async {
    // Submit answers to KBA provider
    // Provider scores responses
    
    return KBAResult(
      passed: true,
      score: 4, // Out of 5 questions
      minimumScore: 3,
    );
  }
}

class KBASession {
  final String sessionId;
  final List<KBAQuestion> questions;
  final Duration timeLimit;
  final int maxAttempts;
  
  const KBASession({
    required this.sessionId,
    required this.questions,
    required this.timeLimit,
    required this.maxAttempts,
  });
}

class KBAQuestion {
  final String id;
  final String text;
  final List<String> answers;
  final Duration timeLimit;
  
  const KBAQuestion({
    required this.id,
    required this.text,
    required this.answers,
    required this.timeLimit,
  });
}

class KBAResult {
  final bool passed;
  final int score;
  final int minimumScore;
  final String? failureReason;
  
  const KBAResult({
    required this.passed,
    required this.score,
    required this.minimumScore,
    this.failureReason,
  });
}
```

---

## 5. Selfie Verification

### 5.1 Liveness Detection

```dart
class LivenessDetectionService {
  Future<LivenessResult> performLivenessCheck() async {
    // Capture video or series of images
    // Detect face movements to confirm live person
    
    final challenges = [
      LivenessChallenge.turnLeft,
      LivenessChallenge.turnRight,
      LivenessChallenge.smile,
      LivenessChallenge.blink,
    ];
    
    // Return result
    return LivenessResult(
      isLive: true,
      confidenceScore: 0.95,
      completedChallenges: challenges,
    );
  }
}

enum LivenessChallenge {
  turnLeft,
  turnRight,
  smile,
  blink,
  nod,
}

class LivenessResult {
  final bool isLive;
  final double confidenceScore;
  final List<LivenessChallenge> completedChallenges;
  final String? errorMessage;
  
  const LivenessResult({
    required this.isLive,
    required this.confidenceScore,
    required this.completedChallenges,
    this.errorMessage,
  });
}
```

### 5.2 Face Matching

```dart
class FaceMatchingService {
  Future<FaceMatchResult> matchSelfieToDocument({
    required String selfieImagePath,
    required String documentImagePath,
  }) async {
    // Use ML model to compare faces
    // Return match confidence
    
    return FaceMatchResult(
      isMatch: true,
      confidenceScore: 0.92,
      threshold: 0.80, // Minimum required confidence
    );
  }
}

class FaceMatchResult {
  final bool isMatch;
  final double confidenceScore;
  final double threshold;
  
  const FaceMatchResult({
    required this.isMatch,
    required this.confidenceScore,
    required this.threshold,
  });
  
  bool get meetsThreshold => confidenceScore >= threshold;
}
```

---

## 6. Identity Verification Flow

### 6.1 Verification Controller

```dart
class IdentityVerificationController extends GetxController {
  final DocumentCaptureService _documentService;
  final DocumentVerificationService _verificationService;
  final LivenessDetectionService _livenessService;
  final FaceMatchingService _faceMatchService;
  final SupabaseClient _supabase;
  
  // State
  final currentStep = VerificationStep.selectDocument.obs;
  final selectedDocumentType = Rx<DocumentType?>(null);
  final frontImagePath = Rx<String?>(null);
  final backImagePath = Rx<String?>(null);
  final selfieImagePath = Rx<String?>(null);
  final verificationStatus = VerificationStatus.pending.obs;
  final verificationResult = Rx<IdentityVerificationResult?>(null);
  
  IdentityVerificationController(
    this._documentService,
    this._verificationService,
    this._livenessService,
    this._faceMatchService,
    this._supabase,
  );
  
  Future<void> selectDocumentType(DocumentType type) async {
    selectedDocumentType.value = type;
    currentStep.value = VerificationStep.captureFront;
  }
  
  Future<void> captureDocumentFront() async {
    final result = await _documentService.captureDocument(
      documentType: selectedDocumentType.value!,
      side: DocumentSide.front,
    );
    
    if (result.success) {
      frontImagePath.value = result.imagePath;
      
      // Some documents need back capture
      if (_requiresBackCapture(selectedDocumentType.value!)) {
        currentStep.value = VerificationStep.captureBack;
      } else {
        currentStep.value = VerificationStep.captureSelfie;
      }
    }
  }
  
  Future<void> captureDocumentBack() async {
    final result = await _documentService.captureDocument(
      documentType: selectedDocumentType.value!,
      side: DocumentSide.back,
    );
    
    if (result.success) {
      backImagePath.value = result.imagePath;
      currentStep.value = VerificationStep.captureSelfie;
    }
  }
  
  Future<void> captureSelfie() async {
    // Perform liveness check
    final livenessResult = await _livenessService.performLivenessCheck();
    
    if (!livenessResult.isLive) {
      Get.snackbar('Error', 'Liveness check failed. Please try again.');
      return;
    }
    
    // Capture selfie
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    
    if (image != null) {
      selfieImagePath.value = image.path;
      currentStep.value = VerificationStep.processing;
      await _submitForVerification();
    }
  }
  
  Future<void> _submitForVerification() async {
    verificationStatus.value = VerificationStatus.inProgress;
    
    try {
      // Create verification session
      final session = await _verificationService.createSession(
        userId: _supabase.auth.currentUser!.id,
        method: VerificationMethod.documentVerification,
      );
      
      // Upload documents to verification provider
      await _uploadDocuments(session.id);
      
      // Poll for result
      await _waitForResult(session.id);
      
    } catch (e) {
      verificationStatus.value = VerificationStatus.failed;
      Get.snackbar('Error', 'Verification failed: $e');
    }
  }
  
  Future<void> _waitForResult(String sessionId) async {
    const maxAttempts = 60;
    const pollInterval = Duration(seconds: 5);
    
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(pollInterval);
      
      final status = await _verificationService.checkStatus(sessionId);
      
      if (status == VerificationStatus.verified ||
          status == VerificationStatus.failed) {
        verificationStatus.value = status;
        
        if (status == VerificationStatus.verified) {
          verificationResult.value = await _verificationService.getResult(sessionId);
          currentStep.value = VerificationStep.complete;
          await _saveVerificationResult(sessionId);
        } else {
          currentStep.value = VerificationStep.failed;
        }
        return;
      }
    }
    
    // Timeout
    verificationStatus.value = VerificationStatus.failed;
    currentStep.value = VerificationStep.failed;
  }
  
  Future<void> _saveVerificationResult(String sessionId) async {
    await _supabase.from('identity_verifications').insert({
      'user_id': _supabase.auth.currentUser!.id,
      'verification_method': VerificationMethod.documentVerification.name,
      'verification_status': verificationStatus.value.name,
      'provider_session_id': sessionId,
      'verified_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(IdentityVerification.verificationValidityPeriod).toIso8601String(),
      'result': verificationResult.value?.providerResponse,
    });
  }
  
  bool _requiresBackCapture(DocumentType type) {
    return type == DocumentType.driversLicense ||
           type == DocumentType.stateId;
  }
}

enum VerificationStep {
  selectDocument,
  captureFront,
  captureBack,
  captureSelfie,
  processing,
  complete,
  failed,
}
```

---

## 7. Verification UI

### 7.1 Identity Verification Screen

```dart
class IdentityVerificationScreen extends GetView<IdentityVerificationController> {
  const IdentityVerificationScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Identity'),
      ),
      body: Obx(() => _buildCurrentStep()),
    );
  }
  
  Widget _buildCurrentStep() {
    return switch (controller.currentStep.value) {
      VerificationStep.selectDocument => _DocumentTypeSelector(controller),
      VerificationStep.captureFront => _DocumentCapture(
        title: 'Capture Front of ID',
        instruction: 'Position the front of your ID within the frame',
        onCapture: controller.captureDocumentFront,
      ),
      VerificationStep.captureBack => _DocumentCapture(
        title: 'Capture Back of ID',
        instruction: 'Position the back of your ID within the frame',
        onCapture: controller.captureDocumentBack,
      ),
      VerificationStep.captureSelfie => _SelfieCapture(controller),
      VerificationStep.processing => _ProcessingScreen(),
      VerificationStep.complete => _VerificationComplete(controller),
      VerificationStep.failed => _VerificationFailed(controller),
    };
  }
}

class _DocumentTypeSelector extends StatelessWidget {
  final IdentityVerificationController controller;
  
  const _DocumentTypeSelector(this.controller);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your ID Type',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a valid government-issued photo ID',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          _DocumentOption(
            icon: Icons.badge,
            title: 'Driver\'s License',
            subtitle: 'US state-issued driver\'s license',
            onTap: () => controller.selectDocumentType(DocumentType.driversLicense),
          ),
          
          const SizedBox(height: 12),
          
          _DocumentOption(
            icon: Icons.credit_card,
            title: 'State ID',
            subtitle: 'US state-issued identification card',
            onTap: () => controller.selectDocumentType(DocumentType.stateId),
          ),
          
          const SizedBox(height: 12),
          
          _DocumentOption(
            icon: Icons.flight,
            title: 'US Passport',
            subtitle: 'Valid US passport',
            onTap: () => controller.selectDocumentType(DocumentType.passport),
          ),
        ],
      ),
    );
  }
}

class _DocumentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _DocumentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
```

---

## 8. Database Schema

```sql
-- Identity Verifications
CREATE TABLE identity_verifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  verification_method TEXT NOT NULL,
  verification_status TEXT NOT NULL DEFAULT 'pending',
  provider_name TEXT,
  provider_session_id TEXT,
  initiated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  result JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Document Images (encrypted references)
CREATE TABLE identity_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  verification_id UUID NOT NULL REFERENCES identity_verifications(id),
  document_type TEXT NOT NULL,
  document_side TEXT NOT NULL,
  storage_path_encrypted BYTEA NOT NULL,
  upload_status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Verification Attempts (for fraud tracking)
CREATE TABLE verification_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  verification_id UUID REFERENCES identity_verifications(id),
  attempt_type TEXT NOT NULL,
  success BOOLEAN NOT NULL,
  failure_reason TEXT,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_identity_verifications_user ON identity_verifications(user_id);
CREATE INDEX idx_identity_verifications_status ON identity_verifications(verification_status);
CREATE INDEX idx_verification_attempts_user ON verification_attempts(user_id);

-- RLS Policies
ALTER TABLE identity_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE identity_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY identity_owner_access ON identity_verifications
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY document_owner_access ON identity_documents
  FOR ALL USING (
    verification_id IN (
      SELECT id FROM identity_verifications WHERE user_id = auth.uid()
    )
  );
```

---

## 9. Implementation Checklist

- [ ] Implement IdentityVerification model
- [ ] Create SSN validation utility
- [ ] Build document capture UI
- [ ] Integrate identity verification provider (Jumio/Onfido/Persona)
- [ ] Implement liveness detection
- [ ] Add face matching for selfie verification
- [ ] Create KBA flow as fallback
- [ ] Build verification status tracking
- [ ] Implement database schema
- [ ] Add verification expiry checking
- [ ] Create audit logging for verification attempts
- [ ] Handle verification failures gracefully

---

## 10. Related Documents

- [Security Compliance](./security_compliance.md)
- [Taxpayer Data](./taxpayer_data.md)
- [Audit Trail](./audit_trail.md)
- [Signature & Consent](./signature_consent.md)
