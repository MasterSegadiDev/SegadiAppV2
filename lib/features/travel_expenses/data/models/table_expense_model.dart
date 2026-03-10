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
      id: json['id'] ?? 0,
      // Del JSON "payment_concept" -> a tu entidad "concept"
      concept: json['payment_concept'] ?? '',
      // Del JSON "total_used" (String "100.00") -> a tu entidad "amount" (double)
      amount: double.tryParse(json['total_used'].toString()) ?? 0.0,
      // Del JSON "payment_document" -> a tu entidad "image"
      image: json['payment_document'],
    );
  }
}
