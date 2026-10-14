class TableExpenseEntity {
  final int id;
  final String concept;
  final double amount;
  final String? image;

  TableExpenseEntity({
    required this.id,
    required this.concept,
    required this.amount,
    this.image,
  });
}
