import 'package:flutter/material.dart';

import '../../domain/entities/checklist_checkpoint_entity.dart';

import 'checklist_option.dart';

// class ChecklistCard extends StatelessWidget {
//   final List<ChecklistCheckpointEntity> checkpoints;

//   final Function(
//     String checkpointId,
//     bool value,
//   ) onChanged;

//   const ChecklistCard({
//     super.key,
//     required this.checkpoints,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (checkpoints.isEmpty) {
//       return const Center(
//         child: Text(
//           'No existen checkpoints.',
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(
//         16,
//       ),
//       itemCount: checkpoints.length,
//       separatorBuilder: (_, __) => const SizedBox(
//         height: 12,
//       ),
//       itemBuilder: (_, index) {
//         final checkpoint = checkpoints[index];

//         return ChecklistOption(
//           checkpoint: checkpoint,
//           onChanged: (value) {
//             onChanged(
//               checkpoint.id,
//               value,
//             );
//           },
//         );
//       },
//     );
//   }
// }

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

  static const _green = Color(0xFF1E7A3C);
  static const _text = Color(0xFF101812);
  static const _secondary = Color(0xFF6B6B66);

  @override
  Widget build(BuildContext context) {
    if (checkpoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFE1F0E3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                size: 32,
                color: _green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin puntos de revisión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No existen checkpoints disponibles.',
              style: TextStyle(
                fontSize: 13,
                color: _secondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 2,
      ),
      itemCount: checkpoints.length,
      separatorBuilder: (_, __) => const SizedBox(
        height: 11,
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
