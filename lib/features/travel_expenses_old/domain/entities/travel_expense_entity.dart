class TravelExpenseEntity {
  final int id;
  final String concept;
  final double totalUsed;
  final double paymentTotal;
  final String paymentRequireEvidence;

  TravelExpenseEntity({
    required this.id,
    required this.concept,
    required this.totalUsed,
    required this.paymentTotal,
    required this.paymentRequireEvidence,
  });
}
