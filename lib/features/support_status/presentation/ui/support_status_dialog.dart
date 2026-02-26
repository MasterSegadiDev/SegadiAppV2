import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';

class SupportStatusDialog extends StatelessWidget {
  const SupportStatusDialog({super.key});

  // Mismos colores para mantener consistencia
  Color _getOptionColor(int id) {
    switch (id) {
      case 24:
        return Colors.blue;
      case 22:
        return Colors.orange;
      case 38:
        return Colors.indigo;
      case 39:
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel
    final vm = context.watch<SupportStatusViewModel>();
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle visual
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text('Estatus de Soporte',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: size.height * 0.4),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: vm.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final opt = vm.options[i];
                    final isSelected = vm.isSelected(opt.id);

                    return _ModernListTile(
                      icon: opt.icon,
                      label: opt.label,
                      // Si está seleccionado usamos el color, si no, un gris suave
                      color: isSelected ? _getOptionColor(opt.id) : Colors.grey,
                      isSelected: isSelected,
                      onTap: vm.loading
                          ? null
                          : () async {
                              // 1. Llamamos a la lógica del VM (sin pasar el context)
                              final success = await vm.send(opt.id);

                              if (success) {
                                if (context.mounted)
                                  Navigator.pop(context, true);
                              } else {
                                // 2. Si falla, mostramos el error aquí (siempre al frente)
                                if (vm.errorMessage != null &&
                                    context.mounted) {
                                  _showErrorDialog(context, vm.errorMessage!);
                                }
                              }
                            },
                    );
                  },
                ),
              ),
            ),
            if (vm.loading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CupertinoActivityIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Atención'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para el diálogo
class _ModernListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ModernListTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Si está seleccionado, pintamos un borde sutil del color
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 18)
            else
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
