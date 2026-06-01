enum CashflowType { positive, negative }
enum CashflowSource { manual, excel }

class CashflowItem {
  final int? id;
  final String jalaliDate;
  final String gregorianDate;
  final String description;
  final int amount;
  final CashflowType type;
  final bool includeInBalance;
  final CashflowSource source;
  final String? sourceFileName;
  final String uniqueKey;
  final int balanceAfter;

  const CashflowItem({
    this.id,
    required this.jalaliDate,
    required this.gregorianDate,
    required this.description,
    required this.amount,
    required this.type,
    required this.includeInBalance,
    required this.source,
    this.sourceFileName,
    required this.uniqueKey,
    this.balanceAfter = 0,
  });

  int get signedAmount {
    if (!includeInBalance) return 0;
    return type == CashflowType.positive ? amount : -amount;
  }

  CashflowItem copyWith({
    int? id,
    String? jalaliDate,
    String? gregorianDate,
    String? description,
    int? amount,
    CashflowType? type,
    bool? includeInBalance,
    CashflowSource? source,
    String? sourceFileName,
    String? uniqueKey,
    int? balanceAfter,
  }) {
    return CashflowItem(
      id: id ?? this.id,
      jalaliDate: jalaliDate ?? this.jalaliDate,
      gregorianDate: gregorianDate ?? this.gregorianDate,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      includeInBalance: includeInBalance ?? this.includeInBalance,
      source: source ?? this.source,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      uniqueKey: uniqueKey ?? this.uniqueKey,
      balanceAfter: balanceAfter ?? this.balanceAfter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jalaliDate': jalaliDate,
      'gregorianDate': gregorianDate,
      'description': description,
      'amount': amount,
      'type': type.name,
      'includeInBalance': includeInBalance ? 1 : 0,
      'source': source.name,
      'sourceFileName': sourceFileName,
      'uniqueKey': uniqueKey,
      'balanceAfter': balanceAfter,
    };
  }

  factory CashflowItem.fromMap(Map<String, dynamic> map) {
    return CashflowItem(
      id: map['id'] as int?,
      jalaliDate: map['jalaliDate'] as String,
      gregorianDate: map['gregorianDate'] as String,
      description: map['description'] as String,
      amount: map['amount'] as int,
      type: map['type'] == 'positive' ? CashflowType.positive : CashflowType.negative,
      includeInBalance: map['includeInBalance'] == 1,
      source: map['source'] == 'excel' ? CashflowSource.excel : CashflowSource.manual,
      sourceFileName: map['sourceFileName'] as String?,
      uniqueKey: map['uniqueKey'] as String,
      balanceAfter: map['balanceAfter'] as int? ?? 0,
    );
  }
}
