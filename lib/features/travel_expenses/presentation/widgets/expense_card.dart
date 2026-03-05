import 'package:flutter/material.dart';
import 'package:segadi/features/travel_expenses/domain/entities/table_expense_entity.dart';

class ExpenseCard extends StatelessWidget {
  final TableExpenseEntity expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFF84A756), width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2C522A).withOpacity(0.1),
          child: const Icon(Icons.receipt_long, color: Color(0xFF2C522A)),
        ),
        title: Text(
          expense.concept,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Importe: \$${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                  color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: expense.image == 1
            ? const Icon(Icons.image, color: Colors.green)
            : const Icon(Icons.image_not_supported, color: Colors.grey),
        onTap: () {
          // Aquí puedes llamar a la función de ver imagen que ya tienes
        },
      ),
    );
  }
}
