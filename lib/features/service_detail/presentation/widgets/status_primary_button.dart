import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';

class StatusPrimaryButton extends StatelessWidget {
  const StatusPrimaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos watch para reaccionar a cambios en el ViewModel
    final vm = context.watch<DetailServiceViewModel>();
    print('estatus id: ${vm.entity?.nextMandatoryStatusId}');

    // Si no hay entidad cargada, no podemos mostrar acciones
    if (vm.entity == null) return const SizedBox.shrink();

    // Usamos el estado para el diseño, pero si es nulo,
    // tenemos valores por defecto para que el botón no desaparezca
    final state = vm.state;

    // Lógica de habilitación
    final bool isTypeEnabled = vm.entity?.type != 'begin';
    final bool isEnabled = (state?.enableButton ?? true) &&
        vm.status != DetailServiceStatus.loading &&
        isTypeEnabled;

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF2C522A).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: const Color(0xFF2C522A),
        disabledColor: Colors.grey[400]!,
        borderRadius: BorderRadius.circular(50),
        // El botón se deshabilita si está cargando O si está en el tiempo de espera de 5s
        onPressed: (isEnabled && !vm.isProcessing)
            ? () => vm.changeMandatoryStatus(context)
            : null,
        child: vm.isProcessing // Mostramos el spinner durante todo el proceso
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Text(
                    state?.buttonLabel ??
                        " ${vm.entity?.nextMandatoryStatus ?? 'Siguiente'}",
                    style: const TextStyle(
                        letterSpacing: 1.1, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
