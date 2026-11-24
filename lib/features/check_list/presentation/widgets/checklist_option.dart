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

  static const _green = Color(0xFF1E7A3C);
  static const _greenSoft = Color(0xFFE1F0E3);
  static const _text = Color(0xFF101812);
  static const _secondary = Color(0xFF6B6B66);
  static const _border = Color(0xFFE0E0DA);

  @override
  Widget build(BuildContext context) {
    final selected = checkpoint.result;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? _greenSoft : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? _green : _border,
          width: selected ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(!selected),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? _green : const Color(0xFFF7F8F6),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.circle_outlined,
                    color: selected ? Colors.white : _secondary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    checkpoint.checkpointName,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: _text,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Checkbox(
                  value: selected,
                  onChanged: (value) {
                    onChanged(value ?? false);
                  },
                  activeColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
