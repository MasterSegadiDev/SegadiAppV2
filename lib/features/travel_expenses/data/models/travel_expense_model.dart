import 'package:segadi/features/travel_expenses/domain/entities/travel_expense_entity.dart';

class TravelExpenseModel extends TravelExpenseEntity {
  TravelExpenseModel({
    required super.id,
    required super.concept,
    required super.totalAmount,
  });

  factory TravelExpenseModel.fromJson(Map<String, dynamic> json) {
    return TravelExpenseModel(
      id: json["id"] ?? 0,
      concept: json["payment_concept"] ?? '',
      totalAmount: double.tryParse(json["payment_total"].toString()) ?? 0.0,
    );
  }
}
