import 'package:flutter/material.dart';
import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';

class ActiveSupportStatus extends StatefulWidget {
  final SupportStatusCurrentEntity supportStatus;
  final Future<bool> Function()? onFinishSupport;

  const ActiveSupportStatus({
    super.key,
    required this.supportStatus,
    this.onFinishSupport,
  });

  @override
  State<ActiveSupportStatus> createState() => _ActiveSupportStatusState();
}

class _ActiveSupportStatusState extends State<ActiveSupportStatus> {
  bool _isFinishing = false;

  Future<void> _finishSupport() async {
    final callback = widget.onFinishSupport;

    if (_isFinishing || callback == null) return;

    setState(() => _isFinishing = true);

    try {
      await callback();
    } finally {
      if (mounted) {
        setState(() => _isFinishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headset_mic,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 3),
                    Text(
                      widget.supportStatus.statusName,
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isFinishing || widget.onFinishSupport == null
                  ? null
                  : _finishSupport,
              icon: _isFinishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.stop_circle_outlined),
              label: Text(
                _isFinishing ? 'Finalizando...' : 'Finalizar soporte',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
