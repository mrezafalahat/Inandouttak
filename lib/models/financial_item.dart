class FinancialItem {
  final int? id;
  final String documentDate;
  final String cashEffectDate;
  final String documentNumber;
  final String description;
  final double amount;
  final String kind; // receivable, payable, manual_receipt, manual_payment
  final String sourceType; // excel, manual
  final String sourceName;
  final String status;
  final int includeInForecast;
  final int isActive;
  final String uniqueKey;
  final String createdAt;
  final String updatedAt;

  const FinancialItem({
    this.id,
    required this.documentDate,
    required this.cashEffectDate,
    required this.documentNumber,
    required this.description,
    required this.amount,
    required this.kind,
    required this.sourceType,
    required this.sourceName,
    required this.status,
    required this.includeInForecast,
    required this.isActive,
    required this.uniqueKey,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'document_date': documentDate,
        'cash_effect_date': cashEffectDate,
        'document_number': documentNumber,
        'description': description,
        'amount': amount,
        'kind': kind,
        'source_type': sourceType,
        'source_name': sourceName,
        'status': status,
        'include_in_forecast': includeInForecast,
        'is_active': isActive,
        'unique_key': uniqueKey,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory FinancialItem.fromMap(Map<String, Object?> map) => FinancialItem(
        id: map['id'] as int?,
        documentDate: (map['document_date'] ?? '').toString(),
        cashEffectDate: (map['cash_effect_date'] ?? '').toString(),
        documentNumber: (map['document_number'] ?? '').toString(),
        description: (map['description'] ?? '').toString(),
        amount: ((map['amount'] ?? 0) as num).toDouble(),
        kind: (map['kind'] ?? '').toString(),
        sourceType: (map['source_type'] ?? '').toString(),
        sourceName: (map['source_name'] ?? '').toString(),
        status: (map['status'] ?? '').toString(),
        includeInForecast: (map['include_in_forecast'] ?? 1) as int,
        isActive: (map['is_active'] ?? 1) as int,
        uniqueKey: (map['unique_key'] ?? '').toString(),
        createdAt: (map['created_at'] ?? '').toString(),
        updatedAt: (map['updated_at'] ?? '').toString(),
      );

  FinancialItem copyWith({
    int? id,
    String? documentDate,
    String? cashEffectDate,
    String? documentNumber,
    String? description,
    double? amount,
    String? kind,
    String? sourceType,
    String? sourceName,
    String? status,
    int? includeInForecast,
    int? isActive,
    String? uniqueKey,
    String? createdAt,
    String? updatedAt,
  }) =>
      FinancialItem(
        id: id ?? this.id,
        documentDate: documentDate ?? this.documentDate,
        cashEffectDate: cashEffectDate ?? this.cashEffectDate,
        documentNumber: documentNumber ?? this.documentNumber,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        kind: kind ?? this.kind,
        sourceType: sourceType ?? this.sourceType,
        sourceName: sourceName ?? this.sourceName,
        status: status ?? this.status,
        includeInForecast: includeInForecast ?? this.includeInForecast,
        isActive: isActive ?? this.isActive,
        uniqueKey: uniqueKey ?? this.uniqueKey,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class BankBalance {
  final int? id;
  final String bankName;
  final double amount;
  final String balanceDate;
  final String updatedAt;

  const BankBalance({
    this.id,
    required this.bankName,
    required this.amount,
    required this.balanceDate,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'bank_name': bankName,
        'amount': amount,
        'balance_date': balanceDate,
        'updated_at': updatedAt,
      };

  factory BankBalance.fromMap(Map<String, Object?> map) => BankBalance(
        id: map['id'] as int?,
        bankName: (map['bank_name'] ?? '').toString(),
        amount: ((map['amount'] ?? 0) as num).toDouble(),
        balanceDate: (map['balance_date'] ?? '').toString(),
        updatedAt: (map['updated_at'] ?? '').toString(),
      );
}
