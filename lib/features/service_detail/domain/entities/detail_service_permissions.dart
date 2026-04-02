import 'package:flutter/cupertino.dart';

import 'detail_service_entity.dart';

class DetailServicePermissions {
  final DetailServiceEntity entity;

  DetailServicePermissions(this.entity);

  // --- REGLAS DE VISIBILIDAD / ESTADO ---

  bool get canShowChecklist =>
      entity.ui.enableCheckList && !entity.ui.serviceClosed;

  bool get canShowSupport =>
      entity.ui.enableSupport && !entity.ui.serviceClosed;

  // Solo mostramos/habilitamos EIR si el tipo es exactamente "Contenedor"
  // y el servicio aún no está cerrado en la UI.
  bool get canShowEIR {
    final type = entity.serviceType.toLowerCase().trim();
    debugPrint(
        'Evaluando EIR: type="$type", serviceClosed=${entity.ui.serviceClosed}');
    return type == 'contenedor' && entity.ui.serviceClosed;
  }

  bool get canShowViaticos => entity.ui.hasMoneyChecks;

  // bool get shouldAutoClose {
  //   if (entity.ui.serviceClosed)
  //     return false; // 🚩 Regla de oro: si ya está cerrado, no hacer nada.

  //   final type = entity.serviceType.toLowerCase().trim();
  //   final isFinished = entity.statusId == 23;
  //   final noPendingMoney = !entity.ui.hasMoneyChecks;

  //   // 🔍 DEBUG PARA TI:
  //   // print('Check Autoclose: type=$type, status=$isFinished, noMoney=$noPendingMoney, eir=${entity.eirSent}');

  //   // CASO 1: Caja Seca
  //   if (type == 'cajaseca') {
  //     return isFinished && noPendingMoney;
  //   }

  //   // CASO 2: Contenedor (Faltaba esta parte en tu código)
  //   if (type == 'contenedor') {
  //     return isFinished && noPendingMoney && entity.eirSent;
  //   }

  //   return false;
  // }

  bool get shouldAutoClose {
    // 1. Si ya está cerrado, abortamos.
    if (entity.ui.serviceClosed) return false;

    // 2. Si NO está en estatus terminado, no importa lo demás, no se cierra.
    final isFinished = entity.statusId == 23;
    if (!isFinished) return false;

    // 3. Validación de Viáticos (Universal)
    // Si la API dice que hay dinero pendiente, detenemos el auto-cierre.
    final noPendingMoney = !entity.ui.hasMoneyChecks;
    if (!noPendingMoney) return false;

    // 4. Validaciones por Tipo de Unidad
    final type = entity.serviceType.toLowerCase().trim();

    if (type == 'contenedor') {
      // Para contenedores, pedimos además que el EIR esté enviado
      return entity.eirSent;
    }

    // 5. Para cualquier otro caso (Caja Seca, etc.),
    // si llegó hasta aquí es porque está terminado y sin viáticos pendientes.
    return true;
  }
}
