-- =============================================================================
-- TCM Return Pilot - IRS E-File Compliance Database Schema
-- Migration: 001_tax_compliance_tables.sql
-- Description: Creates all tables required for IRS e-file compliance
-- =============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- 1. TAX RETURNS - Master table for all tax returns
-- =============================================================================
CREATE TABLE IF NOT EXISTS tax_returns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Return Information
  tax_year INTEGER NOT NULL CHECK (tax_year >= 2020 AND tax_year <= 2099),
  filing_status TEXT NOT NULL CHECK (
    filing_status IN ('single', 'married_filing_jointly', 'married_filing_separately', 'head_of_household', 'qualifying_widow')
  ),
  return_status TEXT NOT NULL DEFAULT 'not_started' CHECK (
    return_status IN ('not_started', 'in_progress', 'ready_for_review', 'ready_to_file', 'submitted', 'accepted', 'rejected', 'amended')
  ),
  
  -- Calculated Totals (updated as user enters data)
  total_income DECIMAL(12,2) DEFAULT 0,
  adjusted_gross_income DECIMAL(12,2) DEFAULT 0,
  total_deductions DECIMAL(12,2) DEFAULT 0,
  taxable_income DECIMAL(12,2) DEFAULT 0,
  total_tax DECIMAL(12,2) DEFAULT 0,
  total_credits DECIMAL(12,2) DEFAULT 0,
  total_payments DECIMAL(12,2) DEFAULT 0,
  refund_amount DECIMAL(12,2) DEFAULT 0,
  amount_owed DECIMAL(12,2) DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  submitted_at TIMESTAMPTZ,
  prepared_by TEXT
);

-- Create indexes for tax_returns
CREATE INDEX idx_tax_returns_user_id ON tax_returns(user_id);
CREATE INDEX idx_tax_returns_tax_year ON tax_returns(tax_year);
CREATE INDEX idx_tax_returns_status ON tax_returns(return_status);

-- =============================================================================
-- 2. TAXPAYER INFO - Primary taxpayer and spouse information
-- =============================================================================
CREATE TABLE IF NOT EXISTS taxpayer_info (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Taxpayer Type
  taxpayer_type TEXT NOT NULL CHECK (taxpayer_type IN ('primary', 'spouse')),
  
  -- Personal Information
  first_name TEXT NOT NULL CHECK (LENGTH(first_name) <= 50),
  middle_initial TEXT CHECK (LENGTH(middle_initial) <= 1),
  last_name TEXT NOT NULL CHECK (LENGTH(last_name) <= 50),
  suffix TEXT CHECK (suffix IN ('Jr', 'Sr', 'II', 'III', 'IV', NULL)),
  
  -- Identification (SSN is encrypted)
  ssn_encrypted BYTEA NOT NULL,
  date_of_birth DATE NOT NULL,
  
  -- Address
  street_address_1 TEXT NOT NULL CHECK (LENGTH(street_address_1) <= 100),
  street_address_2 TEXT CHECK (LENGTH(street_address_2) <= 100),
  city TEXT NOT NULL CHECK (LENGTH(city) <= 50),
  state_code TEXT NOT NULL CHECK (LENGTH(state_code) = 2),
  zip_code TEXT NOT NULL CHECK (zip_code ~ '^\d{5}$'),
  zip_plus_4 TEXT CHECK (zip_plus_4 ~ '^\d{4}$'),
  
  -- Additional Information
  occupation TEXT CHECK (LENGTH(occupation) <= 50),
  phone TEXT CHECK (phone ~ '^\d{10}$'),
  email TEXT CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  
  -- Identity Protection PIN (if issued by IRS)
  ip_pin_encrypted BYTEA,
  
  -- Prior Year Info (for e-file authentication)
  prior_year_agi_encrypted BYTEA,
  prior_year_pin_encrypted BYTEA,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure only one primary and one spouse per return
  UNIQUE (return_id, taxpayer_type)
);

-- Create indexes
CREATE INDEX idx_taxpayer_info_return_id ON taxpayer_info(return_id);

-- =============================================================================
-- 3. DEPENDENTS - Child and dependent information
-- =============================================================================
CREATE TABLE IF NOT EXISTS dependents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Personal Information
  first_name TEXT NOT NULL CHECK (LENGTH(first_name) <= 50),
  middle_initial TEXT CHECK (LENGTH(middle_initial) <= 1),
  last_name TEXT NOT NULL CHECK (LENGTH(last_name) <= 50),
  suffix TEXT CHECK (suffix IN ('Jr', 'Sr', 'II', 'III', 'IV', NULL)),
  
  -- Identification
  ssn_encrypted BYTEA NOT NULL,
  date_of_birth DATE NOT NULL,
  
  -- Relationship
  relationship TEXT NOT NULL CHECK (
    relationship IN (
      'son', 'daughter', 'stepson', 'stepdaughter', 'foster_child',
      'brother', 'sister', 'half_brother', 'half_sister', 'stepbrother', 'stepsister',
      'grandchild', 'niece', 'nephew', 'parent', 'grandparent', 'aunt', 'uncle', 'other'
    )
  ),
  
  -- Qualifying Information
  months_lived_with_taxpayer INTEGER CHECK (months_lived_with_taxpayer >= 0 AND months_lived_with_taxpayer <= 12),
  
  -- Credit Eligibility (calculated/verified)
  qualifies_for_ctc BOOLEAN DEFAULT FALSE,          -- Child Tax Credit
  qualifies_for_eic BOOLEAN DEFAULT FALSE,          -- Earned Income Credit
  qualifies_for_child_care BOOLEAN DEFAULT FALSE,   -- Child & Dependent Care Credit
  qualifies_for_other_dependent BOOLEAN DEFAULT FALSE,
  
  -- Additional Status
  is_student BOOLEAN DEFAULT FALSE,
  is_disabled BOOLEAN DEFAULT FALSE,
  gross_income DECIMAL(12,2),
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_dependents_return_id ON dependents(return_id);

-- =============================================================================
-- 4. W-2 FORMS - Wage and tax statements
-- =============================================================================
CREATE TABLE IF NOT EXISTS w2_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Employer Information
  employer_ein TEXT NOT NULL CHECK (employer_ein ~ '^\d{2}-\d{7}$'),
  employer_name TEXT NOT NULL CHECK (LENGTH(employer_name) <= 100),
  employer_street_1 TEXT NOT NULL,
  employer_street_2 TEXT,
  employer_city TEXT NOT NULL,
  employer_state TEXT NOT NULL CHECK (LENGTH(employer_state) = 2),
  employer_zip TEXT NOT NULL,
  control_number TEXT,
  
  -- Box 1-6: Core Wage/Tax Information
  box_1_wages DECIMAL(12,2) NOT NULL DEFAULT 0,                -- Wages, tips, other compensation
  box_2_federal_withheld DECIMAL(12,2) NOT NULL DEFAULT 0,     -- Federal income tax withheld
  box_3_ss_wages DECIMAL(12,2) NOT NULL DEFAULT 0,             -- Social Security wages
  box_4_ss_tax DECIMAL(12,2) NOT NULL DEFAULT 0,               -- Social Security tax withheld
  box_5_medicare_wages DECIMAL(12,2) NOT NULL DEFAULT 0,       -- Medicare wages and tips
  box_6_medicare_tax DECIMAL(12,2) NOT NULL DEFAULT 0,         -- Medicare tax withheld
  
  -- Box 7-11: Additional Information
  box_7_ss_tips DECIMAL(12,2) DEFAULT 0,                       -- Social Security tips
  box_8_allocated_tips DECIMAL(12,2) DEFAULT 0,                -- Allocated tips
  box_10_dependent_care DECIMAL(12,2) DEFAULT 0,               -- Dependent care benefits
  box_11_nonqualified_plans DECIMAL(12,2) DEFAULT 0,           -- Nonqualified plans
  
  -- Box 12: Special Codes (stored as JSONB array)
  box_12_entries JSONB DEFAULT '[]',                           -- [{code: "D", amount: 1000.00}]
  
  -- Box 13: Checkboxes
  box_13_statutory_employee BOOLEAN DEFAULT FALSE,
  box_13_retirement_plan BOOLEAN DEFAULT FALSE,
  box_13_third_party_sick_pay BOOLEAN DEFAULT FALSE,
  
  -- Box 14: Other
  box_14_other TEXT,
  
  -- Boxes 15-20: State & Local
  state_code TEXT CHECK (LENGTH(state_code) = 2),
  state_employer_id TEXT,
  state_wages DECIMAL(12,2),
  state_tax_withheld DECIMAL(12,2),
  locality_name TEXT,
  local_wages DECIMAL(12,2),
  local_tax_withheld DECIMAL(12,2),
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_w2_forms_return_id ON w2_forms(return_id);

-- =============================================================================
-- 5. FORM 1099-INT - Interest Income
-- =============================================================================
CREATE TABLE IF NOT EXISTS form_1099_int (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Payer Information
  payer_name TEXT NOT NULL,
  payer_tin TEXT NOT NULL,                                    -- Payer's TIN
  payer_street TEXT,
  payer_city TEXT,
  payer_state TEXT,
  payer_zip TEXT,
  
  -- Box 1-17 (Common ones)
  box_1_interest_income DECIMAL(12,2) DEFAULT 0,              -- Interest income
  box_2_early_withdrawal_penalty DECIMAL(12,2) DEFAULT 0,     -- Early withdrawal penalty
  box_3_interest_us_bonds DECIMAL(12,2) DEFAULT 0,            -- Interest on U.S. Savings Bonds
  box_4_federal_withheld DECIMAL(12,2) DEFAULT 0,             -- Federal income tax withheld
  box_8_tax_exempt_interest DECIMAL(12,2) DEFAULT 0,          -- Tax-exempt interest
  box_9_private_activity_bond DECIMAL(12,2) DEFAULT 0,        -- Private activity bond interest
  box_10_market_discount DECIMAL(12,2) DEFAULT 0,             -- Market discount
  box_11_bond_premium DECIMAL(12,2) DEFAULT 0,                -- Bond premium
  
  -- State Information
  state_code TEXT,
  state_id TEXT,
  state_tax_withheld DECIMAL(12,2),
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_1099_int_return_id ON form_1099_int(return_id);

-- =============================================================================
-- 6. FORM 1099-DIV - Dividend Income
-- =============================================================================
CREATE TABLE IF NOT EXISTS form_1099_div (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Payer Information
  payer_name TEXT NOT NULL,
  payer_tin TEXT NOT NULL,
  
  -- Box 1-18
  box_1a_ordinary_dividends DECIMAL(12,2) DEFAULT 0,          -- Total ordinary dividends
  box_1b_qualified_dividends DECIMAL(12,2) DEFAULT 0,         -- Qualified dividends
  box_2a_capital_gains DECIMAL(12,2) DEFAULT 0,               -- Total capital gain distributions
  box_2b_unrecap_1250_gain DECIMAL(12,2) DEFAULT 0,           -- Unrecaptured Section 1250 gain
  box_2c_section_1202_gain DECIMAL(12,2) DEFAULT 0,           -- Section 1202 gain
  box_2d_collectibles_gain DECIMAL(12,2) DEFAULT 0,           -- Collectibles (28%) gain
  box_3_nondividend_dist DECIMAL(12,2) DEFAULT 0,             -- Nondividend distributions
  box_4_federal_withheld DECIMAL(12,2) DEFAULT 0,             -- Federal income tax withheld
  box_5_section_199a DECIMAL(12,2) DEFAULT 0,                 -- Section 199A dividends
  box_6_investment_expenses DECIMAL(12,2) DEFAULT 0,          -- Investment expenses
  box_7_foreign_tax_paid DECIMAL(12,2) DEFAULT 0,             -- Foreign tax paid
  box_8_foreign_country TEXT,                                 -- Foreign country
  box_11_fatca_filing BOOLEAN DEFAULT FALSE,                  -- FATCA filing requirement
  box_12_exempt_interest_dividends DECIMAL(12,2) DEFAULT 0,   -- Exempt-interest dividends
  box_13_private_activity DECIMAL(12,2) DEFAULT 0,            -- Private activity bond AMT
  
  -- State Information
  state_code TEXT,
  state_id TEXT,
  state_tax_withheld DECIMAL(12,2),
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_1099_div_return_id ON form_1099_div(return_id);

-- =============================================================================
-- 7. FORM 1099-R - Retirement Distributions
-- =============================================================================
CREATE TABLE IF NOT EXISTS form_1099_r (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Payer Information
  payer_name TEXT NOT NULL,
  payer_tin TEXT NOT NULL,
  payer_street TEXT,
  payer_city TEXT,
  payer_state TEXT,
  payer_zip TEXT,
  
  -- Boxes
  box_1_gross_distribution DECIMAL(12,2) DEFAULT 0,           -- Gross distribution
  box_2a_taxable_amount DECIMAL(12,2) DEFAULT 0,              -- Taxable amount
  box_2b_taxable_not_determined BOOLEAN DEFAULT FALSE,        -- Taxable amount not determined
  box_2b_total_distribution BOOLEAN DEFAULT FALSE,            -- Total distribution
  box_3_capital_gain DECIMAL(12,2) DEFAULT 0,                 -- Capital gain
  box_4_federal_withheld DECIMAL(12,2) DEFAULT 0,             -- Federal income tax withheld
  box_5_employee_contributions DECIMAL(12,2) DEFAULT 0,       -- Employee contributions/insurance premiums
  box_6_net_unrealized_appreciation DECIMAL(12,2) DEFAULT 0,  -- Net unrealized appreciation
  box_7_distribution_code TEXT,                               -- Distribution code(s)
  box_8_other_amount DECIMAL(12,2) DEFAULT 0,                 -- Other amount
  box_9a_employee_percent DECIMAL(5,2),                       -- Your percentage of total distribution
  box_9b_total_employee_contributions DECIMAL(12,2),          -- Total employee contributions
  box_10_amount_allocable_irr DECIMAL(12,2) DEFAULT 0,        -- Amount allocable to IRR
  box_11_first_year_roth INTEGER,                             -- First year of designated Roth
  box_14_state_tax_withheld DECIMAL(12,2) DEFAULT 0,          -- State tax withheld
  box_15_state_payer_number TEXT,                             -- State/Payer's state no.
  box_16_state_distribution DECIMAL(12,2) DEFAULT 0,          -- State distribution
  
  -- IRA/SEP/SIMPLE indicator
  ira_sep_simple BOOLEAN DEFAULT FALSE,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_1099_r_return_id ON form_1099_r(return_id);

-- =============================================================================
-- 8. FORM 1099-NEC - Nonemployee Compensation
-- =============================================================================
CREATE TABLE IF NOT EXISTS form_1099_nec (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Payer Information
  payer_name TEXT NOT NULL,
  payer_tin TEXT NOT NULL,
  payer_street TEXT,
  payer_city TEXT,
  payer_state TEXT,
  payer_zip TEXT,
  
  -- Boxes
  box_1_nonemployee_compensation DECIMAL(12,2) DEFAULT 0,     -- Nonemployee compensation
  box_4_federal_withheld DECIMAL(12,2) DEFAULT 0,             -- Federal income tax withheld
  
  -- State Information
  state_code TEXT,
  state_payer_number TEXT,
  state_income DECIMAL(12,2),
  state_tax_withheld DECIMAL(12,2),
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_1099_nec_return_id ON form_1099_nec(return_id);

-- =============================================================================
-- 9. FORM 1099-MISC - Miscellaneous Income
-- =============================================================================
CREATE TABLE IF NOT EXISTS form_1099_misc (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Payer Information
  payer_name TEXT NOT NULL,
  payer_tin TEXT NOT NULL,
  
  -- Boxes
  box_1_rents DECIMAL(12,2) DEFAULT 0,                        -- Rents
  box_2_royalties DECIMAL(12,2) DEFAULT 0,                    -- Royalties
  box_3_other_income DECIMAL(12,2) DEFAULT 0,                 -- Other income
  box_4_federal_withheld DECIMAL(12,2) DEFAULT 0,             -- Federal income tax withheld
  box_5_fishing_boat DECIMAL(12,2) DEFAULT 0,                 -- Fishing boat proceeds
  box_6_medical_payments DECIMAL(12,2) DEFAULT 0,             -- Medical and health care payments
  box_8_substitute_payments DECIMAL(12,2) DEFAULT 0,          -- Substitute payments
  box_9_crop_insurance DECIMAL(12,2) DEFAULT 0,               -- Crop insurance proceeds
  box_10_gross_proceeds DECIMAL(12,2) DEFAULT 0,              -- Gross proceeds to attorney
  box_11_fish_purchased DECIMAL(12,2) DEFAULT 0,              -- Fish purchased for resale
  box_12_section_409a_deferrals DECIMAL(12,2) DEFAULT 0,      -- Section 409A deferrals
  box_14_excess_golden_parachute DECIMAL(12,2) DEFAULT 0,     -- Excess golden parachute payments
  box_15_nonqualified_deferred_comp DECIMAL(12,2) DEFAULT 0,  -- Nonqualified deferred compensation
  
  -- State Information
  state_code TEXT,
  state_payer_number TEXT,
  state_income DECIMAL(12,2),
  state_tax_withheld DECIMAL(12,2),
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_1099_misc_return_id ON form_1099_misc(return_id);

-- =============================================================================
-- 10. FORM 1099-G - Government Payments
-- =============================================================================
CREATE TABLE IF NOT EXISTS form_1099_g (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Payer Information
  payer_name TEXT NOT NULL,
  payer_tin TEXT NOT NULL,
  
  -- Boxes
  box_1_unemployment DECIMAL(12,2) DEFAULT 0,                 -- Unemployment compensation
  box_2_state_local_refund DECIMAL(12,2) DEFAULT 0,           -- State or local income tax refunds
  box_3_tax_year TEXT,                                        -- Box 2 amount is for tax year
  box_4_federal_withheld DECIMAL(12,2) DEFAULT 0,             -- Federal income tax withheld
  box_5_rtaa_payments DECIMAL(12,2) DEFAULT 0,                -- RTAA payments
  box_6_taxable_grants DECIMAL(12,2) DEFAULT 0,               -- Taxable grants
  box_7_agriculture_payments DECIMAL(12,2) DEFAULT 0,         -- Agriculture payments
  box_9_market_gain DECIMAL(12,2) DEFAULT 0,                  -- Market gain
  box_10a_state_tax_withheld DECIMAL(12,2) DEFAULT 0,         -- State tax withheld
  box_10b_state_tax_withheld DECIMAL(12,2) DEFAULT 0,         -- State tax withheld (2nd state)
  box_11_state TEXT,                                          -- State
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_1099_g_return_id ON form_1099_g(return_id);

-- =============================================================================
-- 11. FORM 1099-B - Broker Transactions (Capital Gains)
-- =============================================================================
CREATE TABLE IF NOT EXISTS form_1099_b (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Broker Information
  broker_name TEXT NOT NULL,
  broker_tin TEXT NOT NULL,
  
  -- Transaction Details
  description TEXT NOT NULL,                                  -- Description of property
  date_acquired DATE,
  date_sold DATE NOT NULL,
  proceeds DECIMAL(12,2) NOT NULL DEFAULT 0,                  -- Sales price
  cost_basis DECIMAL(12,2) DEFAULT 0,                         -- Cost or other basis
  
  -- Gain/Loss Calculation
  adjustment_code TEXT,                                       -- Adjustment code
  adjustment_amount DECIMAL(12,2) DEFAULT 0,                  -- Adjustment amount
  gain_loss DECIMAL(12,2) DEFAULT 0,                          -- Realized gain or loss
  
  -- Classification
  is_short_term BOOLEAN DEFAULT TRUE,                         -- Short-term vs long-term
  box_6_reported_to_irs BOOLEAN DEFAULT TRUE,                 -- Reported to IRS
  
  -- Holding Category (for Form 8949)
  holding_category TEXT CHECK (
    holding_category IN ('A', 'B', 'C', 'D', 'E', 'F')
  ),
  
  -- Federal Withholding
  federal_withheld DECIMAL(12,2) DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_1099_b_return_id ON form_1099_b(return_id);

-- =============================================================================
-- 12. FORM 1099-SSA - Social Security Benefits
-- =============================================================================
CREATE TABLE IF NOT EXISTS form_1099_ssa (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Beneficiary Type
  beneficiary_type TEXT NOT NULL CHECK (beneficiary_type IN ('primary', 'spouse')),
  
  -- Boxes
  box_3_benefits_paid DECIMAL(12,2) DEFAULT 0,                -- Benefits paid
  box_4_benefits_repaid DECIMAL(12,2) DEFAULT 0,              -- Benefits repaid
  box_5_net_benefits DECIMAL(12,2) DEFAULT 0,                 -- Net benefits (Box 3 - Box 4)
  box_6_voluntary_withheld DECIMAL(12,2) DEFAULT 0,           -- Voluntary federal income tax withheld
  
  -- Calculated taxable amount (based on AGI)
  taxable_amount DECIMAL(12,2) DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_1099_ssa_return_id ON form_1099_ssa(return_id);

-- =============================================================================
-- 13. ADJUSTMENTS TO INCOME
-- =============================================================================
CREATE TABLE IF NOT EXISTS adjustments_to_income (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Line 11-24 Adjustments (Schedule 1 Part II)
  educator_expenses DECIMAL(12,2) DEFAULT 0,                  -- Up to $300 per educator
  business_expenses_reservists DECIMAL(12,2) DEFAULT 0,       -- Reservists, artists, etc.
  health_savings_account DECIMAL(12,2) DEFAULT 0,             -- HSA deduction
  moving_expenses_military DECIMAL(12,2) DEFAULT 0,           -- Armed Forces only
  self_employment_tax_deduction DECIMAL(12,2) DEFAULT 0,      -- 50% of SE tax
  self_employed_sep_simple DECIMAL(12,2) DEFAULT 0,           -- SEP, SIMPLE, qualified plans
  self_employed_health_insurance DECIMAL(12,2) DEFAULT 0,     -- Health insurance deduction
  early_withdrawal_penalty DECIMAL(12,2) DEFAULT 0,           -- From 1099-INT box 2
  alimony_paid DECIMAL(12,2) DEFAULT 0,                       -- Pre-2019 agreements only
  alimony_recipient_ssn TEXT,                                 -- Required if alimony paid
  traditional_ira_deduction DECIMAL(12,2) DEFAULT 0,          -- Traditional IRA deduction
  student_loan_interest DECIMAL(12,2) DEFAULT 0,              -- Up to $2,500
  tuition_fees_deduction DECIMAL(12,2) DEFAULT 0,             -- If applicable for tax year
  other_adjustments DECIMAL(12,2) DEFAULT 0,                  -- Other adjustments
  other_adjustments_description TEXT,
  
  -- Total
  total_adjustments DECIMAL(12,2) DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE (return_id)
);

CREATE INDEX idx_adjustments_return_id ON adjustments_to_income(return_id);

-- =============================================================================
-- 14. DEDUCTIONS (Standard or Itemized)
-- =============================================================================
CREATE TABLE IF NOT EXISTS deductions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Deduction Type Selection
  deduction_type TEXT NOT NULL CHECK (deduction_type IN ('standard', 'itemized')),
  
  -- Standard Deduction (if applicable)
  standard_deduction_amount DECIMAL(12,2) DEFAULT 0,
  
  -- Itemized Deductions (Schedule A)
  -- Medical Expenses
  medical_expenses_total DECIMAL(12,2) DEFAULT 0,
  medical_expenses_threshold DECIMAL(12,2) DEFAULT 0,         -- 7.5% of AGI threshold
  medical_expenses_deductible DECIMAL(12,2) DEFAULT 0,        -- Amount exceeding threshold
  
  -- Taxes Paid (SALT - capped at $10,000)
  state_local_income_tax DECIMAL(12,2) DEFAULT 0,
  state_local_sales_tax DECIMAL(12,2) DEFAULT 0,              -- Alternative to income tax
  real_estate_taxes DECIMAL(12,2) DEFAULT 0,
  personal_property_taxes DECIMAL(12,2) DEFAULT 0,
  salt_total DECIMAL(12,2) DEFAULT 0,                         -- Capped at $10,000
  
  -- Interest Paid
  home_mortgage_interest DECIMAL(12,2) DEFAULT 0,
  home_mortgage_points DECIMAL(12,2) DEFAULT 0,
  investment_interest DECIMAL(12,2) DEFAULT 0,
  
  -- Charitable Contributions
  charitable_cash DECIMAL(12,2) DEFAULT 0,
  charitable_noncash DECIMAL(12,2) DEFAULT 0,
  charitable_carryover DECIMAL(12,2) DEFAULT 0,
  
  -- Casualty & Theft Losses (Federally declared disasters only)
  casualty_theft_losses DECIMAL(12,2) DEFAULT 0,
  
  -- Other Itemized Deductions
  other_itemized DECIMAL(12,2) DEFAULT 0,
  other_itemized_description TEXT,
  
  -- Totals
  total_itemized_deductions DECIMAL(12,2) DEFAULT 0,
  
  -- QBI Deduction (Qualified Business Income - Section 199A)
  qbi_deduction DECIMAL(12,2) DEFAULT 0,
  
  -- Final Deduction Used
  total_deductions DECIMAL(12,2) NOT NULL DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE (return_id)
);

CREATE INDEX idx_deductions_return_id ON deductions(return_id);

-- =============================================================================
-- 15. CREDITS
-- =============================================================================
CREATE TABLE IF NOT EXISTS credits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Nonrefundable Credits (reduce tax liability only to $0)
  child_tax_credit DECIMAL(12,2) DEFAULT 0,                   -- Up to $2,000 per child
  credit_other_dependents DECIMAL(12,2) DEFAULT 0,            -- $500 per dependent
  child_dependent_care_credit DECIMAL(12,2) DEFAULT 0,        -- Up to $3,000 or $6,000 limit
  education_credits_aoc DECIMAL(12,2) DEFAULT 0,              -- American Opportunity Credit
  education_credits_llc DECIMAL(12,2) DEFAULT 0,              -- Lifetime Learning Credit
  retirement_savings_credit DECIMAL(12,2) DEFAULT 0,          -- Saver's Credit
  residential_energy_credit DECIMAL(12,2) DEFAULT 0,          -- Energy efficient improvements
  foreign_tax_credit DECIMAL(12,2) DEFAULT 0,                 -- Taxes paid to foreign countries
  elderly_disabled_credit DECIMAL(12,2) DEFAULT 0,            -- Schedule R
  other_nonrefundable_credits DECIMAL(12,2) DEFAULT 0,
  total_nonrefundable_credits DECIMAL(12,2) DEFAULT 0,
  
  -- Refundable Credits (can result in refund)
  earned_income_credit DECIMAL(12,2) DEFAULT 0,               -- EIC/EITC
  additional_child_tax_credit DECIMAL(12,2) DEFAULT 0,        -- Refundable portion of CTC
  american_opportunity_refundable DECIMAL(12,2) DEFAULT 0,    -- 40% of AOC is refundable
  net_premium_tax_credit DECIMAL(12,2) DEFAULT 0,             -- ACA marketplace credit
  recovery_rebate_credit DECIMAL(12,2) DEFAULT 0,             -- Stimulus payments
  other_refundable_credits DECIMAL(12,2) DEFAULT 0,
  total_refundable_credits DECIMAL(12,2) DEFAULT 0,
  
  -- Total Credits
  total_credits DECIMAL(12,2) DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE (return_id)
);

CREATE INDEX idx_credits_return_id ON credits(return_id);

-- =============================================================================
-- 16. TAX PAYMENTS - Withholdings and Estimated Payments
-- =============================================================================
CREATE TABLE IF NOT EXISTS tax_payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Federal Withholding (from W-2s and 1099s)
  federal_withheld_w2 DECIMAL(12,2) DEFAULT 0,                -- Total from all W-2s
  federal_withheld_1099 DECIMAL(12,2) DEFAULT 0,              -- Total from all 1099s
  federal_withheld_total DECIMAL(12,2) DEFAULT 0,             -- Combined withholding
  
  -- Estimated Tax Payments
  estimated_q1 DECIMAL(12,2) DEFAULT 0,                       -- Q1 payment (April)
  estimated_q2 DECIMAL(12,2) DEFAULT 0,                       -- Q2 payment (June)
  estimated_q3 DECIMAL(12,2) DEFAULT 0,                       -- Q3 payment (September)
  estimated_q4 DECIMAL(12,2) DEFAULT 0,                       -- Q4 payment (January)
  estimated_total DECIMAL(12,2) DEFAULT 0,                    -- Total estimated payments
  
  -- Prior Year Overpayment Applied
  prior_year_overpayment DECIMAL(12,2) DEFAULT 0,
  
  -- Extension Payment
  extension_payment DECIMAL(12,2) DEFAULT 0,
  
  -- Other Payments
  excess_social_security DECIMAL(12,2) DEFAULT 0,             -- Excess SS tax withheld
  other_payments DECIMAL(12,2) DEFAULT 0,
  
  -- Total
  total_payments DECIMAL(12,2) DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE (return_id)
);

CREATE INDEX idx_tax_payments_return_id ON tax_payments(return_id);

-- =============================================================================
-- 17. REFUND PREFERENCES
-- =============================================================================
CREATE TABLE IF NOT EXISTS refund_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Refund Option Selection
  refund_option TEXT NOT NULL CHECK (
    refund_option IN ('direct_deposit', 'paper_check', 'apply_to_next_year', 'split')
  ),
  
  -- Primary Bank Account (encrypted sensitive fields)
  routing_number_encrypted BYTEA,
  account_number_encrypted BYTEA,
  account_type TEXT CHECK (account_type IN ('checking', 'savings')),
  account_last_four TEXT,                                     -- For display purposes
  
  -- Split Refund (Form 8888) - if splitting into multiple accounts
  split_accounts JSONB DEFAULT '[]',                          -- Array of split destinations
  
  -- Apply to Next Year
  apply_to_estimated DECIMAL(12,2) DEFAULT 0,                 -- Amount to apply to next year
  
  -- US Savings Bonds
  savings_bond_purchase DECIMAL(12,2) DEFAULT 0,              -- Purchase I bonds with refund
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE (return_id)
);

CREATE INDEX idx_refund_preferences_return_id ON refund_preferences(return_id);

-- =============================================================================
-- 18. SIGNATURES AND CONSENT
-- =============================================================================
CREATE TABLE IF NOT EXISTS return_signatures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Signer Type
  signer_type TEXT NOT NULL CHECK (signer_type IN ('primary', 'spouse', 'preparer', 'ero')),
  
  -- Signature Method
  signature_method TEXT NOT NULL CHECK (
    signature_method IN ('self_select_pin', 'practitioner_pin', 'irs_signature')
  ),
  
  -- PIN-based Signature (encrypted)
  pin_encrypted BYTEA,
  
  -- Prior Year Authentication
  prior_year_agi_encrypted BYTEA,
  prior_year_pin_encrypted BYTEA,
  
  -- E-Signature Capture
  signature_image_path TEXT,                                  -- Path to signature image
  
  -- Consent & Authorization
  consent_to_disclose BOOLEAN NOT NULL DEFAULT FALSE,
  consent_to_use_info BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Audit Trail
  ip_address INET,
  user_agent TEXT,
  device_fingerprint TEXT,
  signed_at TIMESTAMPTZ NOT NULL,
  
  -- IRS Form 8879 (e-file signature)
  form_8879_signed BOOLEAN DEFAULT FALSE,
  form_8879_date DATE,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- One signature per signer type per return
  UNIQUE (return_id, signer_type)
);

CREATE INDEX idx_return_signatures_return_id ON return_signatures(return_id);

-- =============================================================================
-- 19. E-FILE SUBMISSIONS
-- =============================================================================
CREATE TABLE IF NOT EXISTS efile_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Submission Identification
  submission_id TEXT NOT NULL UNIQUE,                         -- IRS-assigned ID
  submission_type TEXT NOT NULL CHECK (
    submission_type IN ('original', 'amended', 'superseded')
  ),
  
  -- Status Tracking
  status TEXT NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'transmitted', 'accepted', 'rejected')
  ),
  
  -- XML Package
  xml_hash TEXT NOT NULL,                                     -- SHA-256 hash of XML
  xml_storage_path TEXT,                                      -- Path to stored XML
  
  -- Timestamps
  submitted_at TIMESTAMPTZ NOT NULL,
  acknowledgment_received_at TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ,
  rejected_at TIMESTAMPTZ,
  
  -- Rejection Details
  rejection_code TEXT,
  rejection_message TEXT,
  rejection_category TEXT CHECK (
    rejection_category IN ('data_error', 'math_error', 'duplicate', 'identity', 'other')
  ),
  
  -- IRS Response
  raw_acknowledgment JSONB,
  
  -- Retry Information
  retry_count INTEGER DEFAULT 0,
  last_retry_at TIMESTAMPTZ,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_efile_submissions_return_id ON efile_submissions(return_id);
CREATE INDEX idx_efile_submissions_status ON efile_submissions(status);
CREATE INDEX idx_efile_submissions_submission_id ON efile_submissions(submission_id);

-- =============================================================================
-- 20. STATE TAX RETURNS
-- =============================================================================
CREATE TABLE IF NOT EXISTS state_returns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- State Information
  state_code TEXT NOT NULL CHECK (LENGTH(state_code) = 2),
  
  -- Status
  return_status TEXT NOT NULL DEFAULT 'not_started' CHECK (
    return_status IN ('not_started', 'in_progress', 'ready_for_review', 'ready_to_file', 'submitted', 'accepted', 'rejected')
  ),
  
  -- State-specific Calculations
  state_agi DECIMAL(12,2) DEFAULT 0,
  state_taxable_income DECIMAL(12,2) DEFAULT 0,
  state_tax_liability DECIMAL(12,2) DEFAULT 0,
  state_credits DECIMAL(12,2) DEFAULT 0,
  state_withheld DECIMAL(12,2) DEFAULT 0,
  state_payments DECIMAL(12,2) DEFAULT 0,
  state_refund DECIMAL(12,2) DEFAULT 0,
  state_amount_owed DECIMAL(12,2) DEFAULT 0,
  
  -- E-File Status
  efile_status TEXT CHECK (
    efile_status IN ('not_submitted', 'pending', 'transmitted', 'accepted', 'rejected')
  ),
  efile_submission_id TEXT,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- One state return per state per federal return
  UNIQUE (return_id, state_code)
);

CREATE INDEX idx_state_returns_return_id ON state_returns(return_id);

-- =============================================================================
-- 21. AUDIT LOG - Comprehensive audit trail for IRS compliance
-- =============================================================================
CREATE TABLE IF NOT EXISTS tax_audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- User and Return Context
  user_id UUID REFERENCES auth.users(id),
  return_id UUID REFERENCES tax_returns(id),
  
  -- Event Classification
  event_type TEXT NOT NULL CHECK (
    event_type IN ('authentication', 'data_access', 'data_modification', 'calculation', 'submission', 'signature', 'export', 'error')
  ),
  action TEXT NOT NULL,
  
  -- Resource Information
  resource_type TEXT,                                         -- Table/entity affected
  resource_id TEXT,                                           -- ID of affected resource
  
  -- Change Details
  old_value JSONB,                                            -- Previous state
  new_value JSONB,                                            -- New state
  
  -- Client Information
  ip_address INET,
  user_agent TEXT,
  device_fingerprint TEXT,
  session_id TEXT,
  
  -- Additional Context
  metadata JSONB,
  error_details TEXT,
  
  -- Timestamp (immutable)
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create indexes for audit log queries
CREATE INDEX idx_audit_log_user_id ON tax_audit_log(user_id);
CREATE INDEX idx_audit_log_return_id ON tax_audit_log(return_id);
CREATE INDEX idx_audit_log_event_type ON tax_audit_log(event_type);
CREATE INDEX idx_audit_log_created_at ON tax_audit_log(created_at);

-- =============================================================================
-- 22. DOCUMENT STORAGE - Track uploaded tax documents
-- =============================================================================
CREATE TABLE IF NOT EXISTS tax_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id) ON DELETE CASCADE,
  
  -- Document Information
  document_type TEXT NOT NULL CHECK (
    document_type IN ('w2', '1099_int', '1099_div', '1099_r', '1099_nec', '1099_misc', '1099_g', '1099_b', '1099_ssa', 'other')
  ),
  original_filename TEXT NOT NULL,
  storage_path TEXT NOT NULL,                                 -- Supabase Storage path
  
  -- File Details
  file_size INTEGER,
  mime_type TEXT,
  
  -- OCR/Processing Status
  processing_status TEXT DEFAULT 'pending' CHECK (
    processing_status IN ('pending', 'processing', 'completed', 'failed')
  ),
  extracted_data JSONB,                                       -- OCR extracted data
  
  -- Verification
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  verified_by TEXT,
  
  -- Metadata
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tax_documents_return_id ON tax_documents(return_id);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE tax_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE taxpayer_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE dependents ENABLE ROW LEVEL SECURITY;
ALTER TABLE w2_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_1099_int ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_1099_div ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_1099_r ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_1099_nec ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_1099_misc ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_1099_g ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_1099_b ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_1099_ssa ENABLE ROW LEVEL SECURITY;
ALTER TABLE adjustments_to_income ENABLE ROW LEVEL SECURITY;
ALTER TABLE deductions ENABLE ROW LEVEL SECURITY;
ALTER TABLE credits ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE refund_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE return_signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE efile_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE state_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_documents ENABLE ROW LEVEL SECURITY;

-- Tax Returns Policy - Users can only access their own returns
CREATE POLICY "Users can view own tax returns"
  ON tax_returns FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tax returns"
  ON tax_returns FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tax returns"
  ON tax_returns FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tax returns"
  ON tax_returns FOR DELETE
  USING (auth.uid() = user_id);

-- Helper function to check return ownership
CREATE OR REPLACE FUNCTION user_owns_return(return_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM tax_returns 
    WHERE id = return_uuid AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply ownership policy to all child tables
-- Taxpayer Info
CREATE POLICY "Users can manage taxpayer info for own returns"
  ON taxpayer_info FOR ALL
  USING (user_owns_return(return_id));

-- Dependents
CREATE POLICY "Users can manage dependents for own returns"
  ON dependents FOR ALL
  USING (user_owns_return(return_id));

-- W-2 Forms
CREATE POLICY "Users can manage W2 forms for own returns"
  ON w2_forms FOR ALL
  USING (user_owns_return(return_id));

-- 1099-INT
CREATE POLICY "Users can manage 1099-INT for own returns"
  ON form_1099_int FOR ALL
  USING (user_owns_return(return_id));

-- 1099-DIV
CREATE POLICY "Users can manage 1099-DIV for own returns"
  ON form_1099_div FOR ALL
  USING (user_owns_return(return_id));

-- 1099-R
CREATE POLICY "Users can manage 1099-R for own returns"
  ON form_1099_r FOR ALL
  USING (user_owns_return(return_id));

-- 1099-NEC
CREATE POLICY "Users can manage 1099-NEC for own returns"
  ON form_1099_nec FOR ALL
  USING (user_owns_return(return_id));

-- 1099-MISC
CREATE POLICY "Users can manage 1099-MISC for own returns"
  ON form_1099_misc FOR ALL
  USING (user_owns_return(return_id));

-- 1099-G
CREATE POLICY "Users can manage 1099-G for own returns"
  ON form_1099_g FOR ALL
  USING (user_owns_return(return_id));

-- 1099-B
CREATE POLICY "Users can manage 1099-B for own returns"
  ON form_1099_b FOR ALL
  USING (user_owns_return(return_id));

-- 1099-SSA
CREATE POLICY "Users can manage 1099-SSA for own returns"
  ON form_1099_ssa FOR ALL
  USING (user_owns_return(return_id));

-- Adjustments
CREATE POLICY "Users can manage adjustments for own returns"
  ON adjustments_to_income FOR ALL
  USING (user_owns_return(return_id));

-- Deductions
CREATE POLICY "Users can manage deductions for own returns"
  ON deductions FOR ALL
  USING (user_owns_return(return_id));

-- Credits
CREATE POLICY "Users can manage credits for own returns"
  ON credits FOR ALL
  USING (user_owns_return(return_id));

-- Tax Payments
CREATE POLICY "Users can manage payments for own returns"
  ON tax_payments FOR ALL
  USING (user_owns_return(return_id));

-- Refund Preferences
CREATE POLICY "Users can manage refund prefs for own returns"
  ON refund_preferences FOR ALL
  USING (user_owns_return(return_id));

-- Signatures
CREATE POLICY "Users can manage signatures for own returns"
  ON return_signatures FOR ALL
  USING (user_owns_return(return_id));

-- E-File Submissions
CREATE POLICY "Users can view efile submissions for own returns"
  ON efile_submissions FOR SELECT
  USING (user_owns_return(return_id));

CREATE POLICY "Users can insert efile submissions for own returns"
  ON efile_submissions FOR INSERT
  WITH CHECK (user_owns_return(return_id));

-- State Returns
CREATE POLICY "Users can manage state returns for own returns"
  ON state_returns FOR ALL
  USING (user_owns_return(return_id));

-- Audit Log - Users can only view their own audit logs
CREATE POLICY "Users can view own audit logs"
  ON tax_audit_log FOR SELECT
  USING (auth.uid() = user_id);

-- Audit log insert is done via service role (no user policy for insert)
CREATE POLICY "Service can insert audit logs"
  ON tax_audit_log FOR INSERT
  WITH CHECK (true);

-- Tax Documents
CREATE POLICY "Users can manage documents for own returns"
  ON tax_documents FOR ALL
  USING (user_owns_return(return_id));

-- =============================================================================
-- UPDATED_AT TRIGGER FUNCTION
-- =============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to tables with updated_at column
CREATE TRIGGER update_tax_returns_updated_at
  BEFORE UPDATE ON tax_returns
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_taxpayer_info_updated_at
  BEFORE UPDATE ON taxpayer_info
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dependents_updated_at
  BEFORE UPDATE ON dependents
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_w2_forms_updated_at
  BEFORE UPDATE ON w2_forms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_adjustments_updated_at
  BEFORE UPDATE ON adjustments_to_income
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deductions_updated_at
  BEFORE UPDATE ON deductions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_credits_updated_at
  BEFORE UPDATE ON credits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tax_payments_updated_at
  BEFORE UPDATE ON tax_payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_refund_preferences_updated_at
  BEFORE UPDATE ON refund_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_state_returns_updated_at
  BEFORE UPDATE ON state_returns
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- COMMENTS FOR DOCUMENTATION
-- =============================================================================
COMMENT ON TABLE tax_returns IS 'Master table for federal tax returns - one per user per tax year';
COMMENT ON TABLE taxpayer_info IS 'Primary and spouse taxpayer personal information';
COMMENT ON TABLE dependents IS 'Dependent/child information for tax credits';
COMMENT ON TABLE w2_forms IS 'W-2 wage and tax statements from employers';
COMMENT ON TABLE form_1099_int IS '1099-INT interest income from banks/financial institutions';
COMMENT ON TABLE form_1099_div IS '1099-DIV dividend income from investments';
COMMENT ON TABLE form_1099_r IS '1099-R retirement distribution income';
COMMENT ON TABLE form_1099_nec IS '1099-NEC nonemployee compensation (contractor income)';
COMMENT ON TABLE form_1099_misc IS '1099-MISC miscellaneous income';
COMMENT ON TABLE form_1099_g IS '1099-G government payments (unemployment, state refunds)';
COMMENT ON TABLE form_1099_b IS '1099-B broker transactions for capital gains';
COMMENT ON TABLE form_1099_ssa IS 'Social Security benefit statements';
COMMENT ON TABLE adjustments_to_income IS 'Above-the-line deductions (Schedule 1 Part II)';
COMMENT ON TABLE deductions IS 'Standard or itemized deductions (Schedule A)';
COMMENT ON TABLE credits IS 'Tax credits - nonrefundable and refundable';
COMMENT ON TABLE tax_payments IS 'Withholdings and estimated tax payments';
COMMENT ON TABLE refund_preferences IS 'How user wants to receive refund';
COMMENT ON TABLE return_signatures IS 'E-signatures and consent records';
COMMENT ON TABLE efile_submissions IS 'E-file transmission tracking and IRS acknowledgments';
COMMENT ON TABLE state_returns IS 'State tax return information';
COMMENT ON TABLE tax_audit_log IS 'Comprehensive audit trail for IRS compliance';
COMMENT ON TABLE tax_documents IS 'Uploaded tax document storage tracking';
