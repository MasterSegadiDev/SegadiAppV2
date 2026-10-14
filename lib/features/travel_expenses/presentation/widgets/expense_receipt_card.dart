import 'package:flutter/material.dart';
import '../../domain/entities/expense_receipt.dart';

class ExpenseReceiptCard extends StatelessWidget {
  final ExpenseReceipt receipt;
  final VoidCallback onTap;
  const ExpenseReceiptCard(
      {super.key, required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE0E0DA))),
        child: ListTile(
          onTap: onTap,
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 48,
                height: 48,
                child: receipt.imageBytes == null
                    ? const ColoredBox(
                        color: Color(0xFFE1F0E3),
                        child:
                            Icon(Icons.receipt_long, color: Color(0xFF1E7A3C)))
                    : Image.memory(receipt.imageBytes!, fit: BoxFit.cover),
              )),
          title: Text(receipt.concept,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('\$${receipt.amount.toStringAsFixed(2)}'),
          trailing: Icon(
              receipt.imageBytes == null
                  ? Icons.image_not_supported_outlined
                  : Icons.image_outlined,
              color: const Color(0xFF1E7A3C)),
        ),
      );
}
