class TableExpenseEntity {
  final int id;
  final String concept;
  final double amount;
  final int? image;

  TableExpenseEntity(
      {required this.id,
      required this.concept,
      required this.amount,
      this.image});
}
