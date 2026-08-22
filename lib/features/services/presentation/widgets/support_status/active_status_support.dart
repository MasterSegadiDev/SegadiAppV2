import 'package:flutter/material.dart';
import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';

class ActiveSupportStatus extends StatelessWidget {
  final SupportStatusCurrentEntity supportStatus;

  const ActiveSupportStatus({
    required this.supportStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        0,
      ),
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.08),
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: Colors.orange.withOpacity(.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estatus de soporte activo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  supportStatus.statusName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.circle,
            color: Colors.green,
            size: 10,
          ),
        ],
      ),
    );
  }
}
