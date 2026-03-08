# Refund Options & Disbursement

## Overview

This document details IRS refund disbursement options, direct deposit requirements, refund transfer products, and split refund functionality for e-filed returns.

---

## 1. Refund Disbursement Options

### 1.1 Available Options

```dart
enum RefundOption {
  directDeposit,       // IRS deposits directly to bank account
  paperCheck,          // IRS mails paper check
  splitRefund,         // Divide among multiple accounts (Form 8888)
  savingsBond,         // Purchase US Series I Savings Bonds
  refundTransfer,      // Refund Transfer Product (bank product)
}

class RefundPreferences {
  final RefundOption primaryOption;
  final BankAccount? directDepositAccount;
  final List<SplitRefundAllocation>? splitAllocations;
  final double? savingsBondAmount;
  final RefundTransferProduct? refundTransfer;
  
  const RefundPreferences({
    required this.primaryOption,
    this.directDepositAccount,
    this.splitAllocations,
    this.savingsBondAmount,
    this.refundTransfer,
  });
  
  bool get isValid {
    switch (primaryOption) {
      case RefundOption.directDeposit:
        return directDepositAccount != null && directDepositAccount!.isValid;
      case RefundOption.paperCheck:
        return true;
      case RefundOption.splitRefund:
        return splitAllocations != null && 
               splitAllocations!.isNotEmpty &&
               _validateSplitAllocations();
      case RefundOption.savingsBond:
        return savingsBondAmount != null && savingsBondAmount! >= 50;
      case RefundOption.refundTransfer:
        return refundTransfer != null;
    }
  }
  
  bool _validateSplitAllocations() {
    if (splitAllocations == null) return false;
    // Max 3 accounts for split refund
    if (splitAllocations!.length > 3) return false;
    // All allocations must be valid
    return splitAllocations!.every((a) => a.isValid);
  }
}
```

### 1.2 Direct Deposit Model

```dart
class BankAccount {
  final String routingNumber;    // 9 digits
  final String accountNumber;    // 4-17 digits
  final BankAccountType accountType;
  final String? bankName;        // Optional, for display
  
  // Encrypted storage
  final String? encryptedRoutingNumber;
  final String? encryptedAccountNumber;
  final String lastFourAccount;
  
  const BankAccount({
    required this.routingNumber,
    required this.accountNumber,
    required this.accountType,
    this.bankName,
    this.encryptedRoutingNumber,
    this.encryptedAccountNumber,
    required this.lastFourAccount,
  });
  
  bool get isValid {
    return _isValidRoutingNumber(routingNumber) &&
           _isValidAccountNumber(accountNumber);
  }
  
  // Routing number validation (ABA checksum)
  static bool _isValidRoutingNumber(String routing) {
    if (!RegExp(r'^\d{9}$').hasMatch(routing)) return false;
    
    // ABA checksum algorithm
    final digits = routing.split('').map(int.parse).toList();
    final checksum = 
        3 * (digits[0] + digits[3] + digits[6]) +
        7 * (digits[1] + digits[4] + digits[7]) +
        1 * (digits[2] + digits[5] + digits[8]);
    
    return checksum % 10 == 0;
  }
  
  static bool _isValidAccountNumber(String account) {
    // 4-17 digits
    return RegExp(r'^\d{4,17}$').hasMatch(account);
  }
  
  // Mask account number for display
  String get maskedAccountNumber => '****$lastFourAccount';
  
  // Mask routing number for display
  String get maskedRoutingNumber => '****${routingNumber.substring(5)}';
}

enum BankAccountType { 
  checking,  // Code 1 in XML
  savings,   // Code 2 in XML
}
```

---

## 2. Split Refund (Form 8888)

### 2.1 Split Refund Model

```dart
/// IRS Form 8888 - Allocation of Refund
class Form8888 {
  final List<SplitRefundAllocation> allocations;
  final double totalRefund;
  
  const Form8888({
    required this.allocations,
    required this.totalRefund,
  });
  
  bool get isValid {
    // Must have at least 2 allocations (otherwise use direct deposit)
    if (allocations.length < 2) return false;
    // Max 3 accounts
    if (allocations.length > 3) return false;
    // Total must equal refund amount
    final allocatedTotal = allocations.fold<double>(
      0, (sum, a) => sum + a.amount);
    if ((allocatedTotal - totalRefund).abs() > 0.01) return false;
    // All allocations valid
    return allocations.every((a) => a.isValid);
  }
  
  // XML representation for e-file
  Map<String, dynamic> toXml() => {
    'IRS8888': {
      allocations.asMap().map((i, a) => MapEntry(
        'RefundDirectDepositGrp${i + 1}',
        a.toXml(),
      )),
    },
  };
}

class SplitRefundAllocation {
  final double amount;
  final AllocationType type;
  final BankAccount? bankAccount;
  final SavingsBondPurchase? savingsBond;
  
  const SplitRefundAllocation({
    required this.amount,
    required this.type,
    this.bankAccount,
    this.savingsBond,
  });
  
  bool get isValid {
    // Amount must be at least $1
    if (amount < 1) return false;
    
    switch (type) {
      case AllocationType.directDeposit:
        return bankAccount != null && bankAccount!.isValid;
      case AllocationType.savingsBond:
        return savingsBond != null && savingsBond!.isValid;
    }
  }
  
  Map<String, dynamic> toXml() {
    if (type == AllocationType.directDeposit) {
      return {
        'RoutingTransitNum': bankAccount!.routingNumber,
        'BankAccountTypeCd': bankAccount!.accountType == BankAccountType.checking ? '1' : '2',
        'DepositorAccountNum': bankAccount!.accountNumber,
        'RefundAmt': amount.toStringAsFixed(0),
      };
    } else {
      return {
        'SavingsBondAmt': amount.toStringAsFixed(0),
        'CoOwnerNm': savingsBond!.coOwnerName,
      };
    }
  }
}

enum AllocationType {
  directDeposit,
  savingsBond,
}
```

### 2.2 Savings Bond Purchase

```dart
class SavingsBondPurchase {
  final double amount;           // Must be multiple of $50
  final String? coOwnerName;     // Optional co-owner
  
  const SavingsBondPurchase({
    required this.amount,
    this.coOwnerName,
  });
  
  bool get isValid {
    // Minimum $50
    if (amount < 50) return false;
    // Must be multiple of $50
    if (amount % 50 != 0) return false;
    // Maximum $5,000 per return
    if (amount > 5000) return false;
    return true;
  }
}
```

---

## 3. Refund Transfer Products

### 3.1 Bank Product Integration

```dart
/// Refund Transfer Product (RT/RAC/RAL)
/// These are bank products that allow fees to be deducted from refund
class RefundTransferProduct {
  final BankProductType productType;
  final String bankPartnerCode;
  final BankAccount temporaryAccount;  // Bank-provided temporary account
  final double processingFee;
  final double? additionalFees;
  final List<RefundTransferFee> feeBreakdown;
  
  const RefundTransferProduct({
    required this.productType,
    required this.bankPartnerCode,
    required this.temporaryAccount,
    required this.processingFee,
    this.additionalFees,
    required this.feeBreakdown,
  });
  
  double get totalFees => feeBreakdown.fold<double>(
    0, (sum, fee) => sum + fee.amount);
  
  double calculateNetRefund(double grossRefund) {
    return grossRefund - totalFees;
  }
}

enum BankProductType {
  refundTransfer,          // RT - Refund Transfer
  refundAnticipationCheck, // RAC - Check mailed when refund received
  refundAdvance,           // RA - Advance loan against expected refund
}

class RefundTransferFee {
  final String description;
  final double amount;
  final FeeType type;
  
  const RefundTransferFee({
    required this.description,
    required this.amount,
    required this.type,
  });
}

enum FeeType {
  bankFee,
  transmitterFee,
  serviceBureauFee,
  stateFee,
  other,
}
```

### 3.2 Bank Product Disclosure

```dart
class BankProductDisclosure {
  // Required disclosures per IRS/FTC regulations
  
  static const requiredDisclosures = [
    'This is an optional product. You can receive your refund by direct deposit or check at no additional cost.',
    'Your refund will be deposited into a temporary bank account. After fees are deducted, the remaining amount will be sent to you.',
    'If your refund is less than expected, the bank product fee will still be deducted.',
    'If your return is rejected or audited, there may be delays in receiving your refund.',
  ];
  
  final double expectedRefund;
  final double totalFees;
  final double netProceeds;
  final String productDescription;
  final List<RefundTransferFee> feeBreakdown;
  final DateTime estimatedFundingDate;
  
  const BankProductDisclosure({
    required this.expectedRefund,
    required this.totalFees,
    required this.netProceeds,
    required this.productDescription,
    required this.feeBreakdown,
    required this.estimatedFundingDate,
  });
  
  String generateDisclosureText() {
    final buffer = StringBuffer();
    
    buffer.writeln('REFUND TRANSFER PRODUCT DISCLOSURE');
    buffer.writeln('');
    buffer.writeln('Expected Federal Refund: \$${expectedRefund.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('Fees to be deducted:');
    
    for (final fee in feeBreakdown) {
      buffer.writeln('  ${fee.description}: \$${fee.amount.toStringAsFixed(2)}');
    }
    
    buffer.writeln('');
    buffer.writeln('Total Fees: \$${totalFees.toStringAsFixed(2)}');
    buffer.writeln('Net Amount to You: \$${netProceeds.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('Estimated Funding: ${DateFormat('MMMM d, yyyy').format(estimatedFundingDate)}');
    buffer.writeln('');
    
    for (final disclosure in requiredDisclosures) {
      buffer.writeln('• $disclosure');
    }
    
    return buffer.toString();
  }
}
```

---

## 4. Refund Status Tracking

### 4.1 IRS Refund Status Model

```dart
enum RefundStatus {
  returnReceived,      // IRS received the return
  returnApproved,      // Return approved, refund calculated
  refundSent,          // Refund sent (direct deposit or check mailed)
  refundDeposited,     // Direct deposit confirmed
  unknown,             // Unable to determine status
}

class RefundStatusInfo {
  final RefundStatus status;
  final DateTime? lastUpdated;
  final double? approvedAmount;
  final DateTime? expectedDate;
  final String? statusMessage;
  final List<RefundStatusHistory> history;
  
  const RefundStatusInfo({
    required this.status,
    this.lastUpdated,
    this.approvedAmount,
    this.expectedDate,
    this.statusMessage,
    this.history = const [],
  });
  
  String get userFriendlyMessage {
    return switch (status) {
      RefundStatus.returnReceived => 
        'Your return has been received and is being processed.',
      RefundStatus.returnApproved => 
        'Your return has been approved! Your refund of \$${approvedAmount?.toStringAsFixed(2) ?? "N/A"} is being processed.',
      RefundStatus.refundSent => 
        'Your refund has been sent! ${_getSentMessage()}',
      RefundStatus.refundDeposited =>
        'Your refund has been deposited to your bank account.',
      RefundStatus.unknown =>
        'We\'re unable to determine your refund status. Please check back later or visit irs.gov/refunds.',
    };
  }
  
  String _getSentMessage() {
    if (expectedDate != null) {
      return 'Expected deposit date: ${DateFormat('MMMM d, yyyy').format(expectedDate!)}';
    }
    return 'Check your bank account in 1-5 business days.';
  }
}

class RefundStatusHistory {
  final RefundStatus status;
  final DateTime timestamp;
  final String? note;
  
  const RefundStatusHistory({
    required this.status,
    required this.timestamp,
    this.note,
  });
}
```

### 4.2 Where's My Refund Integration

```dart
class RefundStatusService {
  // Note: This would integrate with IRS Where's My Refund API
  // For demo purposes, this shows the expected interface
  
  Future<RefundStatusInfo> checkRefundStatus({
    required String ssn,
    required FilingStatus filingStatus,
    required double expectedRefund,
    required int taxYear,
  }) async {
    // In production, this would call IRS API
    // IRS requires SSN, filing status, and exact refund amount
    
    // Simulated response
    return RefundStatusInfo(
      status: RefundStatus.returnReceived,
      lastUpdated: DateTime.now(),
      statusMessage: 'Your return is being processed.',
    );
  }
  
  // IRS typically updates status once per day
  static const updateFrequency = Duration(hours: 24);
  
  // Typical refund timeline
  static const typicalTimelines = {
    'e-file_direct_deposit': '21 days or less',
    'e-file_check': '4 weeks',
    'paper_direct_deposit': '4 weeks',
    'paper_check': '6-8 weeks',
  };
}
```

---

## 5. Refund Selection UI

### 5.1 Refund Options Screen

```dart
class RefundOptionsScreen extends GetView<RefundController> {
  const RefundOptionsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refund Options')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Refund Amount Display
            _RefundAmountCard(
              amount: controller.refundAmount,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'How would you like to receive your refund?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            
            const SizedBox(height: 16),
            
            // Direct Deposit Option
            Obx(() => _RefundOptionCard(
              title: 'Direct Deposit',
              subtitle: 'Fastest option - typically 21 days or less',
              icon: Icons.account_balance,
              isSelected: controller.selectedOption.value == RefundOption.directDeposit,
              onTap: () => controller.selectOption(RefundOption.directDeposit),
              recommended: true,
            )),
            
            const SizedBox(height: 12),
            
            // Paper Check Option
            Obx(() => _RefundOptionCard(
              title: 'Paper Check',
              subtitle: 'Mailed to your address - 4-6 weeks',
              icon: Icons.mail,
              isSelected: controller.selectedOption.value == RefundOption.paperCheck,
              onTap: () => controller.selectOption(RefundOption.paperCheck),
            )),
            
            const SizedBox(height: 12),
            
            // Split Refund Option
            Obx(() => _RefundOptionCard(
              title: 'Split Your Refund',
              subtitle: 'Deposit into up to 3 accounts',
              icon: Icons.call_split,
              isSelected: controller.selectedOption.value == RefundOption.splitRefund,
              onTap: () => controller.selectOption(RefundOption.splitRefund),
            )),
            
            const SizedBox(height: 24),
            
            // Bank Account Entry (if direct deposit selected)
            Obx(() {
              if (controller.selectedOption.value == RefundOption.directDeposit) {
                return _BankAccountEntry(controller: controller);
              }
              return const SizedBox.shrink();
            }),
            
            // Split Refund Entry (if split selected)
            Obx(() {
              if (controller.selectedOption.value == RefundOption.splitRefund) {
                return _SplitRefundEntry(controller: controller);
              }
              return const SizedBox.shrink();
            }),
            
            const SizedBox(height: 32),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.canContinue ? controller.saveAndContinue : null,
                child: const Text('Continue'),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefundAmountCard extends StatelessWidget {
  final double amount;
  
  const _RefundAmountCard({required this.amount});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Your Federal Refund',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefundOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool recommended;
  
  const _RefundOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.recommended = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5.2 Bank Account Entry Widget

```dart
class _BankAccountEntry extends StatelessWidget {
  final RefundController controller;
  
  const _BankAccountEntry({required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Account Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Account Type
            Text('Account Type', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Obx(() => Row(
              children: [
                Expanded(
                  child: _AccountTypeButton(
                    label: 'Checking',
                    isSelected: controller.accountType.value == BankAccountType.checking,
                    onTap: () => controller.accountType.value = BankAccountType.checking,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AccountTypeButton(
                    label: 'Savings',
                    isSelected: controller.accountType.value == BankAccountType.savings,
                    onTap: () => controller.accountType.value = BankAccountType.savings,
                  ),
                ),
              ],
            )),
            
            const SizedBox(height: 16),
            
            // Routing Number
            TextField(
              controller: controller.routingController,
              keyboardType: TextInputType.number,
              maxLength: 9,
              decoration: InputDecoration(
                labelText: 'Routing Number',
                hintText: '9 digits',
                counterText: '',
                prefixIcon: const Icon(Icons.tag),
                errorText: controller.routingError.value,
              ),
              onChanged: controller.validateRouting,
            ),
            
            const SizedBox(height: 16),
            
            // Account Number
            TextField(
              controller: controller.accountController,
              keyboardType: TextInputType.number,
              maxLength: 17,
              obscureText: !controller.showAccountNumber.value,
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: '4-17 digits',
                counterText: '',
                prefixIcon: const Icon(Icons.account_balance),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showAccountNumber.value 
                        ? Icons.visibility_off 
                        : Icons.visibility,
                  ),
                  onPressed: () => controller.showAccountNumber.toggle(),
                ),
                errorText: controller.accountError.value,
              ),
              onChanged: controller.validateAccount,
            ),
            
            const SizedBox(height: 16),
            
            // Confirm Account Number
            TextField(
              controller: controller.confirmAccountController,
              keyboardType: TextInputType.number,
              maxLength: 17,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Account Number',
                counterText: '',
                prefixIcon: const Icon(Icons.account_balance),
                errorText: controller.confirmAccountError.value,
              ),
              onChanged: controller.validateConfirmAccount,
            ),
            
            const SizedBox(height: 16),
            
            // Bank check image helper
            _BankCheckHelper(),
          ],
        ),
      ),
    );
  }
}

class _BankCheckHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Where do I find these numbers?'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Check diagram
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Routing number indicator
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: Colors.blue.shade100,
                            child: const Text('⎸123456789⎸', style: TextStyle(fontFamily: 'monospace')),
                          ),
                          const Text('Routing Number', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    // Account number indicator
                    Positioned(
                      bottom: 20,
                      left: 140,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: Colors.green.shade100,
                            child: const Text('⎸987654321⎸', style: TextStyle(fontFamily: 'monospace')),
                          ),
                          const Text('Account Number', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Look at the bottom of a check from your account. '
                'The routing number is the first 9 digits, followed by your account number.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## 6. Database Schema

```sql
-- Refund Preferences
CREATE TABLE refund_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  refund_option TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Bank Accounts (encrypted)
CREATE TABLE refund_bank_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preference_id UUID NOT NULL REFERENCES refund_preferences(id),
  routing_number_encrypted BYTEA NOT NULL,
  account_number_encrypted BYTEA NOT NULL,
  account_type TEXT NOT NULL,
  last_four TEXT NOT NULL,
  bank_name TEXT,
  allocation_order INTEGER DEFAULT 1,
  allocation_amount DECIMAL(12,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Refund Status Tracking
CREATE TABLE refund_status (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  status TEXT NOT NULL,
  status_date TIMESTAMPTZ NOT NULL,
  approved_amount DECIMAL(12,2),
  expected_date DATE,
  status_message TEXT,
  raw_response JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refund_status_return ON refund_status(return_id);

-- RLS Policies
ALTER TABLE refund_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE refund_bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE refund_status ENABLE ROW LEVEL SECURITY;

CREATE POLICY refund_owner_access ON refund_preferences
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY bank_owner_access ON refund_bank_accounts
  FOR ALL USING (
    preference_id IN (SELECT id FROM refund_preferences WHERE user_id = auth.uid())
  );

CREATE POLICY status_owner_access ON refund_status
  FOR ALL USING (
    return_id IN (SELECT id FROM tax_returns WHERE user_id = auth.uid())
  );
```

---

## 7. Implementation Checklist

- [ ] Implement RefundPreferences model
- [ ] Create BankAccount model with validation
- [ ] Implement Form8888 for split refunds
- [ ] Build refund options selection UI
- [ ] Create bank account entry widget
- [ ] Add routing number validation (ABA checksum)
- [ ] Implement account number encryption
- [ ] Create split refund allocation UI
- [ ] Build refund status tracking
- [ ] Add refund amount display
- [ ] Create database tables
- [ ] Implement XML generation for refund info

---

## 8. Related Documents

- [E-File Transmission](./efile_transmission.md)
- [Security Compliance](./security_compliance.md)
- [Tax Forms](./tax_forms.md)
- [Signature & Consent](./signature_consent.md)
