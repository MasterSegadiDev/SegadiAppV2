import 'package:segadi/features/travel_expenses/domain/entities/table_expense_entity.dart';

class TableExpenseModel extends TableExpenseEntity {
  TableExpenseModel({
    required super.id,
    required super.concept,
    required super.amount,
    super.image,
  });

  factory TableExpenseModel.fromJson(Map<String, dynamic> json) {
    return TableExpenseModel(
      id: json["id"] ?? 0,
      concept: json["payment_concept"] ?? '',
      amount: double.tryParse(json["total_used"].toString()) ?? 0.0,
      image: json["image"],
    );
  }
}
