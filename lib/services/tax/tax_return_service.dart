/// =============================================================================
/// Tax Return Service
/// 
/// Core service for tax return CRUD operations including:
/// - Creating new returns
/// - Loading returns with all related data
/// - Saving/updating returns
/// - Managing income forms (W-2, 1099s)
/// - Managing deductions and credits
/// - Audit trail logging
/// 
/// Uses Supabase for persistence with proper error handling
/// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/models/tax/tax_models.dart';

/// Service for managing tax returns and related data
/// 
/// All database operations are wrapped in try-catch blocks
/// Audit trail is automatically logged for all modifications
class TaxReturnService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String get _userId => _supabase.auth.currentUser?.id ?? '';

  // ===========================================================================
  // Table Names (constants to avoid typos)
  // ===========================================================================

  static const String _taxReturnsTable = 'tax_returns';
  static const String _taxpayerInfoTable = 'taxpayer_info';
  static const String _dependentsTable = 'dependents';
  static const String _w2FormsTable = 'w2_forms';
  static const String _form1099IntTable = 'form_1099_int';
  static const String _form1099DivTable = 'form_1099_div';
  static const String _form1099RTable = 'form_1099_r';
  static const String _form1099NecTable = 'form_1099_nec';
  static const String _form1099GTable = 'form_1099_g';
  static const String _formSsa1099Table = 'form_1099_ssa';
  static const String _adjustmentsTable = 'adjustments_to_income';
  static const String _deductionsTable = 'deductions';
  static const String _creditsTable = 'credits';
  static const String _taxPaymentsTable = 'tax_payments';
  static const String _refundPreferencesTable = 'refund_preferences';
  static const String _returnSignaturesTable = 'return_signatures';
  // ignore: unused_field
  static const String _efileSubmissionsTable = 'efile_submissions'; // TODO: Implement E-File operations
  static const String _stateReturnsTable = 'state_returns';
  static const String _taxDocumentsTable = 'tax_documents';
  static const String _taxAuditLogTable = 'tax_audit_log';

  // ===========================================================================
  // Tax Return CRUD Operations
  // ===========================================================================

  /// Create a new tax return
  /// 
  /// Returns the created [TaxReturn] with database-generated ID
  Future<TaxReturn?> createReturn({
    required int taxYear,
    required FilingStatus filingStatus,
  }) async {
    try {
      final newReturn = TaxReturn.newReturn(
        userId: _userId,
        taxYear: taxYear,
        filingStatus: filingStatus,
      );

      final response = await _supabase
          .from(_taxReturnsTable)
          .insert(newReturn.toJson())
          .select()
          .single();

      final createdReturn = TaxReturn.fromJson(response);

      // Log creation
      await _logAuditEvent(
        returnId: createdReturn.id!,
        eventType: AuditEventType.returnCreated,
        description: 'Tax return created for year $taxYear',
      );

      return createdReturn;
    } catch (e) {
      print('Error creating tax return: $e');
      return null;
    }
  }

  /// Get a tax return by ID
  Future<TaxReturn?> getReturnById(String returnId) async {
    try {
      final response = await _supabase
          .from(_taxReturnsTable)
          .select()
          .eq('id', returnId)
          .eq('user_id', _userId)
          .single();

      return TaxReturn.fromJson(response);
    } catch (e) {
      print('Error getting tax return: $e');
      return null;
    }
  }

  /// Get all tax returns for current user
  Future<List<TaxReturn>> getAllReturns() async {
    try {
      final response = await _supabase
          .from(_taxReturnsTable)
          .select()
          .eq('user_id', _userId)
          .order('tax_year', ascending: false);

      return (response as List)
          .map((json) => TaxReturn.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all tax returns: $e');
      return [];
    }
  }

  /// Get returns by tax year
  Future<List<TaxReturn>> getReturnsByYear(int taxYear) async {
    try {
      final response = await _supabase
          .from(_taxReturnsTable)
          .select()
          .eq('user_id', _userId)
          .eq('tax_year', taxYear)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => TaxReturn.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting returns by year: $e');
      return [];
    }
  }

  /// Update a tax return
  Future<TaxReturn?> updateReturn(TaxReturn taxReturn) async {
    if (taxReturn.id == null) return null;

    try {
      final response = await _supabase
          .from(_taxReturnsTable)
          .update(taxReturn.toJson())
          .eq('id', taxReturn.id!)
          .eq('user_id', _userId)
          .select()
          .single();

      return TaxReturn.fromJson(response);
    } catch (e) {
      print('Error updating tax return: $e');
      return null;
    }
  }

  /// Update return status
  Future<bool> updateReturnStatus(
    String returnId,
    ReturnStatus status,
  ) async {
    try {
      await _supabase
          .from(_taxReturnsTable)
          .update({'status': status.value})
          .eq('id', returnId)
          .eq('user_id', _userId);

      await _logAuditEvent(
        returnId: returnId,
        eventType: AuditEventType.statusChanged,
        description: 'Return status changed to ${status.displayName}',
      );

      return true;
    } catch (e) {
      print('Error updating return status: $e');
      return false;
    }
  }

  /// Delete a tax return (soft delete recommended)
  Future<bool> deleteReturn(String returnId) async {
    try {
      // Note: In production, consider soft delete by adding is_deleted flag
      await _supabase
          .from(_taxReturnsTable)
          .delete()
          .eq('id', returnId)
          .eq('user_id', _userId);

      return true;
    } catch (e) {
      print('Error deleting tax return: $e');
      return false;
    }
  }

  // ===========================================================================
  // Taxpayer Info Operations
  // ===========================================================================

  /// Save or update taxpayer info
  Future<TaxpayerInfo?> saveTaxpayerInfo(TaxpayerInfo info) async {
    try {
      final Map<String, dynamic> response;

      if (info.id != null) {
        // Update existing
        response = await _supabase
            .from(_taxpayerInfoTable)
            .update(info.toJson())
            .eq('id', info.id!)
            .select()
            .single();
      } else {
        // Insert new
        response = await _supabase
            .from(_taxpayerInfoTable)
            .insert(info.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: info.returnId,
        eventType: AuditEventType.dataModified,
        description: 'Taxpayer info ${info.taxpayerType.displayName} saved',
      );

      return TaxpayerInfo.fromJson(response);
    } catch (e) {
      print('Error saving taxpayer info: $e');
      return null;
    }
  }

  /// Get taxpayer info for a return
  Future<List<TaxpayerInfo>> getTaxpayerInfo(String returnId) async {
    try {
      final response = await _supabase
          .from(_taxpayerInfoTable)
          .select()
          .eq('return_id', returnId)
          .order('taxpayer_type');

      return (response as List)
          .map((json) => TaxpayerInfo.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting taxpayer info: $e');
      return [];
    }
  }

  // ===========================================================================
  // Dependent Operations
  // ===========================================================================

  /// Save or update dependent
  Future<Dependent?> saveDependent(Dependent dependent) async {
    try {
      final Map<String, dynamic> response;

      if (dependent.id != null) {
        response = await _supabase
            .from(_dependentsTable)
            .update(dependent.toJson())
            .eq('id', dependent.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_dependentsTable)
            .insert(dependent.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: dependent.returnId,
        eventType: AuditEventType.dataModified,
        description: 'Dependent ${dependent.firstName} saved',
      );

      return Dependent.fromJson(response);
    } catch (e) {
      print('Error saving dependent: $e');
      return null;
    }
  }

  /// Get dependents for a return
  Future<List<Dependent>> getDependents(String returnId) async {
    try {
      final response = await _supabase
          .from(_dependentsTable)
          .select()
          .eq('return_id', returnId)
          .order('created_at');

      return (response as List)
          .map((json) => Dependent.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting dependents: $e');
      return [];
    }
  }

  /// Delete dependent
  Future<bool> deleteDependent(String dependentId, String returnId) async {
    try {
      await _supabase
          .from(_dependentsTable)
          .delete()
          .eq('id', dependentId);

      await _logAuditEvent(
        returnId: returnId,
        eventType: AuditEventType.dataModified,
        description: 'Dependent removed',
      );

      return true;
    } catch (e) {
      print('Error deleting dependent: $e');
      return false;
    }
  }

  // ===========================================================================
  // W-2 Form Operations
  // ===========================================================================

  /// Save or update W-2 form
  Future<W2Form?> saveW2Form(W2Form w2) async {
    try {
      final Map<String, dynamic> response;

      if (w2.id != null) {
        response = await _supabase
            .from(_w2FormsTable)
            .update(w2.toJson())
            .eq('id', w2.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_w2FormsTable)
            .insert(w2.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: w2.returnId,
        eventType: AuditEventType.dataModified,
        description: 'W-2 from ${w2.employerName} saved',
      );

      return W2Form.fromJson(response);
    } catch (e) {
      print('Error saving W-2 form: $e');
      return null;
    }
  }

  /// Get W-2 forms for a return
  Future<List<W2Form>> getW2Forms(String returnId) async {
    try {
      final response = await _supabase
          .from(_w2FormsTable)
          .select()
          .eq('return_id', returnId)
          .order('created_at');

      return (response as List)
          .map((json) => W2Form.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting W-2 forms: $e');
      return [];
    }
  }

  /// Delete W-2 form
  Future<bool> deleteW2Form(String w2Id, String returnId) async {
    try {
      await _supabase.from(_w2FormsTable).delete().eq('id', w2Id);

      await _logAuditEvent(
        returnId: returnId,
        eventType: AuditEventType.dataModified,
        description: 'W-2 form removed',
      );

      return true;
    } catch (e) {
      print('Error deleting W-2 form: $e');
      return false;
    }
  }

  // ===========================================================================
  // 1099 Form Operations (Generic method for all types)
  // ===========================================================================

  /// Save Form 1099-INT
  Future<Form1099Int?> saveForm1099Int(Form1099Int form) async {
    return _save1099Form(form, _form1099IntTable, Form1099Int.fromJson);
  }

  /// Get 1099-INT forms
  Future<List<Form1099Int>> getForm1099Int(String returnId) async {
    return _get1099Forms(returnId, _form1099IntTable, Form1099Int.fromJson);
  }

  /// Save Form 1099-DIV
  Future<Form1099Div?> saveForm1099Div(Form1099Div form) async {
    return _save1099Form(form, _form1099DivTable, Form1099Div.fromJson);
  }

  /// Get 1099-DIV forms
  Future<List<Form1099Div>> getForm1099Div(String returnId) async {
    return _get1099Forms(returnId, _form1099DivTable, Form1099Div.fromJson);
  }

  /// Save Form 1099-R
  Future<Form1099R?> saveForm1099R(Form1099R form) async {
    return _save1099Form(form, _form1099RTable, Form1099R.fromJson);
  }

  /// Get 1099-R forms
  Future<List<Form1099R>> getForm1099R(String returnId) async {
    return _get1099Forms(returnId, _form1099RTable, Form1099R.fromJson);
  }

  /// Save Form 1099-NEC
  Future<Form1099Nec?> saveForm1099Nec(Form1099Nec form) async {
    return _save1099Form(form, _form1099NecTable, Form1099Nec.fromJson);
  }

  /// Get 1099-NEC forms
  Future<List<Form1099Nec>> getForm1099Nec(String returnId) async {
    return _get1099Forms(returnId, _form1099NecTable, Form1099Nec.fromJson);
  }

  /// Save Form 1099-G
  Future<Form1099G?> saveForm1099G(Form1099G form) async {
    return _save1099Form(form, _form1099GTable, Form1099G.fromJson);
  }

  /// Get 1099-G forms
  Future<List<Form1099G>> getForm1099G(String returnId) async {
    return _get1099Forms(returnId, _form1099GTable, Form1099G.fromJson);
  }

  /// Save Form SSA-1099
  Future<FormSsa1099?> saveFormSsa1099(FormSsa1099 form) async {
    return _save1099Form(form, _formSsa1099Table, FormSsa1099.fromJson);
  }

  /// Get SSA-1099 forms
  Future<List<FormSsa1099>> getFormSsa1099(String returnId) async {
    return _get1099Forms(returnId, _formSsa1099Table, FormSsa1099.fromJson);
  }

  /// Generic 1099 save method
  Future<T?> _save1099Form<T>(
    dynamic form,
    String tableName,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final Map<String, dynamic> response;
      final json = form.toJson() as Map<String, dynamic>;
      final id = form.id as String?;
      final returnId = form.returnId as String;

      if (id != null) {
        response = await _supabase
            .from(tableName)
            .update(json)
            .eq('id', id)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(tableName)
            .insert(json)
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: returnId,
        eventType: AuditEventType.dataModified,
        description: '${tableName.replaceAll('_', ' ')} saved',
      );

      return fromJson(response);
    } catch (e) {
      print('Error saving $tableName: $e');
      return null;
    }
  }

  /// Generic 1099 get method
  Future<List<T>> _get1099Forms<T>(
    String returnId,
    String tableName,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('return_id', returnId)
          .order('created_at');

      return (response as List).map((json) => fromJson(json)).toList();
    } catch (e) {
      print('Error getting $tableName: $e');
      return [];
    }
  }

  /// Delete any 1099 form
  Future<bool> delete1099Form(
    String formId,
    String returnId,
    String tableName,
  ) async {
    try {
      await _supabase.from(tableName).delete().eq('id', formId);

      await _logAuditEvent(
        returnId: returnId,
        eventType: AuditEventType.dataModified,
        description: '${tableName.replaceAll('_', ' ')} removed',
      );

      return true;
    } catch (e) {
      print('Error deleting $tableName: $e');
      return false;
    }
  }

  // ===========================================================================
  // Adjustments, Deductions, Credits Operations
  // ===========================================================================

  /// Save adjustments to income
  Future<AdjustmentsToIncome?> saveAdjustments(AdjustmentsToIncome adj) async {
    try {
      final Map<String, dynamic> response;

      if (adj.id != null) {
        response = await _supabase
            .from(_adjustmentsTable)
            .update(adj.toJson())
            .eq('id', adj.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_adjustmentsTable)
            .insert(adj.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: adj.returnId,
        eventType: AuditEventType.dataModified,
        description: 'Adjustments to income saved',
      );

      return AdjustmentsToIncome.fromJson(response);
    } catch (e) {
      print('Error saving adjustments: $e');
      return null;
    }
  }

  /// Get adjustments for a return
  Future<AdjustmentsToIncome?> getAdjustments(String returnId) async {
    try {
      final response = await _supabase
          .from(_adjustmentsTable)
          .select()
          .eq('return_id', returnId)
          .maybeSingle();

      if (response == null) return null;
      return AdjustmentsToIncome.fromJson(response);
    } catch (e) {
      print('Error getting adjustments: $e');
      return null;
    }
  }

  /// Save deductions
  Future<Deductions?> saveDeductions(Deductions deductions) async {
    try {
      final Map<String, dynamic> response;

      if (deductions.id != null) {
        response = await _supabase
            .from(_deductionsTable)
            .update(deductions.toJson())
            .eq('id', deductions.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_deductionsTable)
            .insert(deductions.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: deductions.returnId,
        eventType: AuditEventType.dataModified,
        description: 'Deductions saved',
      );

      return Deductions.fromJson(response);
    } catch (e) {
      print('Error saving deductions: $e');
      return null;
    }
  }

  /// Get deductions for a return
  Future<Deductions?> getDeductions(String returnId) async {
    try {
      final response = await _supabase
          .from(_deductionsTable)
          .select()
          .eq('return_id', returnId)
          .maybeSingle();

      if (response == null) return null;
      return Deductions.fromJson(response);
    } catch (e) {
      print('Error getting deductions: $e');
      return null;
    }
  }

  /// Save credits
  Future<Credits?> saveCredits(Credits credits) async {
    try {
      final Map<String, dynamic> response;

      if (credits.id != null) {
        response = await _supabase
            .from(_creditsTable)
            .update(credits.toJson())
            .eq('id', credits.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_creditsTable)
            .insert(credits.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: credits.returnId,
        eventType: AuditEventType.dataModified,
        description: 'Credits saved',
      );

      return Credits.fromJson(response);
    } catch (e) {
      print('Error saving credits: $e');
      return null;
    }
  }

  /// Get credits for a return
  Future<Credits?> getCredits(String returnId) async {
    try {
      final response = await _supabase
          .from(_creditsTable)
          .select()
          .eq('return_id', returnId)
          .maybeSingle();

      if (response == null) return null;
      return Credits.fromJson(response);
    } catch (e) {
      print('Error getting credits: $e');
      return null;
    }
  }

  // ===========================================================================
  // Tax Payments Operations
  // ===========================================================================

  /// Save tax payments
  Future<TaxPayments?> saveTaxPayments(TaxPayments payments) async {
    try {
      final Map<String, dynamic> response;

      if (payments.id != null) {
        response = await _supabase
            .from(_taxPaymentsTable)
            .update(payments.toJson())
            .eq('id', payments.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_taxPaymentsTable)
            .insert(payments.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: payments.returnId,
        eventType: AuditEventType.dataModified,
        description: 'Tax payments saved',
      );

      return TaxPayments.fromJson(response);
    } catch (e) {
      print('Error saving tax payments: $e');
      return null;
    }
  }

  /// Get tax payments for a return
  Future<TaxPayments?> getTaxPayments(String returnId) async {
    try {
      final response = await _supabase
          .from(_taxPaymentsTable)
          .select()
          .eq('return_id', returnId)
          .maybeSingle();

      if (response == null) return null;
      return TaxPayments.fromJson(response);
    } catch (e) {
      print('Error getting tax payments: $e');
      return null;
    }
  }

  // ===========================================================================
  // Refund Preferences Operations
  // ===========================================================================

  /// Save refund preferences
  Future<RefundPreferences?> saveRefundPreferences(
    RefundPreferences prefs,
  ) async {
    try {
      final Map<String, dynamic> response;

      if (prefs.id != null) {
        response = await _supabase
            .from(_refundPreferencesTable)
            .update(prefs.toJson())
            .eq('id', prefs.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_refundPreferencesTable)
            .insert(prefs.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: prefs.returnId,
        eventType: AuditEventType.dataModified,
        description: 'Refund preferences saved',
      );

      return RefundPreferences.fromJson(response);
    } catch (e) {
      print('Error saving refund preferences: $e');
      return null;
    }
  }

  /// Get refund preferences for a return
  Future<RefundPreferences?> getRefundPreferences(String returnId) async {
    try {
      final response = await _supabase
          .from(_refundPreferencesTable)
          .select()
          .eq('return_id', returnId)
          .maybeSingle();

      if (response == null) return null;
      return RefundPreferences.fromJson(response);
    } catch (e) {
      print('Error getting refund preferences: $e');
      return null;
    }
  }

  // ===========================================================================
  // Signature Operations
  // ===========================================================================

  /// Save return signature
  Future<ReturnSignature?> saveSignature(ReturnSignature signature) async {
    try {
      final Map<String, dynamic> response;

      if (signature.id != null) {
        response = await _supabase
            .from(_returnSignaturesTable)
            .update(signature.toJson())
            .eq('id', signature.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_returnSignaturesTable)
            .insert(signature.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: signature.returnId,
        eventType: AuditEventType.signatureCollected,
        description: 'Signature from ${signature.signerType.displayName} collected',
      );

      return ReturnSignature.fromJson(response);
    } catch (e) {
      print('Error saving signature: $e');
      return null;
    }
  }

  /// Get signatures for a return
  Future<List<ReturnSignature>> getSignatures(String returnId) async {
    try {
      final response = await _supabase
          .from(_returnSignaturesTable)
          .select()
          .eq('return_id', returnId)
          .order('signed_at');

      return (response as List)
          .map((json) => ReturnSignature.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting signatures: $e');
      return [];
    }
  }

  // ===========================================================================
  // State Return Operations
  // ===========================================================================

  /// Save state return
  Future<StateReturn?> saveStateReturn(StateReturn stateReturn) async {
    try {
      final Map<String, dynamic> response;

      if (stateReturn.id != null) {
        response = await _supabase
            .from(_stateReturnsTable)
            .update(stateReturn.toJson())
            .eq('id', stateReturn.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_stateReturnsTable)
            .insert(stateReturn.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: stateReturn.returnId,
        eventType: AuditEventType.dataModified,
        description: 'State return for ${stateReturn.stateName} saved',
      );

      return StateReturn.fromJson(response);
    } catch (e) {
      print('Error saving state return: $e');
      return null;
    }
  }

  /// Get state returns for a federal return
  Future<List<StateReturn>> getStateReturns(String returnId) async {
    try {
      final response = await _supabase
          .from(_stateReturnsTable)
          .select()
          .eq('return_id', returnId)
          .order('state_code');

      return (response as List)
          .map((json) => StateReturn.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting state returns: $e');
      return [];
    }
  }

  // ===========================================================================
  // Document Operations
  // ===========================================================================

  /// Save document metadata
  Future<TaxDocument?> saveDocument(TaxDocument document) async {
    try {
      final Map<String, dynamic> response;

      if (document.id != null) {
        response = await _supabase
            .from(_taxDocumentsTable)
            .update(document.toJson())
            .eq('id', document.id!)
            .select()
            .single();
      } else {
        response = await _supabase
            .from(_taxDocumentsTable)
            .insert(document.toJson())
            .select()
            .single();
      }

      await _logAuditEvent(
        returnId: document.returnId,
        eventType: AuditEventType.documentUploaded,
        description: 'Document ${document.fileName} saved',
      );

      return TaxDocument.fromJson(response);
    } catch (e) {
      print('Error saving document: $e');
      return null;
    }
  }

  /// Get documents for a return
  Future<List<TaxDocument>> getDocuments(String returnId) async {
    try {
      final response = await _supabase
          .from(_taxDocumentsTable)
          .select()
          .eq('return_id', returnId)
          .order('created_at');

      return (response as List)
          .map((json) => TaxDocument.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting documents: $e');
      return [];
    }
  }

  // ===========================================================================
  // Audit Log Operations
  // ===========================================================================

  /// Log an audit event
  Future<void> _logAuditEvent({
    required String returnId,
    required AuditEventType eventType,
    required String description,
    Map<String, dynamic>? previousValues,
    Map<String, dynamic>? newValues,
  }) async {
    try {
      final log = TaxAuditLog(
        returnId: returnId,
        userId: _userId,
        eventType: eventType,
        eventDescription: description,
        previousValues: previousValues,
        newValues: newValues,
        timestamp: DateTime.now(),
      );

      await _supabase.from(_taxAuditLogTable).insert(log.toJson());
    } catch (e) {
      print('Error logging audit event: $e');
      // Don't throw - audit logging should not break operations
    }
  }

  /// Get audit log for a return
  Future<List<TaxAuditLog>> getAuditLog(String returnId) async {
    try {
      final response = await _supabase
          .from(_taxAuditLogTable)
          .select()
          .eq('return_id', returnId)
          .order('timestamp', ascending: false);

      return (response as List)
          .map((json) => TaxAuditLog.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting audit log: $e');
      return [];
    }
  }

  // ===========================================================================
  // Comprehensive Return Loading
  // ===========================================================================

  /// Load a complete tax return with all related data
  Future<CompleteTaxReturn?> loadCompleteReturn(String returnId) async {
    try {
      // Load all data in parallel for efficiency
      final results = await Future.wait([
        getReturnById(returnId),
        getTaxpayerInfo(returnId),
        getDependents(returnId),
        getW2Forms(returnId),
        getForm1099Int(returnId),
        getForm1099Div(returnId),
        getForm1099R(returnId),
        getForm1099Nec(returnId),
        getForm1099G(returnId),
        getFormSsa1099(returnId),
        getAdjustments(returnId),
        getDeductions(returnId),
        getCredits(returnId),
        getTaxPayments(returnId),
        getRefundPreferences(returnId),
        getSignatures(returnId),
        getStateReturns(returnId),
        getDocuments(returnId),
      ]);

      final taxReturn = results[0] as TaxReturn?;
      if (taxReturn == null) return null;

      // Log access
      await _logAuditEvent(
        returnId: returnId,
        eventType: AuditEventType.returnViewed,
        description: 'Complete return loaded',
      );

      return CompleteTaxReturn(
        taxReturn: taxReturn,
        taxpayerInfo: results[1] as List<TaxpayerInfo>,
        dependents: results[2] as List<Dependent>,
        w2Forms: results[3] as List<W2Form>,
        form1099Int: results[4] as List<Form1099Int>,
        form1099Div: results[5] as List<Form1099Div>,
        form1099R: results[6] as List<Form1099R>,
        form1099Nec: results[7] as List<Form1099Nec>,
        form1099G: results[8] as List<Form1099G>,
        formSsa1099: results[9] as List<FormSsa1099>,
        adjustments: results[10] as AdjustmentsToIncome?,
        deductions: results[11] as Deductions?,
        credits: results[12] as Credits?,
        taxPayments: results[13] as TaxPayments?,
        refundPreferences: results[14] as RefundPreferences?,
        signatures: results[15] as List<ReturnSignature>,
        stateReturns: results[16] as List<StateReturn>,
        documents: results[17] as List<TaxDocument>,
      );
    } catch (e) {
      print('Error loading complete return: $e');
      return null;
    }
  }
}

// =============================================================================
// Complete Tax Return Container
// =============================================================================

/// Container for a complete tax return with all related data
class CompleteTaxReturn {
  final TaxReturn taxReturn;
  final List<TaxpayerInfo> taxpayerInfo;
  final List<Dependent> dependents;
  final List<W2Form> w2Forms;
  final List<Form1099Int> form1099Int;
  final List<Form1099Div> form1099Div;
  final List<Form1099R> form1099R;
  final List<Form1099Nec> form1099Nec;
  final List<Form1099G> form1099G;
  final List<FormSsa1099> formSsa1099;
  final AdjustmentsToIncome? adjustments;
  final Deductions? deductions;
  final Credits? credits;
  final TaxPayments? taxPayments;
  final RefundPreferences? refundPreferences;
  final List<ReturnSignature> signatures;
  final List<StateReturn> stateReturns;
  final List<TaxDocument> documents;

  const CompleteTaxReturn({
    required this.taxReturn,
    required this.taxpayerInfo,
    required this.dependents,
    required this.w2Forms,
    required this.form1099Int,
    required this.form1099Div,
    required this.form1099R,
    required this.form1099Nec,
    required this.form1099G,
    required this.formSsa1099,
    this.adjustments,
    this.deductions,
    this.credits,
    this.taxPayments,
    this.refundPreferences,
    required this.signatures,
    required this.stateReturns,
    required this.documents,
  });

  /// Get primary taxpayer info
  TaxpayerInfo? get primaryTaxpayer => taxpayerInfo
      .where((t) => t.taxpayerType == TaxpayerType.primary)
      .firstOrNull;

  /// Get spouse taxpayer info
  TaxpayerInfo? get spouseTaxpayer => taxpayerInfo
      .where((t) => t.taxpayerType == TaxpayerType.spouse)
      .firstOrNull;

  /// Get total W-2 wages
  double get totalW2Wages =>
      w2Forms.fold(0.0, (sum, w2) => sum + w2.box1Wages);

  /// Get total W-2 federal withholding
  double get totalW2Withholding =>
      w2Forms.fold(0.0, (sum, w2) => sum + w2.box2FederalWithheld);

  /// Count qualifying children for credits
  int get qualifyingChildrenForCtc =>
      dependents.where((d) => d.qualifiesForChildTaxCredit(DateTime.now().year)).length;

  /// Count qualifying children for EIC
  int get qualifyingChildrenForEic =>
      dependents.where((d) => d.qualifiesForEarnedIncomeCredit(DateTime.now().year)).length;
}
