import '../../domain/entities/travel_expense_concept.dart';

class TravelExpenseConceptModel extends TravelExpenseConcept {
  const TravelExpenseConceptModel({required super.id, required super.travelExpenseRequestId,
    required super.concept, required super.amount, required super.evidenceRequired,
    super.evidenceAmount, super.evidenceDateTime, super.fileUrl});

  factory TravelExpenseConceptModel.fromJson(Map<String, dynamic> json) {
    final date = json['strEvidenceDateTime']?.toString();
    return TravelExpenseConceptModel(
      id: json['id'].toString(),
      travelExpenseRequestId: json['strTravelExpenseRequestId'].toString(),
      concept: json['strConcept']?.toString() ?? '',
      amount: (json['fltAmount'] as num).toDouble(),
      evidenceRequired: json['blnEvidenceRequired'] == true,
      evidenceAmount: (json['fltEvidenceAmount'] as num?)?.toDouble(),
      evidenceDateTime: date == null ? null : DateTime.tryParse(date),
      fileUrl: json['strFileUrl']?.toString(),
    );
  }
}
