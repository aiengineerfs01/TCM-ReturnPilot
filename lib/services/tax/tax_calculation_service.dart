/// =============================================================================
/// Tax Calculation Service
/// 
/// Core service for performing IRS-compliant tax calculations including:
/// - Federal income tax brackets
/// - Standard deductions
/// - Tax credits
/// - FICA taxes
/// - Self-employment tax
/// 
/// Tax Year: 2024
/// Based on IRS Publication 15-T and official tax tables
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/tax_models.dart';

/// Service for calculating federal and state taxes
/// 
/// All calculations follow IRS rules for Tax Year 2024
/// This service is stateless - pass all required data to methods
class TaxCalculationService {
  TaxCalculationService._(); // Private constructor - use static methods

  // ===========================================================================
  // 2024 Tax Constants (IRS Official Values)
  // ===========================================================================

  /// 2024 Federal Tax Brackets
  /// Rates: 10%, 12%, 22%, 24%, 32%, 35%, 37%
  static const Map<FilingStatus, List<TaxBracket>> taxBrackets2024 = {
    FilingStatus.single: [
      TaxBracket(min: 0, max: 11600, rate: 0.10),
      TaxBracket(min: 11600, max: 47150, rate: 0.12),
      TaxBracket(min: 47150, max: 100525, rate: 0.22),
      TaxBracket(min: 100525, max: 191950, rate: 0.24),
      TaxBracket(min: 191950, max: 243725, rate: 0.32),
      TaxBracket(min: 243725, max: 609350, rate: 0.35),
      TaxBracket(min: 609350, max: double.infinity, rate: 0.37),
    ],
    FilingStatus.marriedFilingJointly: [
      TaxBracket(min: 0, max: 23200, rate: 0.10),
      TaxBracket(min: 23200, max: 94300, rate: 0.12),
      TaxBracket(min: 94300, max: 201050, rate: 0.22),
      TaxBracket(min: 201050, max: 383900, rate: 0.24),
      TaxBracket(min: 383900, max: 487450, rate: 0.32),
      TaxBracket(min: 487450, max: 731200, rate: 0.35),
      TaxBracket(min: 731200, max: double.infinity, rate: 0.37),
    ],
    FilingStatus.marriedFilingSeparately: [
      TaxBracket(min: 0, max: 11600, rate: 0.10),
      TaxBracket(min: 11600, max: 47150, rate: 0.12),
      TaxBracket(min: 47150, max: 100525, rate: 0.22),
      TaxBracket(min: 100525, max: 191950, rate: 0.24),
      TaxBracket(min: 191950, max: 243725, rate: 0.32),
      TaxBracket(min: 243725, max: 365600, rate: 0.35),
      TaxBracket(min: 365600, max: double.infinity, rate: 0.37),
    ],
    FilingStatus.headOfHousehold: [
      TaxBracket(min: 0, max: 16550, rate: 0.10),
      TaxBracket(min: 16550, max: 63100, rate: 0.12),
      TaxBracket(min: 63100, max: 100500, rate: 0.22),
      TaxBracket(min: 100500, max: 191950, rate: 0.24),
      TaxBracket(min: 191950, max: 243700, rate: 0.32),
      TaxBracket(min: 243700, max: 609350, rate: 0.35),
      TaxBracket(min: 609350, max: double.infinity, rate: 0.37),
    ],
    FilingStatus.qualifyingWidow: [
      // Same as Married Filing Jointly
      TaxBracket(min: 0, max: 23200, rate: 0.10),
      TaxBracket(min: 23200, max: 94300, rate: 0.12),
      TaxBracket(min: 94300, max: 201050, rate: 0.22),
      TaxBracket(min: 201050, max: 383900, rate: 0.24),
      TaxBracket(min: 383900, max: 487450, rate: 0.32),
      TaxBracket(min: 487450, max: 731200, rate: 0.35),
      TaxBracket(min: 731200, max: double.infinity, rate: 0.37),
    ],
  };

  /// 2024 Standard Deductions
  static const Map<FilingStatus, double> standardDeductions2024 = {
    FilingStatus.single: 14600,
    FilingStatus.marriedFilingJointly: 29200,
    FilingStatus.marriedFilingSeparately: 14600,
    FilingStatus.headOfHousehold: 21900,
    FilingStatus.qualifyingWidow: 29200,
  };

  /// Additional standard deduction for age 65+ or blind (2024)
  static const double additionalStandardDeduction2024Single = 1950;
  static const double additionalStandardDeduction2024Married = 1550;

  /// 2024 FICA Tax Rates
  static const double socialSecurityRate = 0.062; // 6.2%
  static const double medicareRate = 0.0145; // 1.45%
  static const double additionalMedicareRate = 0.009; // 0.9% additional

  /// 2024 Social Security wage base
  static const double socialSecurityWageBase2024 = 168600;

  /// 2024 Additional Medicare threshold
  static const Map<FilingStatus, double> additionalMedicareThreshold2024 = {
    FilingStatus.single: 200000,
    FilingStatus.marriedFilingJointly: 250000,
    FilingStatus.marriedFilingSeparately: 125000,
    FilingStatus.headOfHousehold: 200000,
    FilingStatus.qualifyingWidow: 200000,
  };

  /// 2024 Self-Employment Tax Rate
  static const double selfEmploymentTaxRate = 0.153; // 15.3%
  static const double selfEmploymentDeductionRate = 0.9235; // 92.35%

  /// 2024 Net Investment Income Tax Rate
  static const double niitRate = 0.038; // 3.8%
  static const Map<FilingStatus, double> niitThreshold2024 = {
    FilingStatus.single: 200000,
    FilingStatus.marriedFilingJointly: 250000,
    FilingStatus.marriedFilingSeparately: 125000,
    FilingStatus.headOfHousehold: 200000,
    FilingStatus.qualifyingWidow: 250000,
  };

  /// 2024 Capital Gains Tax Rates
  static const Map<FilingStatus, List<TaxBracket>> capitalGainsBrackets2024 = {
    FilingStatus.single: [
      TaxBracket(min: 0, max: 47025, rate: 0.00),
      TaxBracket(min: 47025, max: 518900, rate: 0.15),
      TaxBracket(min: 518900, max: double.infinity, rate: 0.20),
    ],
    FilingStatus.marriedFilingJointly: [
      TaxBracket(min: 0, max: 94050, rate: 0.00),
      TaxBracket(min: 94050, max: 583750, rate: 0.15),
      TaxBracket(min: 583750, max: double.infinity, rate: 0.20),
    ],
    FilingStatus.marriedFilingSeparately: [
      TaxBracket(min: 0, max: 47025, rate: 0.00),
      TaxBracket(min: 47025, max: 291850, rate: 0.15),
      TaxBracket(min: 291850, max: double.infinity, rate: 0.20),
    ],
    FilingStatus.headOfHousehold: [
      TaxBracket(min: 0, max: 63000, rate: 0.00),
      TaxBracket(min: 63000, max: 551350, rate: 0.15),
      TaxBracket(min: 551350, max: double.infinity, rate: 0.20),
    ],
    FilingStatus.qualifyingWidow: [
      TaxBracket(min: 0, max: 94050, rate: 0.00),
      TaxBracket(min: 94050, max: 583750, rate: 0.15),
      TaxBracket(min: 583750, max: double.infinity, rate: 0.20),
    ],
  };

  // ===========================================================================
  // Tax Calculation Methods
  // ===========================================================================

  /// Calculate federal income tax using progressive brackets
  /// 
  /// Returns detailed breakdown of tax calculation
  static TaxCalculationResult calculateFederalIncomeTax({
    required double taxableIncome,
    required FilingStatus filingStatus,
  }) {
    if (taxableIncome <= 0) {
      return const TaxCalculationResult(
        totalTax: 0,
        effectiveRate: 0,
        marginalRate: 0.10,
        bracketBreakdown: [],
      );
    }

    final brackets = taxBrackets2024[filingStatus]!;
    double totalTax = 0;
    final breakdowns = <BracketBreakdown>[];

    for (final bracket in brackets) {
      if (taxableIncome <= bracket.min) break;

      final taxableInBracket = (taxableIncome > bracket.max
              ? bracket.max
              : taxableIncome) -
          bracket.min;

      if (taxableInBracket > 0) {
        final taxInBracket = taxableInBracket * bracket.rate;
        totalTax += taxInBracket;

        breakdowns.add(BracketBreakdown(
          bracketRate: bracket.rate,
          incomeInBracket: taxableInBracket,
          taxInBracket: taxInBracket,
        ));
      }
    }

    // Find marginal rate
    double marginalRate = 0.10;
    for (final bracket in brackets) {
      if (taxableIncome <= bracket.max) {
        marginalRate = bracket.rate;
        break;
      }
    }

    return TaxCalculationResult(
      totalTax: _roundToTwoDecimals(totalTax),
      effectiveRate: taxableIncome > 0 ? totalTax / taxableIncome : 0,
      marginalRate: marginalRate,
      bracketBreakdown: breakdowns,
    );
  }

  /// Calculate standard deduction with additional amounts for age/blindness
  static double calculateStandardDeduction({
    required FilingStatus filingStatus,
    required bool is65OrOlder,
    required bool isBlind,
    required bool spouseIs65OrOlder,
    required bool spouseIsBlind,
  }) {
    double deduction = standardDeductions2024[filingStatus] ?? 14600;

    // Additional amounts for primary taxpayer
    if (filingStatus == FilingStatus.single ||
        filingStatus == FilingStatus.headOfHousehold) {
      if (is65OrOlder) deduction += additionalStandardDeduction2024Single;
      if (isBlind) deduction += additionalStandardDeduction2024Single;
    } else {
      if (is65OrOlder) deduction += additionalStandardDeduction2024Married;
      if (isBlind) deduction += additionalStandardDeduction2024Married;
    }

    // Additional amounts for spouse (joint filers)
    if (filingStatus == FilingStatus.marriedFilingJointly ||
        filingStatus == FilingStatus.qualifyingWidow) {
      if (spouseIs65OrOlder) {
        deduction += additionalStandardDeduction2024Married;
      }
      if (spouseIsBlind) {
        deduction += additionalStandardDeduction2024Married;
      }
    }

    return deduction;
  }

  /// Calculate long-term capital gains tax
  static double calculateCapitalGainsTax({
    required double capitalGains,
    required double ordinaryIncome,
    required FilingStatus filingStatus,
  }) {
    if (capitalGains <= 0) return 0;

    final brackets = capitalGainsBrackets2024[filingStatus]!;
    double totalTax = 0;
    double remainingGains = capitalGains;

    // Capital gains stack on top of ordinary income for bracket purposes
    double incomeBase = ordinaryIncome;

    for (final bracket in brackets) {
      if (remainingGains <= 0) break;

      // Calculate how much income is already in this bracket
      final incomeInBracket = incomeBase > bracket.min
          ? (incomeBase > bracket.max ? bracket.max : incomeBase) - bracket.min
          : 0;

      // Calculate room left in this bracket
      final bracketSize = bracket.max - bracket.min;
      final roomInBracket = bracketSize - incomeInBracket;

      if (roomInBracket > 0) {
        final gainsInBracket =
            remainingGains > roomInBracket ? roomInBracket : remainingGains;
        totalTax += gainsInBracket * bracket.rate;
        remainingGains -= gainsInBracket;
      }

      incomeBase = incomeBase > bracket.max ? incomeBase : bracket.max;
    }

    return _roundToTwoDecimals(totalTax);
  }

  /// Calculate self-employment tax
  /// 
  /// Self-employment tax = 15.3% on 92.35% of net self-employment income
  /// - Social Security: 12.4% (up to wage base)
  /// - Medicare: 2.9% (no limit)
  /// - Additional Medicare: 0.9% over threshold
  static SelfEmploymentTaxResult calculateSelfEmploymentTax({
    required double netSelfEmploymentIncome,
    required FilingStatus filingStatus,
    double wageIncome = 0,
  }) {
    if (netSelfEmploymentIncome <= 0) {
      return const SelfEmploymentTaxResult(
        totalSeTax: 0,
        socialSecurityTax: 0,
        medicareTax: 0,
        additionalMedicareTax: 0,
        deductiblePortion: 0,
      );
    }

    // Calculate net earnings (92.35% of net SE income)
    final netEarnings = netSelfEmploymentIncome * selfEmploymentDeductionRate;

    // Social Security portion (12.4% up to wage base minus wage income)
    final remainingWageBase = socialSecurityWageBase2024 - wageIncome;
    final socialSecurityBase = netEarnings > remainingWageBase
        ? remainingWageBase
        : netEarnings;
    final double socialSecurityTax = socialSecurityBase > 0
        ? socialSecurityBase * (socialSecurityRate * 2)
        : 0.0;

    // Medicare portion (2.9% on all earnings)
    final medicareTax = netEarnings * (medicareRate * 2);

    // Additional Medicare (0.9% over threshold)
    final threshold = additionalMedicareThreshold2024[filingStatus] ?? 200000;
    final totalEarnings = netEarnings + wageIncome;
    final double additionalMedicareTax =
        totalEarnings > threshold
            ? (totalEarnings - threshold) * additionalMedicareRate
            : 0.0;

    final totalSeTax = socialSecurityTax + medicareTax + additionalMedicareTax;

    // Deductible portion (half of SE tax, excluding additional Medicare)
    final deductiblePortion = (socialSecurityTax + medicareTax) / 2;

    return SelfEmploymentTaxResult(
      totalSeTax: _roundToTwoDecimals(totalSeTax),
      socialSecurityTax: _roundToTwoDecimals(socialSecurityTax),
      medicareTax: _roundToTwoDecimals(medicareTax),
      additionalMedicareTax: _roundToTwoDecimals(additionalMedicareTax),
      deductiblePortion: _roundToTwoDecimals(deductiblePortion),
    );
  }

  /// Calculate Net Investment Income Tax (NIIT)
  /// 
  /// 3.8% on lesser of:
  /// - Net investment income
  /// - Amount by which MAGI exceeds threshold
  static double calculateNiit({
    required double netInvestmentIncome,
    required double magi,
    required FilingStatus filingStatus,
  }) {
    if (netInvestmentIncome <= 0) return 0;

    final threshold = niitThreshold2024[filingStatus] ?? 200000;

    if (magi <= threshold) return 0;

    final excessMagi = magi - threshold;
    final taxableAmount =
        netInvestmentIncome < excessMagi ? netInvestmentIncome : excessMagi;

    return _roundToTwoDecimals(taxableAmount * niitRate);
  }

  // ===========================================================================
  // Credit Calculations
  // ===========================================================================

  /// Calculate Child Tax Credit (CTC) for 2024
  /// 
  /// 2024 Rules:
  /// - $2,000 per qualifying child under 17
  /// - Up to $1,700 refundable as ACTC
  /// - Phase-out: $50 reduction per $1,000 over income threshold
  ///   - Single/HoH: $200,000
  ///   - MFJ: $400,000
  static ChildTaxCreditResult calculateChildTaxCredit({
    required int qualifyingChildren,
    required double agi,
    required FilingStatus filingStatus,
    required double taxLiability,
  }) {
    if (qualifyingChildren <= 0) {
      return const ChildTaxCreditResult(
        totalCredit: 0,
        nonrefundableCredit: 0,
        refundableCredit: 0,
        phaseOutReduction: 0,
      );
    }

    const creditPerChild = 2000.0;
    const maxRefundablePerChild = 1700.0;

    // Income threshold for phase-out
    final threshold = filingStatus == FilingStatus.marriedFilingJointly
        ? 400000.0
        : 200000.0;

    // Calculate initial credit
    double totalCredit = qualifyingChildren * creditPerChild;

    // Calculate phase-out
    double phaseOutReduction = 0;
    if (agi > threshold) {
      // $50 for each $1,000 (or fraction) over threshold
      final excessIncome = agi - threshold;
      final thousands = (excessIncome / 1000).ceil();
      phaseOutReduction = thousands * 50.0;
    }

    // Apply phase-out
    totalCredit = (totalCredit - phaseOutReduction).clamp(0, double.infinity);

    // Non-refundable portion (limited by tax liability)
    final nonrefundableCredit = totalCredit < taxLiability
        ? totalCredit
        : taxLiability;

    // Refundable portion (ACTC)
    final maxRefundable = qualifyingChildren * maxRefundablePerChild;
    final unusedCredit = totalCredit - nonrefundableCredit;
    final refundableCredit = unusedCredit < maxRefundable
        ? unusedCredit
        : maxRefundable;

    return ChildTaxCreditResult(
      totalCredit: _roundToTwoDecimals(totalCredit),
      nonrefundableCredit: _roundToTwoDecimals(nonrefundableCredit),
      refundableCredit: _roundToTwoDecimals(refundableCredit),
      phaseOutReduction: _roundToTwoDecimals(phaseOutReduction),
    );
  }

  /// Calculate Earned Income Credit (EIC) for 2024
  /// 
  /// Complex calculation based on:
  /// - Number of qualifying children (0-3)
  /// - Earned income
  /// - AGI
  /// - Filing status
  /// - Investment income (must be <= $11,600 for 2024)
  static double calculateEarnedIncomeCredit({
    required int qualifyingChildren,
    required double earnedIncome,
    required double agi,
    required FilingStatus filingStatus,
    double investmentIncome = 0,
  }) {
    // EIC not available for MFS
    if (filingStatus == FilingStatus.marriedFilingSeparately) return 0;

    // Investment income limit for 2024 - EIC is disallowed if investment income exceeds this
    const investmentIncomeLimit = 11600.0;
    if (investmentIncome > investmentIncomeLimit) return 0;

    // EIC parameters for 2024
    final eicParams = _getEicParams2024(
      qualifyingChildren: qualifyingChildren,
      isJoint: filingStatus == FilingStatus.marriedFilingJointly ||
          filingStatus == FilingStatus.qualifyingWidow,
    );

    // Use higher of earned income or AGI for phase-out
    final incomeForPhaseOut = agi > earnedIncome ? agi : earnedIncome;

    // Check if over phase-out threshold
    if (incomeForPhaseOut > eicParams.phaseOutEnd) return 0;

    // Calculate credit
    double credit;
    if (earnedIncome <= eicParams.phaseInEnd) {
      // Phase-in: credit increases
      credit = earnedIncome * eicParams.creditRate;
    } else if (incomeForPhaseOut <= eicParams.phaseOutStart) {
      // Maximum credit
      credit = eicParams.maxCredit;
    } else {
      // Phase-out: credit decreases
      final phaseOutAmount = incomeForPhaseOut - eicParams.phaseOutStart;
      credit = eicParams.maxCredit - (phaseOutAmount * eicParams.phaseOutRate);
    }

    return _roundToTwoDecimals(credit.clamp(0, eicParams.maxCredit));
  }

  /// Calculate Retirement Savings Contribution Credit (Saver's Credit)
  /// 
  /// 2024 AGI limits:
  /// - MFJ: $76,500
  /// - HoH: $57,375  
  /// - Single/MFS: $38,250
  static double calculateSaversCredit({
    required double retirementContributions,
    required double agi,
    required FilingStatus filingStatus,
  }) {
    if (retirementContributions <= 0) return 0;

    // Maximum contribution eligible for credit
    const maxContribution = 2000.0;
    final eligibleContribution = retirementContributions < maxContribution
        ? retirementContributions
        : maxContribution;

    // Determine credit rate based on AGI and filing status
    double creditRate;

    switch (filingStatus) {
      case FilingStatus.marriedFilingJointly:
      case FilingStatus.qualifyingWidow:
        if (agi <= 46000) {
          creditRate = 0.50;
        } else if (agi <= 50000) {
          creditRate = 0.20;
        } else if (agi <= 76500) {
          creditRate = 0.10;
        } else {
          creditRate = 0;
        }
        break;
      case FilingStatus.headOfHousehold:
        if (agi <= 34500) {
          creditRate = 0.50;
        } else if (agi <= 37500) {
          creditRate = 0.20;
        } else if (agi <= 57375) {
          creditRate = 0.10;
        } else {
          creditRate = 0;
        }
        break;
      default: // Single, MFS
        if (agi <= 23000) {
          creditRate = 0.50;
        } else if (agi <= 25000) {
          creditRate = 0.20;
        } else if (agi <= 38250) {
          creditRate = 0.10;
        } else {
          creditRate = 0;
        }
    }

    return _roundToTwoDecimals(eligibleContribution * creditRate);
  }

  // ===========================================================================
  // Helper Methods
  // ===========================================================================

  /// Get EIC parameters for 2024
  static _EicParams _getEicParams2024({
    required int qualifyingChildren,
    required bool isJoint,
  }) {
    // 2024 EIC parameters
    if (qualifyingChildren >= 3) {
      return _EicParams(
        creditRate: 0.45,
        phaseOutRate: 0.2106,
        phaseInEnd: 17250,
        phaseOutStart: isJoint ? 27380 : 20130,
        phaseOutEnd: isJoint ? 66819 : 59899,
        maxCredit: 7830,
      );
    } else if (qualifyingChildren == 2) {
      return _EicParams(
        creditRate: 0.40,
        phaseOutRate: 0.2106,
        phaseInEnd: 17250,
        phaseOutStart: isJoint ? 27380 : 20130,
        phaseOutEnd: isJoint ? 59478 : 52427,
        maxCredit: 6960,
      );
    } else if (qualifyingChildren == 1) {
      return _EicParams(
        creditRate: 0.34,
        phaseOutRate: 0.1598,
        phaseInEnd: 11750,
        phaseOutStart: isJoint ? 27380 : 20130,
        phaseOutEnd: isJoint ? 53120 : 46560,
        maxCredit: 3995,
      );
    } else {
      // No children
      return _EicParams(
        creditRate: 0.0765,
        phaseOutRate: 0.0765,
        phaseInEnd: 8260,
        phaseOutStart: isJoint ? 17250 : 10330,
        phaseOutEnd: isJoint ? 25511 : 18591,
        maxCredit: 632,
      );
    }
  }

  /// Round to two decimal places
  static double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}

// =============================================================================
// Supporting Classes
// =============================================================================

/// Tax bracket definition
class TaxBracket {
  final double min;
  final double max;
  final double rate;

  const TaxBracket({
    required this.min,
    required this.max,
    required this.rate,
  });
}

/// Result of federal income tax calculation
class TaxCalculationResult {
  final double totalTax;
  final double effectiveRate;
  final double marginalRate;
  final List<BracketBreakdown> bracketBreakdown;

  const TaxCalculationResult({
    required this.totalTax,
    required this.effectiveRate,
    required this.marginalRate,
    required this.bracketBreakdown,
  });
}

/// Breakdown of tax within each bracket
class BracketBreakdown {
  final double bracketRate;
  final double incomeInBracket;
  final double taxInBracket;

  const BracketBreakdown({
    required this.bracketRate,
    required this.incomeInBracket,
    required this.taxInBracket,
  });
}

/// Result of self-employment tax calculation
class SelfEmploymentTaxResult {
  final double totalSeTax;
  final double socialSecurityTax;
  final double medicareTax;
  final double additionalMedicareTax;
  final double deductiblePortion;

  const SelfEmploymentTaxResult({
    required this.totalSeTax,
    required this.socialSecurityTax,
    required this.medicareTax,
    required this.additionalMedicareTax,
    required this.deductiblePortion,
  });
}

/// Result of Child Tax Credit calculation
class ChildTaxCreditResult {
  final double totalCredit;
  final double nonrefundableCredit;
  final double refundableCredit;
  final double phaseOutReduction;

  const ChildTaxCreditResult({
    required this.totalCredit,
    required this.nonrefundableCredit,
    required this.refundableCredit,
    required this.phaseOutReduction,
  });
}

/// Internal EIC parameters
class _EicParams {
  final double creditRate;
  final double phaseOutRate;
  final double phaseInEnd;
  final double phaseOutStart;
  final double phaseOutEnd;
  final double maxCredit;

  const _EicParams({
    required this.creditRate,
    required this.phaseOutRate,
    required this.phaseInEnd,
    required this.phaseOutStart,
    required this.phaseOutEnd,
    required this.maxCredit,
  });
}
