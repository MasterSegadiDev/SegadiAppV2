import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/core/presentation/dialogs/app_dialog.dart';
import 'package:segadi/features/check_list/presentation/models/checklist_arguments.dart';

import '../../../../app/di/injection_container.dart';

import '../viewmodels/checklist_viewmodel.dart';

import '../widgets/checklist_card.dart';
import '../widgets/checklist_footer.dart';

class _C {
  static const background = Color(0xFFF7F8F6);
  static const surfaceDark = Color(0xFF101812);

  static const primaryGreen = Color(0xFF1E7A3C);
  static const primaryGreenSoft = Color(0xFFE1F0E3);

  static const textPrimary = Color(0xFF101812);
  static const textSecondary = Color(0xFF6B6B66);
  static const textMuted = Color(0xFF9A9A94);

  static const border = Color(0xFFE0E0DA);
  static const errorRed = Color(0xFFB23A3A);
}

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
        backgroundColor: _C.background,
        body: Center(
          child: CircularProgressIndicator(
            color: _C.primaryGreen,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 78,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chequeo de Unidad',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 14,
                  color: Colors.white.withOpacity(.75),
                ),
                const SizedBox(width: 5),
                Text(
                  'Servicio: ${arguments.serviceNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  12,
                ),
                child: ChecklistCard(
                  checkpoints: vm.checkpoints,
                  onChanged: vm.toggleCheckpoint,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: _C.border.withOpacity(.7),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    12,
                  ),
                  child: ChecklistFooter(
                    isSaving: vm.isSaving,
                    canSave: vm.hasCheckedItem,
                    onSave: () {
                      _saveChecklist(context, vm);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
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
