// lib/models/payment.dart
class Payment {
  final int id;
  final int userId;
  final DateTime paymentDate;
  final double amount;
  final String status;
  final String? labourName;

  Payment({
    required this.id,
    required this.userId,
    required this.paymentDate,
    required this.amount,
    required this.status,
    this.labourName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      paymentDate: DateTime.parse(json['paymentDate']),
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PAID',
      labourName: json['labourName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'paymentDate': paymentDate.toIso8601String().split('T')[0],
      'amount': amount,
      'status': status,
    };
  }

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';

  String get formattedDate => '${paymentDate.day} ${_getMonth(paymentDate.month)} ${paymentDate.year}';
}

String _getMonth(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}
