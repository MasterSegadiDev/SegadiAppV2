import 'package:flutter/material.dart';
import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';

class SupportStatusCard extends StatelessWidget {
  final SupportStatusCurrentEntity? supportStatus;
  final VoidCallback? onStartSupport;
  final VoidCallback? onFinishSupport;
  final bool isFinishing;

  const SupportStatusCard({
    super.key,
    this.supportStatus,
    this.onStartSupport,
    this.onFinishSupport,
    this.isFinishing = false,
  });

  static const green = Color(0xFF1E7A3C);
  static const orange = Color(0xFFED7900);
  static const red = Color(0xFFB9382E);

  @override
  Widget build(BuildContext context) {
    final hasActiveSupport = supportStatus?.active == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 550;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasActiveSupport ? const Color(0xFFFFF4E9) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: hasActiveSupport
                  ? const Color(0xFFFFBD75)
                  : const Color(0xFFE0E0DA),
              width: 1.5,
            ),
          ),
          child: compact
              ? _buildCompact(hasActiveSupport)
              : _buildHorizontal(hasActiveSupport),
        );
      },
    );
  }

  Widget _buildHorizontal(bool active) {
    return Row(
      children: [
        _buildIcon(active),
        const SizedBox(width: 14),
        Expanded(child: _buildInformation(active)),
        const SizedBox(width: 12),
        _buildButton(active),
      ],
    );
  }

  Widget _buildCompact(bool active) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildIcon(active),
            const SizedBox(width: 14),
            Expanded(child: _buildInformation(active)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _buildButton(active),
        ),
      ],
    );
  }

  Widget _buildIcon(bool active) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFE5C7) : const Color(0xFFE1F0E3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        active ? Icons.hotel_rounded : Icons.headset_mic_rounded,
        color: active ? orange : green,
        size: 38,
      ),
    );
  }

  Widget _buildInformation(bool active) {
    if (!active) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soporte de unidad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101812),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Registra una actividad de soporte para esta unidad.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6B66),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Soporte en curso',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101812),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0BD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            supportStatus!.statusName,
            style: const TextStyle(
              color: orange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Inicio: ${supportStatus!.startedAt}',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B6B66),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(bool active) {
    if (active) {
      return ElevatedButton.icon(
        onPressed: isFinishing ? null : onFinishSupport,
        icon: isFinishing
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
          isFinishing ? 'Finalizando...' : 'Finalizar soporte',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: red.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onStartSupport,
      icon: const Icon(Icons.add),
      label: const Text('Iniciar soporte'),
      style: OutlinedButton.styleFrom(
        foregroundColor: green,
        side: const BorderSide(color: green, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
