import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/core/presentation/dialogs/app_dialog.dart';
import 'package:segadi/features/check_list/presentation/models/checklist_arguments.dart';

import '../../../../app/di/injection_container.dart';

import '../viewmodels/checklist_viewmodel.dart';

import '../widgets/checklist_card.dart';
import '../widgets/checklist_footer.dart';

class ChecklistPage extends StatelessWidget {
  final ChecklistArguments arguments;

  const ChecklistPage({
    super.key,
    required this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ChecklistViewModel>()
        ..loadChecklist(
          arguments.referralId,
        ),
      child: _ChecklistView(
        arguments: arguments,
      ),
    );
  }
}

class _ChecklistView extends StatelessWidget {
  final ChecklistArguments arguments;

  const _ChecklistView({
    required this.arguments,
  });
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChecklistViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chequeo de Unidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Servicio # ${arguments.serviceNumber}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(.85),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChecklistCard(
              checkpoints: vm.checkpoints,
              onChanged: vm.toggleCheckpoint,
            ),
          ),
          ChecklistFooter(
            isSaving: vm.isSaving,
            canSave: vm.hasCheckedItem,
            onSave: () {
              _saveChecklist(
                context,
                vm,
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> _saveChecklist(
    BuildContext context,
    ChecklistViewModel vm,
  ) async {
    final confirm = await AppDialog.confirm(
      context,
      title: 'Enviar Checklist',
      message: '¿Deseas enviar el checklist?\n\n'
          'Una vez enviado no podrás modificar la información.',
      confirmText: 'Enviar',
      cancelText: 'Cancelar',
    );

    if (!confirm) {
      return;
    }

    AppDialog.loading(
      context,
    );

    final success = await vm.saveChecklist();

    if (!context.mounted) return;

    AppDialog.close(
      context,
    );

    if (success) {
      await AppDialog.success(
        context,
        title: 'Checklist enviado',
        message: 'El checklist fue guardado correctamente.',
      );

      if (!context.mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } else {
      await AppDialog.error(
        context,
        title: 'No se pudo guardar',
        message: vm.error ?? 'Ocurrió un error al guardar el checklist.',
      );
    }
  }
}
