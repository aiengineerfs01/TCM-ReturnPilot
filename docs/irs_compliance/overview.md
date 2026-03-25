# IRS E-File Program Overview

## What is IRS E-File?

The IRS Modernized e-File (MeF) system is the electronic filing system for federal tax returns. To participate, applications must meet strict compliance requirements.

---

## 1. Authorized E-File Provider Requirements

### 1.1 EFIN (Electronic Filing Identification Number)
- **Required**: Every e-file provider must have a valid EFIN
- **Application**: IRS Form 8633 (Application to Participate in IRS e-file)
- **Background Check**: Principals must pass IRS suitability checks
- **Renewal**: Annual renewal required

### 1.2 Provider Types
| Type | Description | Requirements |
|------|-------------|--------------|
| **ERO** | Electronic Return Originator | Originates and transmits returns |
| **Transmitter** | Transmits returns to IRS | Must pass software testing |
| **ISP** | Intermediate Service Provider | Processes returns between parties |
| **Software Developer** | Creates e-file software | Must pass IRS software testing |

### 1.3 Our Role
- **Primary**: Software Developer + Transmitter
- **EFIN Holder**: TCM or partner organization
- **Responsibility**: Complete MeF compliance

---

## 2. Compliance Categories

### 2.1 Technical Requirements
```
┌─────────────────────────────────────────────────────────┐
│                 MeF SYSTEM INTEGRATION                  │
├─────────────────────────────────────────────────────────┤
│  ┌───────────┐    ┌───────────┐    ┌───────────────┐   │
│  │  Mobile   │───▶│   API     │───▶│  IRS MeF      │   │
│  │   App     │    │  Server   │    │  Gateway      │   │
│  └───────────┘    └───────────┘    └───────────────┘   │
│       │                │                   │            │
│       ▼                ▼                   ▼            │
│  [User Input]    [XML Generation]    [Acknowledgment]   │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Data Security Requirements
- **Encryption**: TLS 1.2+ for transmission, AES-256 at rest
- **Access Control**: Role-based, multi-factor authentication
- **Audit Logging**: All access and modifications tracked
- **Data Retention**: 3 years minimum per IRS requirements

### 2.3 Identity Verification
- **IRS SSNVS**: Social Security Number Verification Service
- **Knowledge-Based Auth**: Questions from credit bureau data
- **ID Document Verification**: Government-issued ID validation
- **Selfie Matching**: Biometric verification (already implemented)

---

## 3. Required IRS Forms Support

### 3.1 Core Forms (Must Have)
| Form | Description | Priority |
|------|-------------|----------|
| **1040** | U.S. Individual Income Tax Return | 🔴 Critical |
| **1040-SR** | Tax Return for Seniors | 🔴 Critical |
| **W-2** | Wage and Tax Statement | 🔴 Critical |
| **1099-INT** | Interest Income | 🔴 Critical |
| **1099-DIV** | Dividend Income | 🔴 Critical |
| **1099-G** | Government Payments | 🔴 Critical |
| **1099-R** | Retirement Distributions | 🟡 High |
| **1099-NEC** | Non-employee Compensation | 🟡 High |
| **1099-MISC** | Miscellaneous Income | 🟡 High |

### 3.2 Schedules (Must Have)
| Schedule | Description | When Required |
|----------|-------------|---------------|
| **Schedule 1** | Additional Income and Adjustments | Certain deductions/income |
| **Schedule 2** | Additional Taxes | Alternative minimum tax, etc. |
| **Schedule 3** | Additional Credits and Payments | Certain credits |
| **Schedule A** | Itemized Deductions | If itemizing |
| **Schedule B** | Interest and Dividends | If > $1,500 |
| **Schedule C** | Business Income | Self-employment |
| **Schedule D** | Capital Gains/Losses | If applicable |
| **Schedule E** | Rental/Partnership Income | If applicable |
| **Schedule EIC** | Earned Income Credit | If claiming EIC |
| **Schedule SE** | Self-Employment Tax | If self-employed |
| **Form 8812** | Child Tax Credit | If claiming CTC |
| **Form 8863** | Education Credits | If claiming education credits |

---

## 4. MeF XML Schema Requirements

### 4.1 Schema Versions
- Current: TY2024 (Tax Year 2024)
- Must support: Current year + 2 prior years
- Schema updates: Published annually by IRS

### 4.2 XML Structure
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Return xmlns="http://www.irs.gov/efile" returnVersion="2024v5.0">
  <ReturnHeader>
    <!-- Taxpayer identification, filing status, preparer info -->
  </ReturnHeader>
  <ReturnData>
    <IRS1040>
      <!-- Main form data -->
    </IRS1040>
    <!-- Supporting schedules and forms -->
  </ReturnData>
</Return>
```

### 4.3 Validation Requirements
1. **Schema Validation**: XML must conform to IRS schemas
2. **Business Rules**: 1000+ IRS business rules
3. **Math Verification**: All calculations verified
4. **Cross-Reference**: Related forms must match

---

## 5. Acknowledgment Processing

### 5.1 Response Types
| Code | Meaning | Action Required |
|------|---------|-----------------|
| **A** | Accepted | Return accepted, no action |
| **R** | Rejected | Error must be corrected |
| **P** | Pending | Awaiting further processing |

### 5.2 Rejection Handling
- **Error Codes**: 500+ possible rejection codes
- **Resolution**: Must provide clear user guidance
- **Resubmission**: Support for correcting and retransmitting
- **Tracking**: Log all rejections and resolutions

---

## 6. Compliance Deadlines

### 6.1 Annual Timeline
| Date | Milestone |
|------|-----------|
| October 15 | Schema release for next year |
| November | Begin software development |
| December | Complete ATS testing |
| January 1 | Testing season opens |
| Late January | IRS begins accepting returns |
| April 15 | Filing deadline |
| October 15 | Extended filing deadline |

### 6.2 Testing Requirements
- **ATS Testing**: Assurance Testing System
- **Test Scenarios**: IRS-provided test returns
- **Pass Rate**: 100% required for production
- **Annual**: Must re-test each tax year

---

## 7. Implementation Priority Matrix

### Phase 1: Foundation (Weeks 1-4)
- [ ] Data models for tax entities
- [ ] Taxpayer information screens
- [ ] SSN validation and formatting
- [ ] Filing status determination

### Phase 2: Income (Weeks 5-8)
- [ ] W-2 entry and import
- [ ] 1099 series support
- [ ] Income categorization
- [ ] Income verification

### Phase 3: Deductions & Credits (Weeks 9-12)
- [ ] Standard vs. itemized logic
- [ ] Common credits (CTC, EIC, etc.)
- [ ] Education credits
- [ ] Retirement contributions

### Phase 4: Calculations (Weeks 13-16)
- [ ] Tax calculation engine
- [ ] Bracket application
- [ ] Credit application
- [ ] Refund/amount owed calculation

### Phase 5: E-File (Weeks 17-20)
- [ ] XML generation
- [ ] Schema validation
- [ ] MeF transmission
- [ ] Acknowledgment handling

### Phase 6: Compliance (Weeks 21-24)
- [ ] Audit logging
- [ ] Security hardening
- [ ] ATS testing
- [ ] Documentation

---

## 8. Related Documents

- [Taxpayer Data Collection](./taxpayer_data.md)
- [Tax Forms Implementation](./tax_forms.md)
- [Income Sources](./income_sources.md)
- [E-File Transmission](./efile_transmission.md)
- [Security & Compliance](./security_compliance.md)

---

## 9. IRS Resources

| Resource | URL |
|----------|-----|
| MeF Program | https://www.irs.gov/e-file-providers/modernized-e-file-mef-internet-transmitter |
| Publication 4164 | https://www.irs.gov/pub/irs-pdf/p4164.pdf |
| Publication 1345 | https://www.irs.gov/pub/irs-pdf/p1345.pdf |
| Publication 4557 | https://www.irs.gov/pub/irs-pdf/p4557.pdf |
| Schema Downloads | https://www.irs.gov/e-file-providers/current-valid-xml-schemas-and-business-rules |
