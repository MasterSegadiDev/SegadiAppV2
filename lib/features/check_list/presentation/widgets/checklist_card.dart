import 'package:flutter/material.dart';

import '../../domain/entities/checklist_checkpoint_entity.dart';

import 'checklist_option.dart';

class ChecklistCard extends StatelessWidget {
  final List<ChecklistCheckpointEntity> checkpoints;

  final Function(
    String checkpointId,
    bool value,
  ) onChanged;

  const ChecklistCard({
    super.key,
    required this.checkpoints,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (checkpoints.isEmpty) {
      return const Center(
        child: Text(
          'No existen checkpoints.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(
        16,
      ),
      itemCount: checkpoints.length,
      separatorBuilder: (_, __) => const SizedBox(
        height: 12,
      ),
      itemBuilder: (_, index) {
        final checkpoint = checkpoints[index];

        return ChecklistOption(
          checkpoint: checkpoint,
          onChanged: (value) {
            onChanged(
              checkpoint.id,
              value,
            );
          },
        );
      },
    );
  }
}
