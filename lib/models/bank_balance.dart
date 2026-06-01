class BankBalance {
  final int? id;
  final String bankName;
  final int amount;
  final String date;

  const BankBalance({this.id, required this.bankName, required this.amount, required this.date});

  Map<String, Object?> toMap() => {
        'id': id,
        'bank_name': bankName,
        'amount': amount,
        'date': date,
      };

  factory BankBalance.fromMap(Map<String, Object?> map) => BankBalance(
        id: map['id'] as int?,
        bankName: (map['bank_name'] ?? '') as String,
        amount: (map['amount'] ?? 0) as int,
        date: (map['date'] ?? '') as String,
      );
}
