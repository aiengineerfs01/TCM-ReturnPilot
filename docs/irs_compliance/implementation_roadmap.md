# Implementation Roadmap

## Overview

This document provides a phased implementation plan for adding IRS e-file compliance to the TCM Return Pilot app. Each phase builds upon the previous, with clear milestones, dependencies, and estimated timelines.

---

## Current App State Assessment

### Existing Features ✅
| Feature | Status | Notes |
|---------|--------|-------|
| User Authentication | ✅ Complete | Supabase Auth |
| Multi-Factor Authentication | ✅ Complete | OTP/Authenticator |
| Identity Verification | ✅ Complete | Document upload |
| Profile Management | ✅ Complete | Basic profile data |
| Interview/Chat System | ✅ Complete | OpenAI Assistants |
| Dark/Light Theme | ✅ Complete | GetX-based |
| Supabase Integration | ✅ Complete | Database + Storage |

### Required for E-File ❌
| Feature | Status | Priority |
|---------|--------|----------|
| Taxpayer Data Collection | ❌ Not Started | 🔴 Critical |
| Tax Calculation Engine | ❌ Not Started | 🔴 Critical |
| IRS XML Generation | ❌ Not Started | 🔴 Critical |
| MeF Transmission | ❌ Not Started | 🔴 Critical |
| Electronic Signature | ❌ Not Started | 🔴 Critical |
| Form 1040 & Schedules | ❌ Not Started | 🔴 Critical |
| W-2/1099 Processing | ❌ Not Started | 🔴 Critical |
| Audit Logging | ❌ Not Started | 🔴 Critical |
| Data Encryption | ❌ Not Started | 🔴 Critical |
| Error Handling (IRS Codes) | ❌ Not Started | 🟡 High |
| Deductions/Credits | ❌ Not Started | 🟡 High |
| State Returns | ❌ Not Started | 🟢 Medium |
| Refund Options | ❌ Not Started | 🟢 Medium |

---

## Phase 1: Foundation & Data Models (Weeks 1-4)

### Goals
- Establish core data models
- Set up encryption infrastructure
- Create audit logging system
- Extend database schema

### Tasks

#### Week 1: Data Models
```
□ Create TaxpayerModel
  - Personal info (name, SSN, DOB)
  - Address model
  - Filing status enum
  - Encrypted field handling
  
□ Create DependentModel
  - Relationship types
  - Qualification rules
  - SSN handling

□ Create SpouseModel
  - Similar to taxpayer
  - Joint filing linkage
```

#### Week 2: Security Infrastructure
```
□ Implement EncryptionService
  - AES-256 encryption
  - Key management
  - SSN/bank account encryption
  
□ Create AuditLogService
  - Event logging
  - Sanitization rules
  - Supabase integration

□ Set up database tables
  - taxpayers table
  - dependents table
  - audit_logs table
  - RLS policies
```

#### Week 3: Income Models
```
□ Create W2Model
  - All box fields
  - Employer info
  - State wages
  
□ Create Form1099Models
  - 1099-INT
  - 1099-DIV
  - 1099-G
  - 1099-NEC
  - 1099-MISC
  
□ Income validation rules
```

#### Week 4: Testing & Integration
```
□ Unit tests for all models
□ Encryption tests
□ Audit log tests
□ Database migration scripts
□ Documentation review
```

### Deliverables
- [ ] All core data models
- [ ] Encryption service
- [ ] Audit logging service
- [ ] Database schema migrations
- [ ] Unit test suite

---

## Phase 2: Tax Calculation Engine (Weeks 5-8)

### Goals
- Build complete tax calculation system
- Implement 2024 tax brackets
- Create deduction/credit calculators
- Validate against IRS rules

### Tasks

#### Week 5: Core Calculator
```
□ TaxCalculatorService
  - Gross income calculation
  - AGI calculation
  - Taxable income calculation
  
□ Tax bracket implementation
  - Single rates
  - MFJ rates
  - MFS rates
  - HOH rates
  - QSS rates
```

#### Week 6: Deductions
```
□ Standard deduction calculator
  - Age/blind additions
  - Dependent limitations
  
□ Itemized deductions
  - Schedule A calculation
  - SALT cap ($10,000)
  - Medical threshold (7.5%)
  - Mortgage interest limits
```

#### Week 7: Credits
```
□ Child Tax Credit calculator
  - Phase-out logic
  - Refundable portion (ACTC)
  
□ Earned Income Credit calculator
  - EIC tables
  - Qualifying children
  - Investment income limit
  
□ Education credits
  - AOTC calculator
  - LLC calculator
```

#### Week 8: Integration & Testing
```
□ End-to-end calculation tests
□ Edge case testing
□ IRS Publication 17 validation
□ Performance optimization
```

### Deliverables
- [ ] Tax calculation engine
- [ ] All credit/deduction calculators
- [ ] Validation test suite
- [ ] Calculation documentation

---

## Phase 3: Form Generation (Weeks 9-12)

### Goals
- Implement Form 1040 structure
- Build all required schedules
- Create form validators
- Generate print-ready PDFs

### Tasks

#### Week 9: Form 1040
```
□ Form1040Model
  - All line items
  - Validation rules
  - Line mappings
  
□ Income section (Lines 1-11)
□ Deduction section (Lines 12-15)
□ Tax section (Lines 16-24)
□ Payments section (Lines 25-33)
□ Refund/owed section (Lines 34-38)
```

#### Week 10: Schedules 1-3
```
□ Schedule 1
  - Additional income
  - Adjustments to income
  
□ Schedule 2
  - Additional taxes
  - AMT calculation
  
□ Schedule 3
  - Nonrefundable credits
  - Other payments
```

#### Week 11: Schedules A-E
```
□ Schedule A (Itemized deductions)
□ Schedule B (Interest/dividends)
□ Schedule C (Business income)
□ Schedule D (Capital gains)
□ Schedule E (Rental income)
```

#### Week 12: Form Validators & PDF
```
□ Cross-form validation
□ IRS business rules
□ PDF generation
□ Print formatting
```

### Deliverables
- [ ] All form models
- [ ] All schedule models
- [ ] Validation engine
- [ ] PDF generator

---

## Phase 4: User Interface (Weeks 13-18)

### Goals
- Build interview flow for data collection
- Create form review screens
- Implement signature flow
- Design error correction UI

### Tasks

#### Week 13-14: Personal Information
```
□ Taxpayer info screens
  - Name entry
  - SSN entry (masked)
  - Date of birth
  - Address
  
□ Filing status selection
  - Status explanations
  - Qualification checks
  
□ Spouse information (if MFJ)
□ Dependent entry screens
```

#### Week 15-16: Income Entry
```
□ W-2 entry wizard
  - Photo capture/OCR
  - Manual entry
  - Employer lookup
  
□ 1099 entry flows
  - Interest income
  - Dividend income
  - Unemployment
  - Self-employment
  
□ Other income screens
```

#### Week 17: Review & Sign
```
□ Return summary screen
□ Form preview (PDF view)
□ Error/warning display
□ PIN entry flow
□ Consent agreements
□ Signature capture
```

#### Week 18: Error Handling
```
□ Validation error UI
□ IRS rejection display
□ Correction wizards
□ Resubmission flow
```

### Deliverables
- [ ] Complete UI flow
- [ ] Form entry wizards
- [ ] Review screens
- [ ] Signature flow
- [ ] Error handling UI

---

## Phase 5: E-File Infrastructure (Weeks 19-24)

### Goals
- Implement IRS XML schema
- Build MeF transmission client
- Create acknowledgment processing
- Set up submission queue

### Tasks

#### Week 19-20: XML Generation
```
□ XML Generator service
  - Return header
  - Form 1040 XML
  - Schedule XML
  - W-2/1099 XML
  
□ Schema validation
□ XML signing
```

#### Week 21-22: Transmission
```
□ MeF client setup
  - SOAP/MTOM client
  - Certificate handling
  - Test environment
  
□ Submission service
  - Queue management
  - Retry logic
  - Status tracking
```

#### Week 23-24: Acknowledgments
```
□ Acknowledgment polling
□ Accept/reject processing
□ Error code database
□ User notifications
□ Rejection handling
```

### Deliverables
- [ ] XML generation engine
- [ ] MeF transmission client
- [ ] Acknowledgment processor
- [ ] Submission queue system

---

## Phase 6: Testing & Certification (Weeks 25-28)

### Goals
- Complete IRS ATES testing
- Pass all certification tests
- Security audit
- Performance testing

### Tasks

#### Week 25-26: ATES Testing
```
□ IRS Assurance Testing
  - Test scenarios
  - Error correction
  - Resubmission
  
□ ATS test cases
□ Issue resolution
```

#### Week 27: Security & Performance
```
□ Security audit
  - Penetration testing
  - Data encryption verification
  - Access control review
  
□ Performance testing
  - Load testing
  - Stress testing
  - Optimization
```

#### Week 28: Final Certification
```
□ IRS certification submission
□ Documentation completion
□ Compliance verification
□ Go-live preparation
```

### Deliverables
- [ ] ATES certification
- [ ] Security audit report
- [ ] Performance benchmarks
- [ ] IRS approval

---

## Phase 7: Launch & Support (Weeks 29-32)

### Goals
- Controlled rollout
- Monitor for issues
- User support setup
- Iteration planning

### Tasks

#### Week 29-30: Soft Launch
```
□ Beta user group
□ Monitoring setup
□ Error tracking
□ Feedback collection
```

#### Week 31-32: Full Launch
```
□ Public release
□ Marketing coordination
□ Support documentation
□ Issue response plan
```

### Deliverables
- [ ] Production deployment
- [ ] Monitoring dashboard
- [ ] Support system
- [ ] User documentation

---

## Resource Requirements

### Development Team
| Role | Phase 1-2 | Phase 3-4 | Phase 5-6 | Phase 7 |
|------|-----------|-----------|-----------|---------|
| Senior Flutter Dev | 2 | 2 | 2 | 1 |
| Backend Developer | 1 | 1 | 2 | 1 |
| Tax Domain Expert | 0.5 | 1 | 0.5 | 0.25 |
| QA Engineer | 0.5 | 1 | 2 | 1 |
| DevOps | 0.25 | 0.25 | 0.5 | 0.5 |

### Infrastructure
- Supabase (existing) - Extended storage/compute
- IRS MeF Test Environment access
- SSL certificates for XML signing
- Monitoring tools (Sentry, etc.)

### External Services
- OCR service for document scanning
- Identity verification API
- Bank account verification (for direct deposit)

---

## Risk Mitigation

### Technical Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| IRS schema changes | High | Monitor IRS updates, build flexible parser |
| MeF downtime | High | Queue system, retry logic, user notification |
| Encryption key loss | Critical | Secure key management, backup procedures |
| Performance issues | Medium | Early load testing, optimization sprints |

### Compliance Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Failed certification | Critical | Early ATES testing, IRS consultation |
| Data breach | Critical | Security audit, penetration testing |
| Incorrect calculations | High | Extensive testing, external validation |
| Audit findings | High | Complete documentation, audit trail |

### Timeline Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Scope creep | Medium | Clear phase gates, feature freeze dates |
| Resource availability | Medium | Cross-training, documentation |
| IRS delays | High | Buffer in schedule, parallel workstreams |

---

## Success Metrics

### Phase Completion Criteria
- [ ] All deliverables complete
- [ ] Tests passing (>90% coverage)
- [ ] Documentation complete
- [ ] Code review approved
- [ ] Stakeholder sign-off

### Launch Criteria
- [ ] IRS certification obtained
- [ ] Security audit passed
- [ ] Performance benchmarks met
- [ ] Support team trained
- [ ] Monitoring operational

### Post-Launch Metrics
- E-file acceptance rate > 95%
- User completion rate > 80%
- Support ticket volume < target
- System uptime > 99.9%

---

## Quick Start Guide

### To Begin Phase 1:

1. **Review Documentation**
   - Read all docs in `/docs/irs_compliance/`
   - Understand data models and requirements

2. **Set Up Development Environment**
   - Ensure Supabase project is configured
   - Set up test environment
   - Configure encryption keys (dev only)

3. **Create First Models**
   ```dart
   // Start with TaxpayerModel
   // See docs/irs_compliance/taxpayer_data.md
   ```

4. **Implement Encryption**
   ```dart
   // See docs/irs_compliance/security_compliance.md
   ```

5. **Set Up Audit Logging**
   ```dart
   // See docs/irs_compliance/audit_trail.md
   ```

---

## Related Documents

- [Overview](./overview.md) - IRS E-File program requirements
- [Taxpayer Data](./taxpayer_data.md) - Personal information specs
- [Income Sources](./income_sources.md) - W-2/1099 handling
- [Calculations](./calculations.md) - Tax calculation engine
- [Tax Forms](./tax_forms.md) - Form 1040 & schedules
- [Deductions & Credits](./deductions_credits.md) - All tax benefits
- [E-File Transmission](./efile_transmission.md) - MeF integration
- [Security Compliance](./security_compliance.md) - Encryption & access
- [Signature & Consent](./signature_consent.md) - Electronic signatures
