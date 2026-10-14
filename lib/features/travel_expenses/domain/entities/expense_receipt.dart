import 'dart:typed_data';

class ExpenseReceipt {
  final String id;
  final String conceptId;
  final String concept;
  final double amount;
  final String comments;
  final Uint8List? imageBytes;
  final DateTime createdAt;

  const ExpenseReceipt({required this.id, required this.conceptId,
    required this.concept, required this.amount, required this.comments,
    this.imageBytes, required this.createdAt});
}
