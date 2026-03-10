import 'package:segadi/features/travel_expenses/domain/entities/travel_expense_entity.dart';

class TravelExpenseModel extends TravelExpenseEntity {
  TravelExpenseModel({
    required super.id,
    required super.concept,
    required super.totalUsed,
    required super.paymentTotal,
    required super.paymentRequireEvidence,
  });

  factory TravelExpenseModel.fromJson(Map<String, dynamic> json) {
    return TravelExpenseModel(
      id: json['id'] ?? 0,
      concept: json['payment_concept'] ?? '',
      // El JSON viene como String "100.00", lo convertimos a double
      totalUsed: double.tryParse(json['total_used'].toString()) ?? 0.0,
      paymentTotal: double.tryParse(json['payment_total'].toString()) ?? 0.0,
      paymentRequireEvidence: json['payment_require_evidence'] ?? "No",
    );
  }
}
