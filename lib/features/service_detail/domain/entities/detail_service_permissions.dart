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

  // --- REGLA DE CIERRE AUTOMÁTICO ---

  // bool get shouldAutoClose {
  //   final type = entity.serviceType.toLowerCase().trim();

  //   // 1. Validamos que sea CajaSeca (en tu JSON viene sin espacio)
  //   final isCajaSeca = type == 'cajaseca';

  //   // 2. Llegó al estatus final de operación (En tu JSON vimos que es 23)
  //   final isFinished = entity.statusId == 23;

  //   // 3. No tiene viáticos pendientes (usando el flag del objeto UI)
  //   final noPendingMoney = !entity.ui.hasMoneyChecks;

  //   // 4. No está cerrado ya en la UI
  //   final notClosed = entity.ui.serviceClosed;

  //   return isCajaSeca && isFinished && noPendingMoney && notClosed;
  // }

  bool get shouldAutoClose {
    if (entity.ui.serviceClosed)
      return false; // 🚩 Regla de oro: si ya está cerrado, no hacer nada.

    final type = entity.serviceType.toLowerCase().trim();
    final isFinished = entity.statusId == 23;
    final noPendingMoney = !entity.ui.hasMoneyChecks;

    // 🔍 DEBUG PARA TI:
    // print('Check Autoclose: type=$type, status=$isFinished, noMoney=$noPendingMoney, eir=${entity.eirSent}');

    // CASO 1: Caja Seca
    if (type == 'cajaseca') {
      return isFinished && noPendingMoney;
    }

    // CASO 2: Contenedor (Faltaba esta parte en tu código)
    if (type == 'contenedor') {
      return isFinished && noPendingMoney && entity.eirSent;
    }

    return false;
  }
}
