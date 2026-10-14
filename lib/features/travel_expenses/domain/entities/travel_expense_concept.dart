class TravelExpenseConcept {
  final String id;
  final String travelExpenseRequestId;
  final String concept;
  final double amount;
  final bool evidenceRequired;
  final double? evidenceAmount;
  final DateTime? evidenceDateTime;
  final String? fileUrl;

  const TravelExpenseConcept({required this.id, required this.travelExpenseRequestId,
    required this.concept, required this.amount, required this.evidenceRequired,
    this.evidenceAmount, this.evidenceDateTime, this.fileUrl});

  bool get isRegistered => evidenceAmount != null;
}
