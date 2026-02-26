import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/support_status/presentation/ui/support_card.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/support_status_viewmodel.dart';
import 'support_card.dart';

class StatusSupportView extends StatelessWidget {
  const StatusSupportView({super.key});

  // Lógica de colores movida a la vista para mantener el VM limpio
  Color _getOptionColor(int id, bool isSelected) {
    if (!isSelected) return Colors.blueGrey;
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

  void _showError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Ha ocurrido un error'),
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SupportStatusViewModel>();

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text('¿Necesitas ayuda? Selecciona una opción.',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildGrid(vm),
                  if (vm.loading) _buildLoadingIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(SupportStatusViewModel vm) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, i) {
        final opt = vm.options[i];
        final isSelected = vm.isSelected(opt.id);

        return SupportStatusCard(
          label: opt.label,
          icon: opt.icon,
          color: _getOptionColor(opt.id, isSelected),
          enabled: !vm.loading,
          selected: isSelected,
          onTap: () async {
            final success = await vm.send(opt.id);
            if (success) {
              if (context.mounted) Navigator.pop(context, true);
            } else {
              if (vm.errorMessage != null && context.mounted) {
                _showError(context, vm.errorMessage!);
              }
            }
          },
        );
      },
    );
  }

  // Widgets menores de soporte para limpieza visual
  Widget _buildHandle() => Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        height: 5,
        width: 45,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
      );

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estatus de soporte',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded)),
          ],
        ),
      );

  Widget _buildLoadingIndicator() => const Padding(
        padding: EdgeInsets.only(top: 20),
        child: CupertinoActivityIndicator(),
      );
}
