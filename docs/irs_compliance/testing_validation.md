# Testing & Validation Guide

## Overview

This document details IRS testing requirements, ATES (Assurance Testing System) certification, test scenarios, and comprehensive validation strategies for e-file software.

---

## 1. IRS Testing Requirements

### 1.1 ATES Certification Overview

```dart
/// IRS Assurance Testing System (ATES)
/// Required before transmitting to production MeF
/// Tests cover all return types software supports

class ATESRequirements {
  // Testing phases
  static const phases = [
    'Development Testing',     // Internal validation
    'ATES Submission',        // Submit test returns to IRS
    'ATES Review',            // IRS reviews submissions
    'Certification',          // IRS certifies software
    'Production Access',      // Access to production MeF
  ];
  
  // Required test scenarios per form type
  static const requiredScenarios = {
    'Form1040': [
      'Single filer, simple W-2 income',
      'MFJ with two W-2s',
      'HOH with dependents',
      'MFS with itemized deductions',
      'QW with capital gains',
      'Self-employment income (Schedule C)',
      'Rental income (Schedule E)',
      'All filing statuses',
      'Standard vs itemized deductions',
      'All major credits (CTC, EIC, education)',
      'Rejection scenarios',
    ],
    'StateReturns': [
      'Resident return',
      'Non-resident return',
      'Part-year resident',
      'Multi-state filing',
    ],
  };
  
  // Test return categories
  static const testCategories = {
    'acceptance': 'Returns that should be accepted',
    'rejection': 'Returns that should be rejected',
    'businessRule': 'Business rule validation tests',
    'calculation': 'Calculation verification tests',
  };
}
```

### 1.2 Test Scenarios Model

```dart
class ATESTestScenario {
  final String id;
  final String name;
  final String description;
  final TestCategory category;
  final FilingStatus filingStatus;
  final List<String> requiredForms;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> expectedOutput;
  final String? expectedRejectionCode;
  
  const ATESTestScenario({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.filingStatus,
    required this.requiredForms,
    required this.inputData,
    required this.expectedOutput,
    this.expectedRejectionCode,
  });
}

enum TestCategory {
  acceptance,
  rejection,
  businessRule,
  calculation,
}

// Example test scenarios
class StandardTestScenarios {
  static final scenarios = [
    ATESTestScenario(
      id: 'ATES-001',
      name: 'Simple Single Filer',
      description: 'Single taxpayer with one W-2, standard deduction',
      category: TestCategory.acceptance,
      filingStatus: FilingStatus.single,
      requiredForms: ['1040', 'W-2'],
      inputData: {
        'taxpayer': {
          'ssn': '400-00-0001',
          'firstName': 'John',
          'lastName': 'TestSingle',
          'dateOfBirth': '1985-06-15',
        },
        'w2s': [{
          'employerEIN': '12-3456789',
          'wages': 50000.00,
          'federalWithheld': 5000.00,
        }],
      },
      expectedOutput: {
        'totalIncome': 50000.00,
        'agi': 50000.00,
        'standardDeduction': 14600.00,
        'taxableIncome': 35400.00,
        'totalTax': 4006.00,
        'refundOrOwed': 994.00, // Refund
      },
    ),
    
    ATESTestScenario(
      id: 'ATES-002',
      name: 'MFJ with Dependents',
      description: 'Married filing jointly with 2 qualifying children',
      category: TestCategory.acceptance,
      filingStatus: FilingStatus.marriedFilingJointly,
      requiredForms: ['1040', 'W-2', 'Schedule 8812'],
      inputData: {
        'taxpayer': {
          'ssn': '400-00-0002',
          'firstName': 'Robert',
          'lastName': 'TestJoint',
        },
        'spouse': {
          'ssn': '400-00-0003',
          'firstName': 'Sarah',
          'lastName': 'TestJoint',
        },
        'dependents': [
          {'ssn': '400-00-0004', 'firstName': 'Child1', 'age': 8},
          {'ssn': '400-00-0005', 'firstName': 'Child2', 'age': 12},
        ],
        'w2s': [
          {'wages': 75000.00, 'federalWithheld': 8000.00},
          {'wages': 45000.00, 'federalWithheld': 4500.00},
        ],
      },
      expectedOutput: {
        'totalIncome': 120000.00,
        'childTaxCredit': 4000.00,
        'refundOrOwed': 1234.00, // Example
      },
    ),
    
    ATESTestScenario(
      id: 'ATES-REJ-001',
      name: 'SSN Mismatch Rejection',
      description: 'Return should be rejected for SSN/name mismatch',
      category: TestCategory.rejection,
      filingStatus: FilingStatus.single,
      requiredForms: ['1040'],
      inputData: {
        'taxpayer': {
          'ssn': '400-00-9999', // Invalid test SSN
          'firstName': 'Wrong',
          'lastName': 'Name',
        },
      },
      expectedOutput: {},
      expectedRejectionCode: 'IND-031',
    ),
  ];
}
```

---

## 2. Test Execution Framework

### 2.1 Test Runner

```dart
class ATESTestRunner {
  final TaxCalculationService _calculator;
  final XMLGeneratorService _xmlGenerator;
  final ValidationService _validator;
  final TestReportGenerator _reportGenerator;
  
  ATESTestRunner(
    this._calculator,
    this._xmlGenerator,
    this._validator,
    this._reportGenerator,
  );
  
  Future<ATESTestReport> runAllTests(List<ATESTestScenario> scenarios) async {
    final results = <ATESTestResult>[];
    
    for (final scenario in scenarios) {
      final result = await runTest(scenario);
      results.add(result);
    }
    
    return _reportGenerator.generateReport(results);
  }
  
  Future<ATESTestResult> runTest(ATESTestScenario scenario) async {
    try {
      // 1. Create test return from input data
      final testReturn = _createTestReturn(scenario);
      
      // 2. Run calculations
      final calculation = await _calculator.calculate(testReturn);
      
      // 3. Validate return
      final validationResult = await _validator.validate(testReturn);
      
      // 4. Generate XML
      final xml = await _xmlGenerator.generate(testReturn);
      
      // 5. Compare results
      final comparison = _compareResults(
        actual: {
          'totalIncome': calculation.totalIncome,
          'agi': calculation.agi,
          'taxableIncome': calculation.taxableIncome,
          'totalTax': calculation.totalTax,
          'refundOrOwed': calculation.refundOrOwed,
        },
        expected: scenario.expectedOutput,
      );
      
      // 6. Check for expected rejection
      if (scenario.category == TestCategory.rejection) {
        final hasExpectedRejection = validationResult.errors
            .any((e) => e.code == scenario.expectedRejectionCode);
        
        return ATESTestResult(
          scenarioId: scenario.id,
          passed: hasExpectedRejection,
          category: scenario.category,
          expectedRejection: scenario.expectedRejectionCode,
          actualRejection: validationResult.errors.firstOrNull?.code,
          message: hasExpectedRejection 
              ? 'Expected rejection received' 
              : 'Did not receive expected rejection',
        );
      }
      
      // 7. Return result for acceptance tests
      return ATESTestResult(
        scenarioId: scenario.id,
        passed: comparison.allMatch && validationResult.isValid,
        category: scenario.category,
        expectedValues: scenario.expectedOutput,
        actualValues: comparison.actualValues,
        differences: comparison.differences,
        validationErrors: validationResult.errors,
        generatedXML: xml,
      );
      
    } catch (e, stackTrace) {
      return ATESTestResult(
        scenarioId: scenario.id,
        passed: false,
        category: scenario.category,
        message: 'Test execution error: $e',
        stackTrace: stackTrace.toString(),
      );
    }
  }
  
  TaxReturn _createTestReturn(ATESTestScenario scenario) {
    final input = scenario.inputData;
    
    return TaxReturn(
      id: 'test-${scenario.id}',
      oderId: 'test-user',
      taxYear: DateTime.now().year - 1,
      filingStatus: scenario.filingStatus,
      status: ReturnStatus.inProgress,
      primaryTaxpayer: TaxpayerInfo(
        firstName: input['taxpayer']['firstName'],
        lastName: input['taxpayer']['lastName'],
        ssn: input['taxpayer']['ssn'],
        dateOfBirth: DateTime.parse(input['taxpayer']['dateOfBirth'] ?? '1980-01-01'),
        address: Address.test(),
      ),
      income: _buildIncomeData(input),
      // ... other properties
    );
  }
  
  _ComparisonResult _compareResults({
    required Map<String, dynamic> actual,
    required Map<String, dynamic> expected,
  }) {
    final differences = <String, _ValueDifference>{};
    bool allMatch = true;
    
    for (final key in expected.keys) {
      final expectedValue = expected[key];
      final actualValue = actual[key];
      
      // Allow small tolerance for floating point
      if (expectedValue is num && actualValue is num) {
        if ((expectedValue - actualValue).abs() > 0.01) {
          differences[key] = _ValueDifference(expected: expectedValue, actual: actualValue);
          allMatch = false;
        }
      } else if (expectedValue != actualValue) {
        differences[key] = _ValueDifference(expected: expectedValue, actual: actualValue);
        allMatch = false;
      }
    }
    
    return _ComparisonResult(
      allMatch: allMatch,
      actualValues: actual,
      differences: differences,
    );
  }
}

class ATESTestResult {
  final String scenarioId;
  final bool passed;
  final TestCategory category;
  final Map<String, dynamic>? expectedValues;
  final Map<String, dynamic>? actualValues;
  final Map<String, _ValueDifference>? differences;
  final List<ValidationError>? validationErrors;
  final String? expectedRejection;
  final String? actualRejection;
  final String? generatedXML;
  final String? message;
  final String? stackTrace;
  
  const ATESTestResult({
    required this.scenarioId,
    required this.passed,
    required this.category,
    this.expectedValues,
    this.actualValues,
    this.differences,
    this.validationErrors,
    this.expectedRejection,
    this.actualRejection,
    this.generatedXML,
    this.message,
    this.stackTrace,
  });
}

class _ComparisonResult {
  final bool allMatch;
  final Map<String, dynamic> actualValues;
  final Map<String, _ValueDifference> differences;
  
  const _ComparisonResult({
    required this.allMatch,
    required this.actualValues,
    required this.differences,
  });
}

class _ValueDifference {
  final dynamic expected;
  final dynamic actual;
  
  const _ValueDifference({required this.expected, required this.actual});
}
```

### 2.2 Test Report Generator

```dart
class TestReportGenerator {
  ATESTestReport generateReport(List<ATESTestResult> results) {
    final passedTests = results.where((r) => r.passed).length;
    final failedTests = results.where((r) => !r.passed).length;
    
    final byCategory = <TestCategory, CategorySummary>{};
    for (final category in TestCategory.values) {
      final categoryResults = results.where((r) => r.category == category).toList();
      byCategory[category] = CategorySummary(
        total: categoryResults.length,
        passed: categoryResults.where((r) => r.passed).length,
        failed: categoryResults.where((r) => !r.passed).length,
      );
    }
    
    return ATESTestReport(
      runDate: DateTime.now(),
      totalTests: results.length,
      passed: passedTests,
      failed: failedTests,
      passRate: passedTests / results.length * 100,
      categoryBreakdown: byCategory,
      results: results,
      recommendations: _generateRecommendations(results),
    );
  }
  
  List<String> _generateRecommendations(List<ATESTestResult> results) {
    final recommendations = <String>[];
    
    // Check for calculation failures
    final calcFailures = results
        .where((r) => !r.passed && r.differences != null && r.differences!.isNotEmpty)
        .toList();
    
    if (calcFailures.isNotEmpty) {
      recommendations.add(
        'Review tax calculation logic - ${calcFailures.length} tests have calculation discrepancies',
      );
    }
    
    // Check for validation failures
    final validationFailures = results
        .where((r) => r.validationErrors != null && r.validationErrors!.isNotEmpty)
        .toList();
    
    if (validationFailures.isNotEmpty) {
      recommendations.add(
        'Review validation rules - ${validationFailures.length} tests have validation errors',
      );
    }
    
    // Check rejection test coverage
    final rejectionTests = results.where((r) => r.category == TestCategory.rejection).toList();
    if (rejectionTests.isEmpty) {
      recommendations.add('Add rejection test scenarios to ensure error handling works correctly');
    }
    
    return recommendations;
  }
  
  String generateHTMLReport(ATESTestReport report) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <title>ATES Test Report - ${DateFormat('yyyy-MM-dd HH:mm').format(report.runDate)}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .summary { background: #f5f5f5; padding: 20px; border-radius: 8px; }
    .passed { color: green; }
    .failed { color: red; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background: #4CAF50; color: white; }
    tr:nth-child(even) { background: #f2f2f2; }
    .category-badge { 
      padding: 4px 8px; 
      border-radius: 4px; 
      font-size: 12px;
    }
    .acceptance { background: #e3f2fd; }
    .rejection { background: #fff3e0; }
    .calculation { background: #e8f5e9; }
  </style>
</head>
<body>
  <h1>ATES Test Report</h1>
  <p>Generated: ${DateFormat('MMMM d, yyyy HH:mm').format(report.runDate)}</p>
  
  <div class="summary">
    <h2>Summary</h2>
    <p><strong>Total Tests:</strong> ${report.totalTests}</p>
    <p><strong class="passed">Passed:</strong> ${report.passed}</p>
    <p><strong class="failed">Failed:</strong> ${report.failed}</p>
    <p><strong>Pass Rate:</strong> ${report.passRate.toStringAsFixed(1)}%</p>
  </div>
  
  <h2>Category Breakdown</h2>
  <table>
    <tr>
      <th>Category</th>
      <th>Total</th>
      <th>Passed</th>
      <th>Failed</th>
    </tr>
    ${report.categoryBreakdown.entries.map((e) => '''
    <tr>
      <td>${e.key.name}</td>
      <td>${e.value.total}</td>
      <td class="passed">${e.value.passed}</td>
      <td class="failed">${e.value.failed}</td>
    </tr>
    ''').join()}
  </table>
  
  <h2>Test Results</h2>
  <table>
    <tr>
      <th>Scenario</th>
      <th>Category</th>
      <th>Status</th>
      <th>Details</th>
    </tr>
    ${report.results.map((r) => '''
    <tr>
      <td>${r.scenarioId}</td>
      <td><span class="category-badge ${r.category.name}">${r.category.name}</span></td>
      <td class="${r.passed ? 'passed' : 'failed'}">${r.passed ? 'PASSED' : 'FAILED'}</td>
      <td>${r.message ?? (r.differences?.isNotEmpty == true ? 'Value differences found' : '-')}</td>
    </tr>
    ''').join()}
  </table>
  
  ${report.recommendations.isNotEmpty ? '''
  <h2>Recommendations</h2>
  <ul>
    ${report.recommendations.map((r) => '<li>$r</li>').join()}
  </ul>
  ''' : ''}
</body>
</html>
''';
  }
}

class ATESTestReport {
  final DateTime runDate;
  final int totalTests;
  final int passed;
  final int failed;
  final double passRate;
  final Map<TestCategory, CategorySummary> categoryBreakdown;
  final List<ATESTestResult> results;
  final List<String> recommendations;
  
  const ATESTestReport({
    required this.runDate,
    required this.totalTests,
    required this.passed,
    required this.failed,
    required this.passRate,
    required this.categoryBreakdown,
    required this.results,
    required this.recommendations,
  });
}

class CategorySummary {
  final int total;
  final int passed;
  final int failed;
  
  const CategorySummary({
    required this.total,
    required this.passed,
    required this.failed,
  });
}
```

---

## 3. Unit Testing

### 3.1 Tax Calculation Tests

```dart
// test/services/tax_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaxCalculator', () {
    late TaxCalculator calculator;
    
    setUp(() {
      calculator = TaxCalculator();
    });
    
    group('Tax Brackets 2024', () {
      test('Single filer - 10% bracket only', () {
        final tax = calculator.calculateTax(
          taxableIncome: 10000,
          filingStatus: FilingStatus.single,
          taxYear: 2024,
        );
        
        expect(tax, equals(1000.00)); // 10% of 10,000
      });
      
      test('Single filer - multiple brackets', () {
        final tax = calculator.calculateTax(
          taxableIncome: 50000,
          filingStatus: FilingStatus.single,
          taxYear: 2024,
        );
        
        // 11,600 * 10% = 1,160
        // (47,150 - 11,600) * 12% = 4,266
        // (50,000 - 47,150) * 22% = 627
        // Total = 6,053
        expect(tax, closeTo(6053.00, 0.01));
      });
      
      test('MFJ - higher brackets', () {
        final tax = calculator.calculateTax(
          taxableIncome: 500000,
          filingStatus: FilingStatus.marriedFilingJointly,
          taxYear: 2024,
        );
        
        // Calculate expected tax through brackets
        expect(tax, greaterThan(100000)); // Sanity check
      });
    });
    
    group('Standard Deduction', () {
      test('Single filer standard deduction 2024', () {
        final deduction = calculator.getStandardDeduction(
          filingStatus: FilingStatus.single,
          taxYear: 2024,
        );
        
        expect(deduction, equals(14600));
      });
      
      test('MFJ standard deduction 2024', () {
        final deduction = calculator.getStandardDeduction(
          filingStatus: FilingStatus.marriedFilingJointly,
          taxYear: 2024,
        );
        
        expect(deduction, equals(29200));
      });
      
      test('HOH standard deduction 2024', () {
        final deduction = calculator.getStandardDeduction(
          filingStatus: FilingStatus.headOfHousehold,
          taxYear: 2024,
        );
        
        expect(deduction, equals(21900));
      });
    });
    
    group('Child Tax Credit', () {
      test('Full credit for one qualifying child', () {
        final credit = calculator.calculateChildTaxCredit(
          qualifyingChildren: 1,
          agi: 50000,
          filingStatus: FilingStatus.single,
        );
        
        expect(credit, equals(2000));
      });
      
      test('Credit phases out at high income', () {
        final credit = calculator.calculateChildTaxCredit(
          qualifyingChildren: 1,
          agi: 250000,
          filingStatus: FilingStatus.single,
        );
        
        expect(credit, lessThan(2000));
      });
      
      test('No credit above threshold', () {
        final credit = calculator.calculateChildTaxCredit(
          qualifyingChildren: 1,
          agi: 500000,
          filingStatus: FilingStatus.single,
        );
        
        expect(credit, equals(0));
      });
    });
    
    group('Earned Income Credit', () {
      test('EIC for single with no children', () {
        final credit = calculator.calculateEIC(
          earnedIncome: 10000,
          agi: 10000,
          qualifyingChildren: 0,
          filingStatus: FilingStatus.single,
        );
        
        expect(credit, greaterThan(0));
        expect(credit, lessThanOrEqualTo(632)); // 2024 max for 0 children
      });
      
      test('EIC phases out at higher income', () {
        final creditLow = calculator.calculateEIC(
          earnedIncome: 10000,
          agi: 10000,
          qualifyingChildren: 1,
          filingStatus: FilingStatus.single,
        );
        
        final creditHigh = calculator.calculateEIC(
          earnedIncome: 40000,
          agi: 40000,
          qualifyingChildren: 1,
          filingStatus: FilingStatus.single,
        );
        
        expect(creditLow, greaterThan(creditHigh));
      });
    });
  });
}
```

### 3.2 Validation Tests

```dart
// test/services/validation_test.dart

void main() {
  group('SSN Validation', () {
    test('Valid SSN format passes', () {
      expect(SSNValidator.isValidFormat('123-45-6789'), isTrue);
      expect(SSNValidator.isValidFormat('123456789'), isTrue);
    });
    
    test('Invalid area numbers fail', () {
      expect(SSNValidator.isValidFormat('000-12-3456'), isFalse); // 000
      expect(SSNValidator.isValidFormat('666-12-3456'), isFalse); // 666
      expect(SSNValidator.isValidFormat('900-12-3456'), isFalse); // 900+
    });
    
    test('Invalid group numbers fail', () {
      expect(SSNValidator.isValidFormat('123-00-6789'), isFalse);
    });
    
    test('Invalid serial numbers fail', () {
      expect(SSNValidator.isValidFormat('123-45-0000'), isFalse);
    });
    
    test('Advertising SSNs fail', () {
      expect(SSNValidator.isValidFormat('078-05-1120'), isFalse);
    });
  });
  
  group('EIN Validation', () {
    test('Valid EIN format passes', () {
      expect(EINValidator.isValidFormat('12-3456789'), isTrue);
      expect(EINValidator.isValidFormat('123456789'), isTrue);
    });
    
    test('Invalid EIN format fails', () {
      expect(EINValidator.isValidFormat('12-345678'), isFalse); // Too short
      expect(EINValidator.isValidFormat('12-34567890'), isFalse); // Too long
      expect(EINValidator.isValidFormat('00-0000000'), isFalse); // Invalid prefix
    });
  });
  
  group('Bank Routing Number Validation', () {
    test('Valid routing number passes checksum', () {
      // Using a known valid routing number pattern
      expect(BankAccount.isValidRoutingNumber('021000021'), isTrue);
    });
    
    test('Invalid checksum fails', () {
      expect(BankAccount.isValidRoutingNumber('123456789'), isFalse);
    });
    
    test('Wrong length fails', () {
      expect(BankAccount.isValidRoutingNumber('12345678'), isFalse);
      expect(BankAccount.isValidRoutingNumber('1234567890'), isFalse);
    });
  });
  
  group('Address Validation', () {
    test('Valid US address passes', () {
      final address = Address(
        street1: '123 Main Street',
        city: 'Springfield',
        state: 'IL',
        zipCode: '62701',
      );
      
      expect(AddressValidator.isValid(address), isTrue);
    });
    
    test('Invalid state code fails', () {
      final address = Address(
        street1: '123 Main Street',
        city: 'Springfield',
        state: 'XX', // Invalid
        zipCode: '62701',
      );
      
      expect(AddressValidator.isValid(address), isFalse);
    });
    
    test('Invalid zip code format fails', () {
      final address = Address(
        street1: '123 Main Street',
        city: 'Springfield',
        state: 'IL',
        zipCode: '1234', // Too short
      );
      
      expect(AddressValidator.isValid(address), isFalse);
    });
  });
}
```

### 3.3 Integration Tests

```dart
// integration_test/e_file_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('E-File Flow Integration', () {
    testWidgets('Complete return creation and validation', (tester) async {
      // 1. Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // 2. Navigate to create return
      await tester.tap(find.text('Start New Return'));
      await tester.pumpAndSettle();
      
      // 3. Enter taxpayer info
      await tester.enterText(find.byKey(Key('firstName')), 'John');
      await tester.enterText(find.byKey(Key('lastName')), 'Test');
      await tester.enterText(find.byKey(Key('ssn')), '400-00-0001');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // 4. Select filing status
      await tester.tap(find.text('Single'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // 5. Add W-2
      await tester.tap(find.text('Add W-2'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('employerEIN')), '12-3456789');
      await tester.enterText(find.byKey(Key('wages')), '50000');
      await tester.enterText(find.byKey(Key('federalWithheld')), '5000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // 6. Review and calculate
      await tester.tap(find.text('Review Return'));
      await tester.pumpAndSettle();
      
      // 7. Verify calculations displayed
      expect(find.textContaining('50,000'), findsOneWidget); // Total income
      expect(find.textContaining('Refund'), findsOneWidget);
      
      // 8. Validate return
      await tester.tap(find.text('Check for Errors'));
      await tester.pumpAndSettle();
      
      expect(find.text('No errors found'), findsOneWidget);
    });
    
    testWidgets('Validation catches missing required fields', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to create return without entering data
      await tester.tap(find.text('Start New Return'));
      await tester.pumpAndSettle();
      
      // Try to continue without entering required fields
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // Verify validation errors shown
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('SSN is required'), findsOneWidget);
    });
  });
}
```

---

## 4. XML Schema Validation

### 4.1 Schema Validator

```dart
class XMLSchemaValidator {
  final Map<String, xml.XmlDocument> _schemas = {};
  
  XMLSchemaValidator() {
    _loadSchemas();
  }
  
  void _loadSchemas() {
    // Load IRS MeF XML schemas
    // In production, these would be loaded from schema files
  }
  
  ValidationResult validateReturn(String xmlContent, int taxYear) {
    final errors = <SchemaValidationError>[];
    
    try {
      final document = xml.XmlDocument.parse(xmlContent);
      
      // Validate structure
      errors.addAll(_validateStructure(document));
      
      // Validate required elements
      errors.addAll(_validateRequiredElements(document));
      
      // Validate data types
      errors.addAll(_validateDataTypes(document));
      
      // Validate business rules
      errors.addAll(_validateBusinessRules(document));
      
      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
      );
      
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: [
          SchemaValidationError(
            path: '/',
            code: 'PARSE_ERROR',
            message: 'Failed to parse XML: $e',
          ),
        ],
      );
    }
  }
  
  List<SchemaValidationError> _validateRequiredElements(xml.XmlDocument doc) {
    final errors = <SchemaValidationError>[];
    
    // Check for required Form 1040 elements
    final requiredElements = [
      'ReturnHeader',
      'ReturnData',
      'IRS1040',
    ];
    
    for (final element in requiredElements) {
      if (doc.findAllElements(element).isEmpty) {
        errors.add(SchemaValidationError(
          path: '/$element',
          code: 'MISSING_ELEMENT',
          message: 'Required element $element is missing',
        ));
      }
    }
    
    return errors;
  }
  
  List<SchemaValidationError> _validateDataTypes(xml.XmlDocument doc) {
    final errors = <SchemaValidationError>[];
    
    // Validate SSN format
    for (final ssn in doc.findAllElements('SSN')) {
      if (!RegExp(r'^\d{9}$').hasMatch(ssn.text)) {
        errors.add(SchemaValidationError(
          path: _getPath(ssn),
          code: 'INVALID_FORMAT',
          message: 'SSN must be 9 digits',
        ));
      }
    }
    
    // Validate amount formats
    for (final amount in doc.findAllElements('Amount')) {
      if (double.tryParse(amount.text) == null) {
        errors.add(SchemaValidationError(
          path: _getPath(amount),
          code: 'INVALID_FORMAT',
          message: 'Amount must be a valid number',
        ));
      }
    }
    
    return errors;
  }
  
  String _getPath(xml.XmlElement element) {
    final path = <String>[];
    xml.XmlNode? current = element;
    
    while (current != null && current is xml.XmlElement) {
      path.insert(0, current.name.local);
      current = current.parent;
    }
    
    return '/' + path.join('/');
  }
}

class SchemaValidationError {
  final String path;
  final String code;
  final String message;
  
  const SchemaValidationError({
    required this.path,
    required this.code,
    required this.message,
  });
}
```

---

## 5. Performance Testing

### 5.1 Load Testing

```dart
class PerformanceTestSuite {
  Future<PerformanceReport> runPerformanceTests() async {
    final results = <PerformanceTestResult>[];
    
    // Test 1: Tax calculation performance
    results.add(await _testCalculationPerformance());
    
    // Test 2: XML generation performance
    results.add(await _testXMLGenerationPerformance());
    
    // Test 3: Validation performance
    results.add(await _testValidationPerformance());
    
    // Test 4: Database query performance
    results.add(await _testDatabasePerformance());
    
    return PerformanceReport(results: results);
  }
  
  Future<PerformanceTestResult> _testCalculationPerformance() async {
    final calculator = TaxCalculator();
    final stopwatch = Stopwatch();
    final iterations = 1000;
    
    stopwatch.start();
    for (var i = 0; i < iterations; i++) {
      calculator.calculateTax(
        taxableIncome: 75000 + (i % 100000),
        filingStatus: FilingStatus.values[i % 5],
        taxYear: 2024,
      );
    }
    stopwatch.stop();
    
    return PerformanceTestResult(
      testName: 'Tax Calculation',
      iterations: iterations,
      totalTime: stopwatch.elapsedMilliseconds,
      averageTime: stopwatch.elapsedMilliseconds / iterations,
      threshold: 1.0, // Max 1ms per calculation
      passed: (stopwatch.elapsedMilliseconds / iterations) < 1.0,
    );
  }
  
  Future<PerformanceTestResult> _testXMLGenerationPerformance() async {
    final generator = XMLGeneratorService();
    final testReturn = _createComplexTestReturn();
    final stopwatch = Stopwatch();
    final iterations = 100;
    
    stopwatch.start();
    for (var i = 0; i < iterations; i++) {
      await generator.generateReturnXML(testReturn);
    }
    stopwatch.stop();
    
    return PerformanceTestResult(
      testName: 'XML Generation',
      iterations: iterations,
      totalTime: stopwatch.elapsedMilliseconds,
      averageTime: stopwatch.elapsedMilliseconds / iterations,
      threshold: 100.0, // Max 100ms per generation
      passed: (stopwatch.elapsedMilliseconds / iterations) < 100.0,
    );
  }
}

class PerformanceTestResult {
  final String testName;
  final int iterations;
  final int totalTime;
  final double averageTime;
  final double threshold;
  final bool passed;
  
  const PerformanceTestResult({
    required this.testName,
    required this.iterations,
    required this.totalTime,
    required this.averageTime,
    required this.threshold,
    required this.passed,
  });
}
```

---

## 6. Test Data Management

### 6.1 Test Data Factory

```dart
class TestDataFactory {
  static TaxReturn createSimpleReturn({
    FilingStatus filingStatus = FilingStatus.single,
    double wages = 50000,
  }) {
    return TaxReturn(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      oderId: 'test-user',
      taxYear: 2024,
      filingStatus: filingStatus,
      status: ReturnStatus.inProgress,
      primaryTaxpayer: _createTestTaxpayer(),
      income: IncomeData(
        totalWages: wages,
        w2s: [_createTestW2(wages: wages)],
      ),
      adjustments: AdjustmentsToIncome(),
      deductions: DeductionData(
        deductionType: DeductionType.standard,
        standardDeduction: 14600,
        totalDeductions: 14600,
      ),
      credits: CreditData(),
      taxCalculation: TaxCalculation.empty(),
      payments: PaymentData(
        federalWithholding: wages * 0.10,
        refundableCredits: 0,
        totalPayments: wages * 0.10,
      ),
      refund: RefundData(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  static TaxReturn createComplexReturn({
    required FilingStatus filingStatus,
    required int dependentCount,
    required List<double> w2Wages,
    bool hasScheduleC = false,
    bool hasScheduleE = false,
    bool itemizedDeductions = false,
  }) {
    // Build complex test return with all scenarios
    return TaxReturn(/* ... */);
  }
  
  static TaxpayerInfo _createTestTaxpayer({
    String? ssn,
    String? firstName,
    String? lastName,
  }) {
    return TaxpayerInfo(
      firstName: firstName ?? 'Test',
      lastName: lastName ?? 'Taxpayer',
      ssn: ssn ?? '400-00-${_randomDigits(4)}',
      dateOfBirth: DateTime(1980, 1, 1),
      address: Address(
        street1: '123 Test Street',
        city: 'Testville',
        state: 'TX',
        zipCode: '75001',
      ),
    );
  }
  
  static W2Form _createTestW2({
    double wages = 50000,
    double federalWithheld = 5000,
  }) {
    return W2Form(
      id: 'test-w2-${DateTime.now().millisecondsSinceEpoch}',
      employerEIN: '12-3456789',
      employerName: 'Test Employer Inc',
      employerAddress: Address(
        street1: '456 Business Ave',
        city: 'Commerce City',
        state: 'CA',
        zipCode: '90001',
      ),
      box1Wages: wages,
      box2FederalWithheld: federalWithheld,
      box3SocialSecurityWages: wages,
      box4SocialSecurityTax: wages * 0.062,
      box5MedicareWages: wages,
      box6MedicareTax: wages * 0.0145,
    );
  }
  
  static String _randomDigits(int count) {
    final random = Random();
    return List.generate(count, (_) => random.nextInt(10)).join();
  }
}
```

---

## 7. Implementation Checklist

- [ ] Set up ATES test account with IRS
- [ ] Create comprehensive test scenarios
- [ ] Implement automated test runner
- [ ] Build test report generator
- [ ] Create unit tests for all calculations
- [ ] Add validation tests
- [ ] Implement integration tests
- [ ] Set up XML schema validation
- [ ] Create performance test suite
- [ ] Build test data factory
- [ ] Run ATES certification tests
- [ ] Document test results
- [ ] Obtain IRS certification

---

## 8. Related Documents

- [Calculations](./calculations.md)
- [E-File Transmission](./efile_transmission.md)
- [Error Handling](./error_handling.md)
- [API Integration](./api_integration.md)
