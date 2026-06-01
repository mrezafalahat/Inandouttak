class CashItem {
  final int? id;
  final String stableKey;
  final String date;
  final String effectDate;
  final String docNo;
  final String description;
  final int amount;
  final String itemType; // receivable, payable, manual_income, manual_expense
  final String sourceType; // excel, manual
  final String sourceName;
  final String status;
  final bool includeInForecast;
  final bool active;

  const CashItem({
    this.id,
    required this.stableKey,
    required this.date,
    required this.effectDate,
    required this.docNo,
    required this.description,
    required this.amount,
    required this.itemType,
    required this.sourceType,
    required this.sourceName,
    required this.status,
    required this.includeInForecast,
    required this.active,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'stable_key': stableKey,
        'date': date,
        'effect_date': effectDate,
        'doc_no': docNo,
        'description': description,
        'amount': amount,
        'item_type': itemType,
        'source_type': sourceType,
        'source_name': sourceName,
        'status': status,
        'include_in_forecast': includeInForecast ? 1 : 0,
        'active': active ? 1 : 0,
      };

  factory CashItem.fromMap(Map<String, Object?> map) => CashItem(
        id: map['id'] as int?,
        stableKey: (map['stable_key'] ?? '') as String,
        date: (map['date'] ?? '') as String,
        effectDate: (map['effect_date'] ?? '') as String,
        docNo: (map['doc_no'] ?? '') as String,
        description: (map['description'] ?? '') as String,
        amount: (map['amount'] ?? 0) as int,
        itemType: (map['item_type'] ?? '') as String,
        sourceType: (map['source_type'] ?? '') as String,
        sourceName: (map['source_name'] ?? '') as String,
        status: (map['status'] ?? '') as String,
        includeInForecast: (map['include_in_forecast'] ?? 1) == 1,
        active: (map['active'] ?? 1) == 1,
      );
}
