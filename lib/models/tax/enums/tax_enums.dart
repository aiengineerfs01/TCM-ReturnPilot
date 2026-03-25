/// =============================================================================
/// Tax Compliance Enums
/// 
/// This file contains all enumeration types used throughout the tax compliance
/// module. Each enum follows IRS specifications and includes helper methods
/// for serialization/deserialization and display formatting.
/// =============================================================================

// -----------------------------------------------------------------------------
// FILING STATUS
// IRS filing statuses as defined on Form 1040
// -----------------------------------------------------------------------------

/// Filing status determines tax brackets, standard deduction, and credit eligibility
enum FilingStatus {
  /// Single - Unmarried or legally separated
  single('single', 'Single'),

  /// Married Filing Jointly - Married couples filing together
  marriedFilingJointly('married_filing_jointly', 'Married Filing Jointly'),

  /// Married Filing Separately - Married couples filing separate returns
  marriedFilingSeparately('married_filing_separately', 'Married Filing Separately'),

  /// Head of Household - Unmarried with qualifying dependent
  headOfHousehold('head_of_household', 'Head of Household'),

  /// Qualifying Widow(er) - Surviving spouse with dependent child (2 years after spouse's death)
  qualifyingWidow('qualifying_widow', 'Qualifying Surviving Spouse');

  /// Database value (snake_case for Supabase)
  final String value;

  /// Human-readable display name
  final String displayName;

  const FilingStatus(this.value, this.displayName);

  /// Convert from database string to enum
  static FilingStatus fromString(String? value) {
    return FilingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FilingStatus.single,
    );
  }

  /// Get 2024 standard deduction amount for this filing status
  double get standardDeduction2024 {
    switch (this) {
      case FilingStatus.single:
        return 14600;
      case FilingStatus.marriedFilingJointly:
      case FilingStatus.qualifyingWidow:
        return 29200;
      case FilingStatus.marriedFilingSeparately:
        return 14600;
      case FilingStatus.headOfHousehold:
        return 21900;
    }
  }
}

// -----------------------------------------------------------------------------
// RETURN STATUS
// Tracks the lifecycle of a tax return from creation to acceptance
// -----------------------------------------------------------------------------

/// Status progression of a tax return through the filing process
enum ReturnStatus {
  /// Initial draft state
  draft('draft', 'Draft'),

  /// Just created, no data entered
  notStarted('not_started', 'Not Started'),

  /// User is actively entering data
  inProgress('in_progress', 'In Progress'),

  /// All required data entered, ready for review
  readyForReview('ready_for_review', 'Ready for Review'),

  /// Reviewed and ready to submit to IRS
  readyToFile('ready_to_file', 'Ready to File'),

  /// Submitted to IRS, awaiting acknowledgment
  submitted('submitted', 'Submitted'),

  /// IRS accepted the return
  accepted('accepted', 'Accepted'),

  /// IRS rejected the return (needs correction)
  rejected('rejected', 'Rejected'),

  /// Amended return (Form 1040-X)
  amended('amended', 'Amended');

  final String value;
  final String displayName;

  const ReturnStatus(this.value, this.displayName);

  static ReturnStatus fromString(String? value) {
    return ReturnStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReturnStatus.draft,
    );
  }

  /// Check if return can be edited
  bool get isEditable =>
      this == draft || this == notStarted || this == inProgress || this == rejected;

  /// Check if return has been submitted
  bool get isSubmitted =>
      this == submitted || this == accepted || this == rejected;
}

// -----------------------------------------------------------------------------
// TAXPAYER TYPE
// Distinguishes between primary taxpayer and spouse
// -----------------------------------------------------------------------------

/// Type of taxpayer on a return
enum TaxpayerType {
  /// Primary taxpayer (always required)
  primary('primary', 'Primary Taxpayer'),

  /// Spouse (required for MFJ filing status)
  spouse('spouse', 'Spouse');

  final String value;
  final String displayName;

  const TaxpayerType(this.value, this.displayName);

  static TaxpayerType fromString(String? value) {
    return TaxpayerType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaxpayerType.primary,
    );
  }
}

// -----------------------------------------------------------------------------
// DEPENDENT RELATIONSHIP
// IRS-defined relationships for claiming dependents
// -----------------------------------------------------------------------------

/// Relationship of dependent to taxpayer
enum DependentRelationship {
  // Children
  son('son', 'Son'),
  daughter('daughter', 'Daughter'),
  stepson('stepson', 'Stepson'),
  stepdaughter('stepdaughter', 'Stepdaughter'),
  fosterChild('foster_child', 'Foster Child'),

  // Siblings
  brother('brother', 'Brother'),
  sister('sister', 'Sister'),
  halfBrother('half_brother', 'Half Brother'),
  halfSister('half_sister', 'Half Sister'),
  stepbrother('stepbrother', 'Stepbrother'),
  stepsister('stepsister', 'Stepsister'),

  // Extended Family
  grandchild('grandchild', 'Grandchild'),
  niece('niece', 'Niece'),
  nephew('nephew', 'Nephew'),
  parent('parent', 'Parent'),
  grandparent('grandparent', 'Grandparent'),
  aunt('aunt', 'Aunt'),
  uncle('uncle', 'Uncle'),

  // Other
  other('other', 'Other');

  final String value;
  final String displayName;

  const DependentRelationship(this.value, this.displayName);

  static DependentRelationship fromString(String? value) {
    return DependentRelationship.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DependentRelationship.other,
    );
  }

  /// Check if this relationship qualifies as "qualifying child" for tax purposes
  bool get isQualifyingChildRelationship {
    return [
      son,
      daughter,
      stepson,
      stepdaughter,
      fosterChild,
      brother,
      sister,
      halfBrother,
      halfSister,
      stepbrother,
      stepsister,
      grandchild,
      niece,
      nephew,
    ].contains(this);
  }
}

// -----------------------------------------------------------------------------
// NAME SUFFIX
// Standard name suffixes accepted by IRS
// -----------------------------------------------------------------------------

/// Name suffixes recognized by the IRS
enum NameSuffix {
  jr('Jr', 'Jr.'),
  sr('Sr', 'Sr.'),
  ii('II', 'II'),
  iii('III', 'III'),
  iv('IV', 'IV');

  final String value;
  final String displayName;

  const NameSuffix(this.value, this.displayName);

  static NameSuffix? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return NameSuffix.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NameSuffix.jr,
    );
  }
}

// -----------------------------------------------------------------------------
// DEDUCTION TYPE
// Standard vs Itemized deduction selection
// -----------------------------------------------------------------------------

/// Type of deduction the taxpayer is claiming
enum DeductionType {
  /// Standard deduction based on filing status
  standard('standard', 'Standard Deduction'),

  /// Itemized deductions on Schedule A
  itemized('itemized', 'Itemized Deductions');

  final String value;
  final String displayName;

  const DeductionType(this.value, this.displayName);

  static DeductionType fromString(String? value) {
    return DeductionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DeductionType.standard,
    );
  }
}

// -----------------------------------------------------------------------------
// REFUND OPTIONS
// How the taxpayer wants to receive their refund
// -----------------------------------------------------------------------------

/// Method for receiving tax refund
enum RefundOption {
  /// Direct deposit to bank account (fastest - 21 days)
  directDeposit('direct_deposit', 'Direct Deposit'),

  /// Paper check mailed to address (4-6 weeks)
  paperCheck('paper_check', 'Paper Check'),

  /// Apply refund to next year's estimated taxes
  applyToNextYear('apply_to_next_year', 'Apply to Next Year'),

  /// Split refund between multiple accounts (Form 8888)
  split('split', 'Split Refund');

  final String value;
  final String displayName;

  const RefundOption(this.value, this.displayName);

  static RefundOption fromString(String? value) {
    return RefundOption.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RefundOption.directDeposit,
    );
  }
}

// -----------------------------------------------------------------------------
// BANK ACCOUNT TYPE
// For direct deposit refund
// -----------------------------------------------------------------------------

/// Type of bank account for refund deposit
enum BankAccountType {
  checking('checking', 'Checking'),
  savings('savings', 'Savings');

  final String value;
  final String displayName;

  const BankAccountType(this.value, this.displayName);

  static BankAccountType fromString(String? value) {
    return BankAccountType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BankAccountType.checking,
    );
  }
}

// -----------------------------------------------------------------------------
// E-FILE STATUS
// Status of electronic filing submission
// -----------------------------------------------------------------------------

/// Status of e-file transmission to IRS
enum EFileStatus {
  /// Not yet submitted
  notSubmitted('not_submitted', 'Not Submitted'),

  /// Submitted, awaiting acknowledgment
  pending('pending', 'Pending'),

  /// Successfully transmitted to IRS
  transmitted('transmitted', 'Transmitted'),

  /// IRS accepted the return
  accepted('accepted', 'Accepted'),

  /// IRS rejected the return
  rejected('rejected', 'Rejected');

  final String value;
  final String displayName;

  const EFileStatus(this.value, this.displayName);

  static EFileStatus fromString(String? value) {
    return EFileStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EFileStatus.notSubmitted,
    );
  }

  /// Check if submission is complete (success or failure)
  bool get isFinal => this == accepted || this == rejected;

  /// Check if return was successfully filed
  bool get isSuccess => this == accepted;
}

// -----------------------------------------------------------------------------
// SUBMISSION TYPE
// Type of e-file submission
// -----------------------------------------------------------------------------

/// Type of tax return submission
enum SubmissionType {
  /// Original return for tax year
  original('original', 'Original Return'),

  /// Amended return (Form 1040-X)
  amended('amended', 'Amended Return'),

  /// Superseding return (replaces original before due date)
  superseded('superseded', 'Superseding Return');

  final String value;
  final String displayName;

  const SubmissionType(this.value, this.displayName);

  static SubmissionType fromString(String? value) {
    return SubmissionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SubmissionType.original,
    );
  }
}

// -----------------------------------------------------------------------------
// SIGNER TYPE
// Who is signing the return
// -----------------------------------------------------------------------------

/// Type of person signing the tax return
enum SignerType {
  /// Primary taxpayer signature
  primary('primary', 'Primary Taxpayer'),

  /// Spouse signature (required for MFJ)
  spouse('spouse', 'Spouse'),

  /// Tax preparer signature
  preparer('preparer', 'Tax Preparer'),

  /// Electronic Return Originator
  ero('ero', 'ERO');

  final String value;
  final String displayName;

  const SignerType(this.value, this.displayName);

  static SignerType fromString(String? value) {
    return SignerType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SignerType.primary,
    );
  }
}

// -----------------------------------------------------------------------------
// SIGNATURE METHOD
// Method used for e-signature authentication
// -----------------------------------------------------------------------------

/// Method of authenticating e-file signature
enum SignatureMethod {
  /// Self-Select PIN using prior year AGI or prior year PIN
  selfSelectPin('self_select_pin', 'Self-Select PIN'),

  /// Practitioner PIN (preparer enters PIN)
  practitionerPin('practitioner_pin', 'Practitioner PIN'),

  /// IRS e-file Signature Authorization (Form 8453)
  irsSignature('irs_signature', 'IRS Signature');

  final String value;
  final String displayName;

  const SignatureMethod(this.value, this.displayName);

  static SignatureMethod fromString(String? value) {
    return SignatureMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SignatureMethod.selfSelectPin,
    );
  }
}

// -----------------------------------------------------------------------------
// DOCUMENT TYPE
// Types of tax documents that can be uploaded
// -----------------------------------------------------------------------------

/// Type of tax document uploaded
enum TaxDocumentType {
  w2('w2', 'W-2'),
  form1099Int('1099_int', '1099-INT'),
  form1099Div('1099_div', '1099-DIV'),
  form1099R('1099_r', '1099-R'),
  form1099Nec('1099_nec', '1099-NEC'),
  form1099Misc('1099_misc', '1099-MISC'),
  form1099G('1099_g', '1099-G'),
  form1099B('1099_b', '1099-B'),
  form1099Ssa('1099_ssa', '1099-SSA'),
  other('other', 'Other');

  final String value;
  final String displayName;

  const TaxDocumentType(this.value, this.displayName);

  static TaxDocumentType fromString(String? value) {
    return TaxDocumentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaxDocumentType.other,
    );
  }
}

// -----------------------------------------------------------------------------
// PROCESSING STATUS
// Status of document OCR processing
// -----------------------------------------------------------------------------

/// Status of document processing/OCR
enum ProcessingStatus {
  /// Uploaded, awaiting processing
  pending('pending', 'Pending'),

  /// Currently being processed
  processing('processing', 'Processing'),

  /// Processing completed successfully
  completed('completed', 'Completed'),

  /// Processing failed
  failed('failed', 'Failed');

  final String value;
  final String displayName;

  const ProcessingStatus(this.value, this.displayName);

  static ProcessingStatus fromString(String? value) {
    return ProcessingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProcessingStatus.pending,
    );
  }
}

// -----------------------------------------------------------------------------
// REJECTION CATEGORY
// Categories of IRS rejection reasons
// -----------------------------------------------------------------------------

/// Category of e-file rejection
enum RejectionCategory {
  /// Data entry error (wrong SSN, name mismatch, etc.)
  dataError('data_error', 'Data Error'),

  /// Math error in calculations
  mathError('math_error', 'Math Error'),

  /// Duplicate return already filed
  duplicate('duplicate', 'Duplicate Return'),

  /// Identity verification failed
  identity('identity', 'Identity Verification'),

  /// Other rejection reason
  other('other', 'Other');

  final String value;
  final String displayName;

  const RejectionCategory(this.value, this.displayName);

  static RejectionCategory fromString(String? value) {
    return RejectionCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RejectionCategory.other,
    );
  }
}

// -----------------------------------------------------------------------------
// AUDIT EVENT TYPE
// Types of events logged in audit trail
// -----------------------------------------------------------------------------

/// Type of audit event for compliance logging
enum AuditEventType {
  /// User authentication event
  authentication('authentication', 'Authentication'),

  /// Return was created
  returnCreated('return_created', 'Return Created'),

  /// Return was viewed/accessed
  returnViewed('return_viewed', 'Return Viewed'),

  /// Data was modified
  dataModified('data_modified', 'Data Modified'),

  /// Status was changed
  statusChanged('status_changed', 'Status Changed'),

  /// Tax calculation was performed
  calculation('calculation', 'Calculation'),

  /// Submission was attempted
  submissionAttempted('submission_attempted', 'Submission Attempted'),

  /// Signature was collected
  signatureCollected('signature_collected', 'Signature Collected'),

  /// Document was uploaded
  documentUploaded('document_uploaded', 'Document Uploaded'),

  /// Data was exported
  export('export', 'Export'),

  /// Error occurred
  error('error', 'Error');

  final String value;
  final String displayName;

  const AuditEventType(this.value, this.displayName);

  static AuditEventType fromString(String? value) {
    return AuditEventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuditEventType.returnViewed,
    );
  }
}

// -----------------------------------------------------------------------------
// W-2 BOX 12 CODES
// IRS-defined codes for W-2 Box 12
// -----------------------------------------------------------------------------

/// W-2 Box 12 codes per IRS specifications
enum W2Box12Code {
  a('A', 'Uncollected Social Security or RRTA tax on tips'),
  b('B', 'Uncollected Medicare tax on tips'),
  c('C', 'Taxable cost of group-term life insurance over \$50,000'),
  d('D', 'Elective deferrals to a 401(k)'),
  e('E', 'Elective deferrals to a 403(b)'),
  f('F', 'Elective deferrals to a 408(k)(6) SEP'),
  g('G', 'Elective deferrals to a 457(b)'),
  h('H', 'Elective deferrals to a 501(c)(18)(D)'),
  j('J', 'Nontaxable sick pay'),
  k('K', '20% excise tax on excess golden parachute payments'),
  l('L', 'Substantiated employee business expense reimbursements'),
  m('M', 'Uncollected Social Security or RRTA tax on group-term life insurance'),
  n('N', 'Uncollected Medicare tax on group-term life insurance'),
  p('P', 'Excludable moving expense reimbursements'),
  q('Q', 'Nontaxable combat pay'),
  r('R', 'Employer contributions to Archer MSA'),
  s('S', 'Employee salary reduction contributions to 408(p) SIMPLE'),
  t('T', 'Adoption benefits'),
  v('V', 'Income from exercise of nonstatutory stock options'),
  w('W', 'Employer contributions to Health Savings Account'),
  y('Y', 'Deferrals under a 409A nonqualified deferred compensation plan'),
  z('Z', 'Income under a 409A nonqualified deferred compensation plan'),
  aa('AA', 'Designated Roth contributions to a 401(k)'),
  bb('BB', 'Designated Roth contributions to a 403(b)'),
  dd('DD', 'Cost of employer-sponsored health coverage'),
  ee('EE', 'Designated Roth contributions to a 457(b)'),
  ff('FF', 'Permitted benefits under a qualified small employer HRA'),
  gg('GG', 'Income from qualified equity grants under section 83(i)'),
  hh('HH', 'Aggregate deferrals under section 83(i) elections');

  final String code;
  final String description;

  const W2Box12Code(this.code, this.description);

  static W2Box12Code? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    return W2Box12Code.values.firstWhere(
      (e) => e.code.toUpperCase() == code.toUpperCase(),
      orElse: () => W2Box12Code.a,
    );
  }
}

// -----------------------------------------------------------------------------
// 1099-R DISTRIBUTION CODES
// IRS-defined distribution codes for retirement account distributions
// -----------------------------------------------------------------------------

/// 1099-R Box 7 distribution codes
enum DistributionCode {
  code1('1', 'Early distribution, no known exception'),
  code2('2', 'Early distribution, exception applies'),
  code3('3', 'Disability'),
  code4('4', 'Death'),
  code5('5', 'Prohibited transaction'),
  code6('6', 'Section 1035 exchange'),
  code7('7', 'Normal distribution'),
  code8('8', 'Excess contributions plus earnings/excess deferrals'),
  code9('9', 'Cost of current life insurance protection'),
  codeA('A', 'May be eligible for 10-year tax option'),
  codeB('B', 'Designated Roth account distribution'),
  codeC('C', 'Reportable death benefits under section 6050Y'),
  codeD('D', 'Annuity payments from nonqualified annuities'),
  codeE('E', 'Distributions under Employee Plans Compliance Resolution System'),
  codeF('F', 'Charitable gift annuity'),
  codeG('G', 'Direct rollover to qualified plan, 403(b), governmental 457(b), or IRA'),
  codeH('H', 'Direct rollover to Roth IRA'),
  codeJ('J', 'Early distribution from Roth IRA, no known exception'),
  codeK('K', 'Distribution of IRA assets not having a readily available FMV'),
  codeL('L', 'Loans treated as deemed distributions'),
  codeM('M', 'Qualified plan loan offset'),
  codeN('N', 'Recharacterized IRA contribution'),
  codeP('P', 'Excess contributions plus earnings taxable in prior year'),
  codeQ('Q', 'Qualified distribution from a Roth IRA'),
  codeR('R', 'Recharacterized IRA contribution'),
  codeS('S', 'Early distribution from a SIMPLE IRA in first 2 years'),
  codeT('T', 'Roth IRA distribution, exception applies'),
  codeU('U', 'Dividend distribution from ESOP under section 404(k)'),
  codeW('W', 'Charges or payments for qualified long-term care insurance');

  final String code;
  final String description;

  const DistributionCode(this.code, this.description);

  static DistributionCode? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    return DistributionCode.values.firstWhere(
      (e) => e.code.toUpperCase() == code.toUpperCase(),
      orElse: () => DistributionCode.code7,
    );
  }

  /// Check if this is an early distribution code (potential penalty)
  bool get isEarlyDistribution => ['1', '2', 'J', 'S'].contains(code);
}

// -----------------------------------------------------------------------------
// US STATES
// All US states and territories for tax purposes
// -----------------------------------------------------------------------------

/// US States and territories
enum USState {
  al('AL', 'Alabama'),
  ak('AK', 'Alaska'),
  az('AZ', 'Arizona'),
  ar('AR', 'Arkansas'),
  ca('CA', 'California'),
  co('CO', 'Colorado'),
  ct('CT', 'Connecticut'),
  de('DE', 'Delaware'),
  dc('DC', 'District of Columbia'),
  fl('FL', 'Florida'),
  ga('GA', 'Georgia'),
  hi('HI', 'Hawaii'),
  idaho('ID', 'Idaho'),
  il('IL', 'Illinois'),
  ind('IN', 'Indiana'),
  ia('IA', 'Iowa'),
  ks('KS', 'Kansas'),
  ky('KY', 'Kentucky'),
  la('LA', 'Louisiana'),
  me('ME', 'Maine'),
  md('MD', 'Maryland'),
  ma('MA', 'Massachusetts'),
  mi('MI', 'Michigan'),
  mn('MN', 'Minnesota'),
  ms('MS', 'Mississippi'),
  mo('MO', 'Missouri'),
  mt('MT', 'Montana'),
  ne('NE', 'Nebraska'),
  nv('NV', 'Nevada'),
  nh('NH', 'New Hampshire'),
  nj('NJ', 'New Jersey'),
  nm('NM', 'New Mexico'),
  ny('NY', 'New York'),
  nc('NC', 'North Carolina'),
  nd('ND', 'North Dakota'),
  oh('OH', 'Ohio'),
  ok('OK', 'Oklahoma'),
  oregon('OR', 'Oregon'),
  pa('PA', 'Pennsylvania'),
  ri('RI', 'Rhode Island'),
  sc('SC', 'South Carolina'),
  sd('SD', 'South Dakota'),
  tn('TN', 'Tennessee'),
  tx('TX', 'Texas'),
  ut('UT', 'Utah'),
  vt('VT', 'Vermont'),
  va('VA', 'Virginia'),
  wa('WA', 'Washington'),
  wv('WV', 'West Virginia'),
  wi('WI', 'Wisconsin'),
  wy('WY', 'Wyoming'),
  // Territories
  as_('AS', 'American Samoa'),
  gu('GU', 'Guam'),
  mp('MP', 'Northern Mariana Islands'),
  pr('PR', 'Puerto Rico'),
  vi('VI', 'U.S. Virgin Islands');

  /// Database value (state code)
  final String value;
  
  /// Human-readable display name
  final String displayName;

  const USState(this.value, this.displayName);

  /// Alias for value (state code)
  String get code => value;

  /// Alias for displayName
  String get name => displayName;

  /// Convert from database string to enum
  static USState fromString(String? value) {
    if (value == null || value.isEmpty) return USState.al;
    return USState.values.firstWhere(
      (e) => e.value.toUpperCase() == value.toUpperCase(),
      orElse: () => USState.al,
    );
  }

  /// Legacy method for compatibility
  static USState? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    return USState.values.firstWhere(
      (e) => e.value.toUpperCase() == code.toUpperCase(),
      orElse: () => USState.al,
    );
  }

  /// Check if this state has no state income tax
  bool get hasNoIncomeTax {
    return [ak, fl, nv, nh, sd, tn, tx, wa, wy].contains(this);
  }
}
