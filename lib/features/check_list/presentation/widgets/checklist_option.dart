import 'package:flutter/material.dart';

import '../../domain/entities/checklist_checkpoint_entity.dart';

class ChecklistOption extends StatelessWidget {
  final ChecklistCheckpointEntity checkpoint;

  final ValueChanged<bool> onChanged;

  const ChecklistOption({
    super.key,
    required this.checkpoint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: checkpoint.result,
        onChanged: (value) {
          onChanged(
            value ?? false,
          );
        },
        activeColor: const Color(
          0xFF2C522A,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          checkpoint.checkpointName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
