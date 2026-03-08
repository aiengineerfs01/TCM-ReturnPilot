/// =============================================================================
/// Tax Data Extraction Service
///
/// AI-Powered Tax Data Extractor for Auto-Fill System
///
/// This service parses AI assistant responses and extracted document data
/// to create structured tax data that can be automatically filled into forms.
///
/// Security:
/// - All sensitive data (SSN, EIN, bank info) is encrypted before storage
/// - Data extraction follows IRS compliance guidelines
/// - Audit logging for all data modifications
///
/// Features:
/// - Extracts personal information from conversation
/// - Parses W-2, 1099 data from uploaded documents
/// - Validates extracted data against IRS rules
/// - Converts unstructured AI responses to structured models
/// =============================================================================

import 'dart:convert';
import 'dart:developer';

import 'package:tcm_return_pilot/models/tax/tax_models.dart';
import 'package:tcm_return_pilot/services/security/encryption_service.dart';

/// Enum for extraction source tracking
enum ExtractionSource {
  aiConversation,
  documentUpload,
  manualEntry,
  ocrScan,
  importedData,
}

/// Extraction result container with validation status
class ExtractionResult<T> {
  final T? data;
  final bool success;
  final List<String> errors;
  final List<String> warnings;
  final ExtractionSource source;
  final double confidenceScore; // 0.0 to 1.0
  final Map<String, dynamic>? rawData;

  const ExtractionResult({
    this.data,
    required this.success,
    this.errors = const [],
    this.warnings = const [],
    required this.source,
    this.confidenceScore = 0.0,
    this.rawData,
  });

  factory ExtractionResult.success(T data, ExtractionSource source,
      {double confidence = 1.0, Map<String, dynamic>? rawData}) {
    return ExtractionResult(
      data: data,
      success: true,
      source: source,
      confidenceScore: confidence,
      rawData: rawData,
    );
  }

  factory ExtractionResult.failure(List<String> errors, ExtractionSource source,
      {List<String> warnings = const []}) {
    return ExtractionResult(
      success: false,
      errors: errors,
      warnings: warnings,
      source: source,
    );
  }

  bool get needsReview => confidenceScore < 0.9 || warnings.isNotEmpty;
}

/// Extracted taxpayer data before model conversion
class ExtractedTaxpayerData {
  final String? firstName;
  final String? middleInitial;
  final String? lastName;
  final String? suffix;
  final String? ssn;
  final String? dateOfBirth;
  final String? phone;
  final String? email;
  final String? occupation;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? ipPin;
  final bool isPrimary;

  const ExtractedTaxpayerData({
    this.firstName,
    this.middleInitial,
    this.lastName,
    this.suffix,
    this.ssn,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.occupation,
    this.streetAddress,
    this.city,
    this.state,
    this.zipCode,
    this.ipPin,
    this.isPrimary = true,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'middle_initial': middleInitial,
    'last_name': lastName,
    'suffix': suffix,
    'ssn': ssn,
    'date_of_birth': dateOfBirth,
    'phone': phone,
    'email': email,
    'occupation': occupation,
    'street_address': streetAddress,
    'city': city,
    'state': state,
    'zip_code': zipCode,
    'ip_pin': ipPin,
    'is_primary': isPrimary,
  };

  factory ExtractedTaxpayerData.fromJson(Map<String, dynamic> json) {
    return ExtractedTaxpayerData(
      firstName: json['first_name'] ?? json['firstName'],
      middleInitial: json['middle_initial'] ?? json['middleInitial'],
      lastName: json['last_name'] ?? json['lastName'],
      suffix: json['suffix'],
      ssn: json['ssn'] ?? json['social_security_number'],
      dateOfBirth: json['date_of_birth'] ?? json['dateOfBirth'] ?? json['dob'],
      phone: json['phone'] ?? json['phone_number'],
      email: json['email'] ?? json['email_address'],
      occupation: json['occupation'] ?? json['job_title'],
      streetAddress: json['street_address'] ?? json['address'] ?? json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'] ?? json['zipCode'] ?? json['zip'],
      ipPin: json['ip_pin'] ?? json['identity_protection_pin'],
      isPrimary: json['is_primary'] ?? json['isPrimary'] ?? true,
    );
  }
}

/// Extracted W-2 data from documents
class ExtractedW2Data {
  final String? employerName;
  final String? employerEin;
  final String? employerStreet;
  final String? employerCity;
  final String? employerState;
  final String? employerZip;
  final String? controlNumber;
  final double? box1Wages;
  final double? box2FederalWithheld;
  final double? box3SocialSecurityWages;
  final double? box4SocialSecurityWithheld;
  final double? box5MedicareWages;
  final double? box6MedicareWithheld;
  final double? box7SocialSecurityTips;
  final double? box8AllocatedTips;
  final double? box10DependentCareBenefits;
  final double? box11NonqualifiedPlans;
  final String? box12aCode;
  final double? box12aAmount;
  final String? box12bCode;
  final double? box12bAmount;
  final String? box12cCode;
  final double? box12cAmount;
  final String? box12dCode;
  final double? box12dAmount;
  final bool? box13StatutoryEmployee;
  final bool? box13RetirementPlan;
  final bool? box13ThirdPartySickPay;
  final double? box16StateWages;
  final double? box17StateWithheld;
  final double? box18LocalWages;
  final double? box19LocalWithheld;
  final String? stateCode;
  final String? stateEmployerId;
  final String? locality;

  const ExtractedW2Data({
    this.employerName,
    this.employerEin,
    this.employerStreet,
    this.employerCity,
    this.employerState,
    this.employerZip,
    this.controlNumber,
    this.box1Wages,
    this.box2FederalWithheld,
    this.box3SocialSecurityWages,
    this.box4SocialSecurityWithheld,
    this.box5MedicareWages,
    this.box6MedicareWithheld,
    this.box7SocialSecurityTips,
    this.box8AllocatedTips,
    this.box10DependentCareBenefits,
    this.box11NonqualifiedPlans,
    this.box12aCode,
    this.box12aAmount,
    this.box12bCode,
    this.box12bAmount,
    this.box12cCode,
    this.box12cAmount,
    this.box12dCode,
    this.box12dAmount,
    this.box13StatutoryEmployee,
    this.box13RetirementPlan,
    this.box13ThirdPartySickPay,
    this.box16StateWages,
    this.box17StateWithheld,
    this.box18LocalWages,
    this.box19LocalWithheld,
    this.stateCode,
    this.stateEmployerId,
    this.locality,
  });

  Map<String, dynamic> toJson() => {
    'employer_name': employerName,
    'employer_ein': employerEin,
    'employer_street': employerStreet,
    'employer_city': employerCity,
    'employer_state': employerState,
    'employer_zip': employerZip,
    'control_number': controlNumber,
    'box_1_wages': box1Wages,
    'box_2_federal_withheld': box2FederalWithheld,
    'box_3_social_security_wages': box3SocialSecurityWages,
    'box_4_social_security_withheld': box4SocialSecurityWithheld,
    'box_5_medicare_wages': box5MedicareWages,
    'box_6_medicare_withheld': box6MedicareWithheld,
    'box_7_social_security_tips': box7SocialSecurityTips,
    'box_8_allocated_tips': box8AllocatedTips,
    'box_10_dependent_care': box10DependentCareBenefits,
    'box_11_nonqualified': box11NonqualifiedPlans,
    'box_12a_code': box12aCode,
    'box_12a_amount': box12aAmount,
    'box_12b_code': box12bCode,
    'box_12b_amount': box12bAmount,
    'box_12c_code': box12cCode,
    'box_12c_amount': box12cAmount,
    'box_12d_code': box12dCode,
    'box_12d_amount': box12dAmount,
    'box_13_statutory': box13StatutoryEmployee,
    'box_13_retirement': box13RetirementPlan,
    'box_13_sick_pay': box13ThirdPartySickPay,
    'box_16_state_wages': box16StateWages,
    'box_17_state_withheld': box17StateWithheld,
    'box_18_local_wages': box18LocalWages,
    'box_19_local_withheld': box19LocalWithheld,
    'state_code': stateCode,
    'state_employer_id': stateEmployerId,
    'locality': locality,
  };

  factory ExtractedW2Data.fromJson(Map<String, dynamic> json) {
    return ExtractedW2Data(
      employerName: json['employer_name'] ?? json['employerName'],
      employerEin: json['employer_ein'] ?? json['ein'] ?? json['employerEin'],
      employerStreet: json['employer_street'] ?? json['employerStreet'],
      employerCity: json['employer_city'] ?? json['employerCity'],
      employerState: json['employer_state'] ?? json['employerState'],
      employerZip: json['employer_zip'] ?? json['employerZip'],
      controlNumber: json['control_number'] ?? json['controlNumber'],
      box1Wages: _parseDouble(json['box_1_wages'] ?? json['box1Wages'] ?? json['wages']),
      box2FederalWithheld: _parseDouble(json['box_2_federal_withheld'] ?? json['box2FederalWithheld'] ?? json['federal_withheld']),
      box3SocialSecurityWages: _parseDouble(json['box_3_social_security_wages'] ?? json['box3SocialSecurityWages']),
      box4SocialSecurityWithheld: _parseDouble(json['box_4_social_security_withheld'] ?? json['box4SocialSecurityWithheld']),
      box5MedicareWages: _parseDouble(json['box_5_medicare_wages'] ?? json['box5MedicareWages']),
      box6MedicareWithheld: _parseDouble(json['box_6_medicare_withheld'] ?? json['box6MedicareWithheld']),
      box7SocialSecurityTips: _parseDouble(json['box_7_social_security_tips']),
      box8AllocatedTips: _parseDouble(json['box_8_allocated_tips']),
      box10DependentCareBenefits: _parseDouble(json['box_10_dependent_care']),
      box11NonqualifiedPlans: _parseDouble(json['box_11_nonqualified']),
      box12aCode: json['box_12a_code'],
      box12aAmount: _parseDouble(json['box_12a_amount']),
      box12bCode: json['box_12b_code'],
      box12bAmount: _parseDouble(json['box_12b_amount']),
      box12cCode: json['box_12c_code'],
      box12cAmount: _parseDouble(json['box_12c_amount']),
      box12dCode: json['box_12d_code'],
      box12dAmount: _parseDouble(json['box_12d_amount']),
      box13StatutoryEmployee: json['box_13_statutory'],
      box13RetirementPlan: json['box_13_retirement'],
      box13ThirdPartySickPay: json['box_13_sick_pay'],
      box16StateWages: _parseDouble(json['box_16_state_wages']),
      box17StateWithheld: _parseDouble(json['box_17_state_withheld']),
      box18LocalWages: _parseDouble(json['box_18_local_wages']),
      box19LocalWithheld: _parseDouble(json['box_19_local_withheld']),
      stateCode: json['state_code'] ?? json['state'],
      stateEmployerId: json['state_employer_id'],
      locality: json['locality'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove currency symbols, commas
      final cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleaned);
    }
    return null;
  }
}

/// Extracted 1099 data (generic for all 1099 types)
class Extracted1099Data {
  final String formType; // INT, DIV, NEC, G, R, MISC
  final String? payerName;
  final String? payerTin;
  final String? payerAddress;
  final String? recipientTin;
  final String? recipientName;
  final String? accountNumber;
  final Map<String, double> amounts; // box number -> amount
  final Map<String, String> codes; // box number -> code
  final Map<String, bool> checkboxes; // box number -> checked

  const Extracted1099Data({
    required this.formType,
    this.payerName,
    this.payerTin,
    this.payerAddress,
    this.recipientTin,
    this.recipientName,
    this.accountNumber,
    this.amounts = const {},
    this.codes = const {},
    this.checkboxes = const {},
  });

  Map<String, dynamic> toJson() => {
    'form_type': formType,
    'payer_name': payerName,
    'payer_tin': payerTin,
    'payer_address': payerAddress,
    'recipient_tin': recipientTin,
    'recipient_name': recipientName,
    'account_number': accountNumber,
    'amounts': amounts,
    'codes': codes,
    'checkboxes': checkboxes,
  };

  factory Extracted1099Data.fromJson(Map<String, dynamic> json) {
    return Extracted1099Data(
      formType: json['form_type'] ?? 'UNKNOWN',
      payerName: json['payer_name'],
      payerTin: json['payer_tin'],
      payerAddress: json['payer_address'],
      recipientTin: json['recipient_tin'],
      recipientName: json['recipient_name'],
      accountNumber: json['account_number'],
      amounts: Map<String, double>.from(json['amounts'] ?? {}),
      codes: Map<String, String>.from(json['codes'] ?? {}),
      checkboxes: Map<String, bool>.from(json['checkboxes'] ?? {}),
    );
  }
}

/// Extracted dependent data
class ExtractedDependentData {
  final String? firstName;
  final String? lastName;
  final String? ssn;
  final String? dateOfBirth;
  final String? relationship;
  final int? monthsLivedWithTaxpayer;
  final bool? qualifiesForCtc;
  final bool? qualifiesForOtherDependent;

  const ExtractedDependentData({
    this.firstName,
    this.lastName,
    this.ssn,
    this.dateOfBirth,
    this.relationship,
    this.monthsLivedWithTaxpayer,
    this.qualifiesForCtc,
    this.qualifiesForOtherDependent,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'ssn': ssn,
    'date_of_birth': dateOfBirth,
    'relationship': relationship,
    'months_lived': monthsLivedWithTaxpayer,
    'qualifies_ctc': qualifiesForCtc,
    'qualifies_other': qualifiesForOtherDependent,
  };

  factory ExtractedDependentData.fromJson(Map<String, dynamic> json) {
    return ExtractedDependentData(
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      ssn: json['ssn'],
      dateOfBirth: json['date_of_birth'] ?? json['dateOfBirth'] ?? json['dob'],
      relationship: json['relationship'],
      monthsLivedWithTaxpayer: json['months_lived'] ?? json['monthsLived'] ?? 12,
      qualifiesForCtc: json['qualifies_ctc'] ?? json['qualifiesForCtc'],
      qualifiesForOtherDependent: json['qualifies_other'],
    );
  }
}

/// Main Tax Data Extraction Service
class TaxDataExtractionService {
  final EncryptionService _encryptionService = EncryptionService();

  /// Initialize the service
  Future<TaxDataExtractionService> init() async {
    await _encryptionService.initialize();
    return this;
  }

  // ===========================================================================
  // AI Response Parsing
  // ===========================================================================

  /// Extract structured data from AI assistant response
  /// 
  /// The AI assistant formats data in JSON blocks marked with specific tags.
  /// This method finds and parses those blocks.
  Future<Map<String, dynamic>> parseAIResponse(String response) async {
    final Map<String, dynamic> extractedData = {};

    try {
      // Look for JSON data blocks in the response
      // Format: ```json\n{...}\n``` or [TAX_DATA]{...}[/TAX_DATA]
      
      // Pattern 1: JSON code blocks
      final jsonBlockPattern = RegExp(r'```json\s*([\s\S]*?)\s*```');
      final jsonMatches = jsonBlockPattern.allMatches(response);
      
      for (final match in jsonMatches) {
        try {
          final jsonStr = match.group(1)?.trim() ?? '';
          final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
          extractedData.addAll(parsed);
        } catch (e) {
          log('Failed to parse JSON block: $e');
        }
      }

      // Pattern 2: TAX_DATA tags (custom format from AI)
      final taxDataPattern = RegExp(r'\[TAX_DATA\]([\s\S]*?)\[/TAX_DATA\]');
      final taxDataMatches = taxDataPattern.allMatches(response);
      
      for (final match in taxDataMatches) {
        try {
          final jsonStr = match.group(1)?.trim() ?? '';
          final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
          extractedData.addAll(parsed);
        } catch (e) {
          log('Failed to parse TAX_DATA block: $e');
        }
      }

      // Pattern 3: EXTRACTED_INFO tags
      final extractedInfoPattern = RegExp(r'\[EXTRACTED_INFO\]([\s\S]*?)\[/EXTRACTED_INFO\]');
      final extractedInfoMatches = extractedInfoPattern.allMatches(response);
      
      for (final match in extractedInfoMatches) {
        try {
          final jsonStr = match.group(1)?.trim() ?? '';
          final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
          extractedData.addAll(parsed);
        } catch (e) {
          log('Failed to parse EXTRACTED_INFO block: $e');
        }
      }

    } catch (e) {
      log('Error parsing AI response: $e');
    }

    return extractedData;
  }

  /// Extract filing status from conversation context
  FilingStatus? extractFilingStatus(String conversationText) {
    final lowerText = conversationText.toLowerCase();

    if (lowerText.contains('married filing jointly') ||
        lowerText.contains('filing jointly with spouse') ||
        (lowerText.contains('married') && lowerText.contains('joint'))) {
      return FilingStatus.marriedFilingJointly;
    }

    if (lowerText.contains('married filing separately') ||
        lowerText.contains('married filing separate') ||
        (lowerText.contains('married') && lowerText.contains('separate'))) {
      return FilingStatus.marriedFilingSeparately;
    }

    if (lowerText.contains('head of household') ||
        lowerText.contains('single parent') ||
        lowerText.contains('head-of-household')) {
      return FilingStatus.headOfHousehold;
    }

    if (lowerText.contains('qualifying widow') ||
        lowerText.contains('qualifying surviving spouse') ||
        lowerText.contains('widow(er)')) {
      return FilingStatus.qualifyingWidow;
    }

    if (lowerText.contains('single') ||
        lowerText.contains('unmarried') ||
        lowerText.contains('not married')) {
      return FilingStatus.single;
    }

    return null;
  }

  // ===========================================================================
  // Taxpayer Data Extraction
  // ===========================================================================

  /// Extract taxpayer information from parsed data
  Future<ExtractionResult<ExtractedTaxpayerData>> extractTaxpayerData(
    Map<String, dynamic> data,
    ExtractionSource source,
  ) async {
    try {
      final errors = <String>[];
      final warnings = <String>[];
      double confidence = 1.0;

      // Extract from various possible key names
      final taxpayerData = data['taxpayer'] ?? 
                          data['taxpayer_info'] ?? 
                          data['personal_info'] ?? 
                          data['primary_taxpayer'] ??
                          data;

      if (taxpayerData is! Map<String, dynamic>) {
        return ExtractionResult.failure(
          ['Invalid taxpayer data format'],
          source,
        );
      }

      final extracted = ExtractedTaxpayerData.fromJson(taxpayerData);

      // Validate required fields
      if (extracted.firstName == null || extracted.firstName!.isEmpty) {
        errors.add('First name is required');
        confidence -= 0.2;
      }

      if (extracted.lastName == null || extracted.lastName!.isEmpty) {
        errors.add('Last name is required');
        confidence -= 0.2;
      }

      if (extracted.ssn == null || extracted.ssn!.isEmpty) {
        warnings.add('SSN not provided - will need to be entered manually');
        confidence -= 0.1;
      } else {
        // Validate SSN format
        final cleanedSSN = extracted.ssn!.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanedSSN.length != 9) {
          errors.add('Invalid SSN format');
          confidence -= 0.3;
        }
      }

      if (errors.isNotEmpty && confidence < 0.5) {
        return ExtractionResult.failure(errors, source, warnings: warnings);
      }

      return ExtractionResult(
        data: extracted,
        success: true,
        errors: errors,
        warnings: warnings,
        source: source,
        confidenceScore: confidence.clamp(0.0, 1.0),
        rawData: taxpayerData,
      );
    } catch (e) {
      return ExtractionResult.failure(
        ['Failed to extract taxpayer data: $e'],
        source,
      );
    }
  }

  // ===========================================================================
  // W-2 Data Extraction
  // ===========================================================================

  /// Extract W-2 form data from parsed document/AI response
  Future<ExtractionResult<ExtractedW2Data>> extractW2Data(
    Map<String, dynamic> data,
    ExtractionSource source,
  ) async {
    try {
      final errors = <String>[];
      final warnings = <String>[];
      double confidence = 1.0;

      // Extract from various possible key names
      final w2Data = data['w2'] ?? data['w2_form'] ?? data['w2_data'] ?? data;

      if (w2Data is! Map<String, dynamic>) {
        return ExtractionResult.failure(
          ['Invalid W-2 data format'],
          source,
        );
      }

      final extracted = ExtractedW2Data.fromJson(w2Data);

      // Validate required fields
      if (extracted.employerName == null || extracted.employerName!.isEmpty) {
        warnings.add('Employer name not found');
        confidence -= 0.1;
      }

      if (extracted.employerEin == null || extracted.employerEin!.isEmpty) {
        errors.add('Employer EIN is required');
        confidence -= 0.2;
      } else {
        // Validate EIN format
        final cleanedEIN = extracted.employerEin!.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanedEIN.length != 9) {
          errors.add('Invalid EIN format');
          confidence -= 0.2;
        }
      }

      if (extracted.box1Wages == null) {
        errors.add('Box 1 (Wages) is required');
        confidence -= 0.3;
      }

      // Validate wage consistency
      if (extracted.box1Wages != null && extracted.box3SocialSecurityWages != null) {
        final maxSSWages = 160200.0; // 2023 SS wage base - update yearly
        if (extracted.box3SocialSecurityWages! > maxSSWages) {
          warnings.add('Social Security wages exceed annual limit');
        }
      }

      if (errors.isNotEmpty && confidence < 0.5) {
        return ExtractionResult.failure(errors, source, warnings: warnings);
      }

      return ExtractionResult(
        data: extracted,
        success: true,
        errors: errors,
        warnings: warnings,
        source: source,
        confidenceScore: confidence.clamp(0.0, 1.0),
        rawData: w2Data,
      );
    } catch (e) {
      return ExtractionResult.failure(
        ['Failed to extract W-2 data: $e'],
        source,
      );
    }
  }

  // ===========================================================================
  // 1099 Data Extraction
  // ===========================================================================

  /// Extract 1099 form data
  Future<ExtractionResult<Extracted1099Data>> extract1099Data(
    Map<String, dynamic> data,
    ExtractionSource source,
  ) async {
    try {
      final errors = <String>[];
      final warnings = <String>[];
      double confidence = 1.0;

      final form1099Data = data['1099'] ?? 
                           data['form_1099'] ?? 
                           data['1099_data'] ?? 
                           data;

      if (form1099Data is! Map<String, dynamic>) {
        return ExtractionResult.failure(
          ['Invalid 1099 data format'],
          source,
        );
      }

      final extracted = Extracted1099Data.fromJson(form1099Data);

      // Validate form type
      if (!['INT', 'DIV', 'NEC', 'G', 'R', 'MISC', 'K', 'B'].contains(extracted.formType)) {
        warnings.add('Unknown 1099 form type: ${extracted.formType}');
        confidence -= 0.1;
      }

      // Validate payer info
      if (extracted.payerName == null || extracted.payerName!.isEmpty) {
        warnings.add('Payer name not found');
        confidence -= 0.1;
      }

      if (extracted.payerTin == null || extracted.payerTin!.isEmpty) {
        errors.add('Payer TIN is required');
        confidence -= 0.2;
      }

      // Validate amounts
      if (extracted.amounts.isEmpty) {
        errors.add('No amounts found in 1099 form');
        confidence -= 0.3;
      }

      if (errors.isNotEmpty && confidence < 0.5) {
        return ExtractionResult.failure(errors, source, warnings: warnings);
      }

      return ExtractionResult(
        data: extracted,
        success: true,
        errors: errors,
        warnings: warnings,
        source: source,
        confidenceScore: confidence.clamp(0.0, 1.0),
        rawData: form1099Data,
      );
    } catch (e) {
      return ExtractionResult.failure(
        ['Failed to extract 1099 data: $e'],
        source,
      );
    }
  }

  // ===========================================================================
  // Dependent Data Extraction
  // ===========================================================================

  /// Extract dependent information
  Future<ExtractionResult<List<ExtractedDependentData>>> extractDependentsData(
    Map<String, dynamic> data,
    ExtractionSource source,
  ) async {
    try {
      final errors = <String>[];
      final warnings = <String>[];
      double confidence = 1.0;

      final dependentsData = data['dependents'] ?? 
                            data['dependent_list'] ?? 
                            data['children'] ??
                            [];

      if (dependentsData is! List) {
        return ExtractionResult.failure(
          ['Invalid dependents data format'],
          source,
        );
      }

      final List<ExtractedDependentData> extractedDependents = [];

      for (int i = 0; i < dependentsData.length; i++) {
        final dep = dependentsData[i];
        if (dep is Map<String, dynamic>) {
          final extracted = ExtractedDependentData.fromJson(dep);

          // Validate each dependent
          if (extracted.firstName == null || extracted.firstName!.isEmpty) {
            warnings.add('Dependent ${i + 1}: First name missing');
            confidence -= 0.05;
          }

          if (extracted.ssn == null || extracted.ssn!.isEmpty) {
            warnings.add('Dependent ${i + 1}: SSN missing');
            confidence -= 0.05;
          }

          extractedDependents.add(extracted);
        }
      }

      return ExtractionResult(
        data: extractedDependents,
        success: true,
        errors: errors,
        warnings: warnings,
        source: source,
        confidenceScore: confidence.clamp(0.0, 1.0),
        rawData: {'dependents': dependentsData},
      );
    } catch (e) {
      return ExtractionResult.failure(
        ['Failed to extract dependents data: $e'],
        source,
      );
    }
  }

  // ===========================================================================
  // Model Conversion (Extracted -> Domain Models)
  // ===========================================================================

  /// Convert extracted taxpayer data to TaxpayerInfo model
  Future<TaxpayerInfo?> convertToTaxpayerInfo(
    ExtractedTaxpayerData extracted,
    String returnId,
  ) async {
    try {
      // Parse date of birth
      DateTime? dob;
      if (extracted.dateOfBirth != null) {
        dob = _parseDate(extracted.dateOfBirth!);
      }

      // Create address
      final address = Address(
        street1: extracted.streetAddress ?? '',
        city: extracted.city ?? '',
        state: USState.fromString(extracted.state),
        zipCode: extracted.zipCode ?? '',
        country: 'US',
      );

      // Determine suffix
      NameSuffix? suffix;
      if (extracted.suffix != null) {
        suffix = NameSuffix.values.cast<NameSuffix?>().firstWhere(
          (s) => s?.displayName.toLowerCase() == extracted.suffix!.toLowerCase(),
          orElse: () => null,
        );
      }

      return TaxpayerInfo(
        returnId: returnId,
        taxpayerType: extracted.isPrimary ? TaxpayerType.primary : TaxpayerType.spouse,
        firstName: extracted.firstName ?? '',
        middleInitial: extracted.middleInitial,
        lastName: extracted.lastName ?? '',
        suffix: suffix,
        ssn: extracted.ssn ?? '',
        dateOfBirth: dob ?? DateTime(1970, 1, 1),
        address: address,
        phone: extracted.phone,
        email: extracted.email,
        occupation: extracted.occupation,
        ipPin: extracted.ipPin,
      );
    } catch (e) {
      log('Error converting taxpayer data: $e');
      return null;
    }
  }

  /// Convert extracted W-2 data to W2Form model
  Future<W2Form?> convertToW2Form(
    ExtractedW2Data extracted,
    String returnId,
  ) async {
    try {
      // Create employer address
      final employerAddress = Address(
        street1: extracted.employerStreet ?? '',
        city: extracted.employerCity ?? '',
        state: USState.fromString(extracted.employerState),
        zipCode: extracted.employerZip ?? '',
        country: 'US',
      );

      // Build Box 12 entries list
      final box12Entries = <Box12Entry>[];
      if (extracted.box12aCode != null && extracted.box12aAmount != null) {
        box12Entries.add(Box12Entry(
          code: extracted.box12aCode!,
          amount: extracted.box12aAmount!,
        ));
      }
      if (extracted.box12bCode != null && extracted.box12bAmount != null) {
        box12Entries.add(Box12Entry(
          code: extracted.box12bCode!,
          amount: extracted.box12bAmount!,
        ));
      }
      if (extracted.box12cCode != null && extracted.box12cAmount != null) {
        box12Entries.add(Box12Entry(
          code: extracted.box12cCode!,
          amount: extracted.box12cAmount!,
        ));
      }
      if (extracted.box12dCode != null && extracted.box12dAmount != null) {
        box12Entries.add(Box12Entry(
          code: extracted.box12dCode!,
          amount: extracted.box12dAmount!,
        ));
      }

      return W2Form(
        returnId: returnId,
        employerName: extracted.employerName ?? '',
        employerEin: extracted.employerEin ?? '',
        employerAddress: employerAddress,
        controlNumber: extracted.controlNumber,
        box1Wages: extracted.box1Wages ?? 0,
        box2FederalWithheld: extracted.box2FederalWithheld ?? 0,
        box3SsWages: extracted.box3SocialSecurityWages ?? 0,
        box4SsTax: extracted.box4SocialSecurityWithheld ?? 0,
        box5MedicareWages: extracted.box5MedicareWages ?? 0,
        box6MedicareTax: extracted.box6MedicareWithheld ?? 0,
        box7SsTips: extracted.box7SocialSecurityTips ?? 0,
        box8AllocatedTips: extracted.box8AllocatedTips ?? 0,
        box10DependentCare: extracted.box10DependentCareBenefits ?? 0,
        box11NonqualifiedPlans: extracted.box11NonqualifiedPlans ?? 0,
        box12Entries: box12Entries,
        box13StatutoryEmployee: extracted.box13StatutoryEmployee ?? false,
        box13RetirementPlan: extracted.box13RetirementPlan ?? false,
        box13ThirdPartySickPay: extracted.box13ThirdPartySickPay ?? false,
        stateWages: extracted.box16StateWages,
        stateTaxWithheld: extracted.box17StateWithheld,
        localWages: extracted.box18LocalWages,
        localTaxWithheld: extracted.box19LocalWithheld,
        stateCode: extracted.stateCode,
        stateEmployerId: extracted.stateEmployerId,
        localityName: extracted.locality,
      );
    } catch (e) {
      log('Error converting W-2 data: $e');
      return null;
    }
  }

  /// Convert extracted dependent to Dependent model
  Future<Dependent?> convertToDependent(
    ExtractedDependentData extracted,
    String returnId,
  ) async {
    try {
      DateTime? dob;
      if (extracted.dateOfBirth != null) {
        dob = _parseDate(extracted.dateOfBirth!);
      }

      // Determine relationship
      DependentRelationship relationship = DependentRelationship.son; // default
      if (extracted.relationship != null) {
        final relLower = extracted.relationship!.toLowerCase();
        if (relLower.contains('parent')) {
          relationship = DependentRelationship.parent;
        } else if (relLower.contains('brother')) {
          relationship = DependentRelationship.brother;
        } else if (relLower.contains('sister')) {
          relationship = DependentRelationship.sister;
        } else if (relLower.contains('grandchild')) {
          relationship = DependentRelationship.grandchild;
        } else if (relLower.contains('grandparent')) {
          relationship = DependentRelationship.grandparent;
        } else if (relLower.contains('niece')) {
          relationship = DependentRelationship.niece;
        } else if (relLower.contains('nephew')) {
          relationship = DependentRelationship.nephew;
        } else if (relLower.contains('foster')) {
          relationship = DependentRelationship.fosterChild;
        } else if (relLower.contains('step') && relLower.contains('son')) {
          relationship = DependentRelationship.stepson;
        } else if (relLower.contains('step') && relLower.contains('daughter')) {
          relationship = DependentRelationship.stepdaughter;
        } else if (relLower.contains('daughter')) {
          relationship = DependentRelationship.daughter;
        } else if (relLower.contains('son')) {
          relationship = DependentRelationship.son;
        } else if (relLower.contains('aunt')) {
          relationship = DependentRelationship.aunt;
        } else if (relLower.contains('uncle')) {
          relationship = DependentRelationship.uncle;
        }
      }

      return Dependent(
        returnId: returnId,
        firstName: extracted.firstName ?? '',
        lastName: extracted.lastName ?? '',
        ssn: extracted.ssn ?? '',
        dateOfBirth: dob ?? DateTime.now(),
        relationship: relationship,
        monthsLivedWithTaxpayer: extracted.monthsLivedWithTaxpayer ?? 12,
        qualifiesForCtc: extracted.qualifiesForCtc ?? false,
        qualifiesForOtherDependent: extracted.qualifiesForOtherDependent ?? false,
      );
    } catch (e) {
      log('Error converting dependent data: $e');
      return null;
    }
  }

  // ===========================================================================
  // Utility Methods
  // ===========================================================================

  /// Parse date from various string formats
  DateTime? _parseDate(String dateStr) {
    // Try various date formats
    final formats = [
      RegExp(r'^(\d{4})-(\d{2})-(\d{2})$'), // YYYY-MM-DD
      RegExp(r'^(\d{2})/(\d{2})/(\d{4})$'), // MM/DD/YYYY
      RegExp(r'^(\d{2})-(\d{2})-(\d{4})$'), // MM-DD-YYYY
      RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$'), // M/D/YYYY
    ];

    for (final format in formats) {
      final match = format.firstMatch(dateStr);
      if (match != null) {
        try {
          // Check format type based on number of captures
          if (dateStr.contains('-') && dateStr.indexOf('-') == 4) {
            // YYYY-MM-DD
            return DateTime(
              int.parse(match.group(1)!),
              int.parse(match.group(2)!),
              int.parse(match.group(3)!),
            );
          } else {
            // MM/DD/YYYY or MM-DD-YYYY
            return DateTime(
              int.parse(match.group(3)!),
              int.parse(match.group(1)!),
              int.parse(match.group(2)!),
            );
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Try DateTime.parse as fallback
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// Validate extracted data completeness
  Map<String, bool> validateCompleteness(Map<String, dynamic> extractedData) {
    return {
      'has_taxpayer_info': extractedData.containsKey('taxpayer') || 
                           extractedData.containsKey('personal_info'),
      'has_filing_status': extractedData.containsKey('filing_status'),
      'has_w2_data': extractedData.containsKey('w2') || 
                     extractedData.containsKey('w2_forms'),
      'has_1099_data': extractedData.containsKey('1099') || 
                       extractedData.containsKey('1099_forms'),
      'has_dependents': extractedData.containsKey('dependents'),
      'has_deductions': extractedData.containsKey('deductions'),
      'has_bank_info': extractedData.containsKey('bank_info') || 
                       extractedData.containsKey('refund_info'),
    };
  }
}
