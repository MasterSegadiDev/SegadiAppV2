
/*import 'package:flutter/material.dart';
import 'package:segadi/helper/navigator.dart';
import 'package:segadi/helper/services/network_services.dart';
import 'package:segadi/model/model_services/detail_service.dart';

import 'package:segadi/view/services/detail_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailServiceViewModel extends ChangeNotifier {
  final NavigationService _navigationService;

  String service = "";
  //TextEditingController descriptioncontroller = TextEditingController();
  int? id;
  late String token;
  late String url;
  late int userId;

  DetailServiceViewModel(this._navigationService) {
    // getDetailService();
  }

  getDetailService(DetailService data) async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id') ?? 0;
    token = prefs.getString('token') ?? '';

    url = 'esegadi/getdetalle';

    var result = await ApiProvider().getDetailService(url, token, userId, id);

    result.isEnableButton = false;
    //valido cuando se envia un estatus de soporte, activo el boton para continuar ruta
    // y el icono estatus soporte
    if (result.statusId == 24 && result.type == "begin") {
      result.isEnableButton = false;
      result.isEnableContinueRute = true;

      result.isEnableStatusSupport = true;
      result.isEnableTripClosure = false;
      result.pendingMoneyChecks = false;
      result.isEnableCheckList = false;

      result.statusSupportId = 24;
      result.mandatoryStatusId = result.nextMandatoryStatusId;
      result.mandatoryStatus = result.nextMandatoryStatus;
    }
    if (result.statusId == 22 && result.type == "begin") {
      result.isEnableButton = false;
      result.isEnableContinueRute = true;

      result.isEnableStatusSupport = true;
      result.isEnableTripClosure = false;
      result.pendingMoneyChecks = false;
      result.isEnableCheckList = false;

      result.statusSupportId = 22;
      result.mandatoryStatusId = result.nextMandatoryStatusId;
      result.mandatoryStatus = result.nextMandatoryStatus;
    }
    if (result.statusId == 38 && result.type == "begin") {
      result.isEnableButton = false;
      result.isEnableContinueRute = true;

      result.isEnableStatusSupport = true;
      result.isEnableTripClosure = false;
      result.pendingMoneyChecks = false;
      result.isEnableCheckList = false;

      result.statusSupportId = 38;
      result.mandatoryStatusId = result.nextMandatoryStatusId;
      result.mandatoryStatus = result.nextMandatoryStatus;
    }
    if (result.statusId == 39 && result.type == "begin") {
      result.isEnableButton = false;
      result.isEnableContinueRute = true;

      result.statusSupportId = 39;
      result.isEnableStatusSupport = true;
      result.isEnableTripClosure = false;
      result.pendingMoneyChecks = false;
      result.isEnableCheckList = false;

      result.mandatoryStatusId = result.nextMandatoryStatusId;
      result.mandatoryStatus = result.nextMandatoryStatus;
    }
    //termino validaciones icono estatus soporte y boton continuar ruta

    //se valida que la remision tenga un estatusId == 0, mandatoryStatusId == 0 y el check lis en null
    //para habilitar el check list
    if (result.statusId == 0 &&
        result.mandatoryStatusId == 0 &&
        result.list == null) {
      result.isEnableStatusSupport = false;
      result.isEnableTripClosure = false;
      result.pendingMoneyChecks = false;
      result.isEnableCheckList = true;
      result.mandatoryStatusId = result.nextMandatoryStatusId;
      result.mandatoryStatus = result.nextMandatoryStatus;

      //con esta validacion activo el boton del estatus obligatorio para inicar ruta, considerando la cita de carga
      //como opcion
    } else if (result.statusId == 0 ||
        result.statusId == 1 &&
            result.mandatoryStatusId == 0 &&
            result.nextMandatoryStatusId == 2 &&
            result.list != null) {
      print(
          'entraste a activar el boton estatus obligatorio para el inicio de ruta');
      result.isEnableButton = true;
      result.isEnableStatusSupport = false;
      result.isEnableCheckList = false;
      result.isEnableTripClosure = false;
      result.pendingMoneyChecks = false;

      result.mandatoryStatusId = result.nextMandatoryStatusId;
      result.mandatoryStatus = result.nextMandatoryStatus;

      //con esta validacion activo el boton de estatus obligatorio y el icono de estatus de soporte
    } else if (result.nextMandatoryStatusId! > 2 &&
        result.list != null &&
        result.type != "begin") {
      print(
          'entro a status mayor a 2(inicio de ruta ) para activar icono status soporte');
      result.isEnableButton = true;
      result.isEnableStatusSupport = true;
      result.isEnableCheckList = false;
      result.isEnableTripClosure = false;
      result.pendingMoneyChecks = false;
      result.mandatoryStatusId = result.nextMandatoryStatusId;
      result.mandatoryStatus = result.nextMandatoryStatus;

      //con esta validacion valido que la remision este terminada tomando en cuenta los IDS 23 de ambos
      //parametros  y que el cierre de viaje no este cerrado(true).
    } else if (result.statusId == 23 &&
        result.mandatoryStatusId == 23 &&
        result.nextMandatoryStatusId == 0 &&
        result.serviceClosed == false) {
      print(
          'entraste a activar el icono cierr de viaje por que a un no se cierra el viaje pero puede que haya evidencias');
      result.isEnableCheckList = false;
      result.isEnableStatusSupport = false;
      result.serviceClosed = true;
      result.pendingMoneyChecks = false;
      result.mandatoryStatus = result.status;

      result.mandatoryStatusId = result.mandatoryStatusId;
      result.mandatoryStatus = result.mandatoryStatus;

      //con esta validacion bloqueo el icono cierre de viaje
    } else if (result.statusId == 23 &&
        result.mandatoryStatusId == 23 &&
        result.nextMandatoryStatusId == 0 &&
        result.serviceClosed == true &&
        result.pendingMoneyChecks == true) {
      print(
          'entraste a bloquear cierre de viaje, por que ya se cerro el viaje, pero la remision no tiene viaticos');
      result.isEnableCheckList = false;
      result.isEnableStatusSupport = false;
      result.serviceClosed = false;
      result.pendingMoneyChecks = true;
      result.mandatoryStatus = result.status;

      result.mandatoryStatusId = result.mandatoryStatusId;
      result.mandatoryStatus = result.mandatoryStatus;

      //con esta validacion desactivo el icono de viaticos y activo el icono cierre de viaje
    } else if (result.statusId == 23 &&
        result.mandatoryStatusId == 23 &&
        result.remainingEvidences == 0 &&
        result.serviceClosed == true &&
        result.pendingMoneyChecks == false) {
      print(
          'entraste a bloquear icono cierre de viaje y bloquear icono viaticos');

      result.isEnableCheckList = false;
      result.isEnableStatusSupport = false;
      result.serviceClosed = false;
      result.pendingMoneyChecks = false;
      result.mandatoryStatus = result.status;

      result.mandatoryStatusId = result.mandatoryStatusId;
      result.mandatoryStatus = result.mandatoryStatus;

      //con esta validacion valido que el cierre de viaje este realizado y la remision tenga viaticos
    } else if (result.statusId == 23 &&
        result.mandatoryStatusId == 23 &&
        result.nextMandatoryStatusId == 0 &&
        result.serviceClosed == true &&
        result.pendingMoneyChecks == true) {
      print('entraste para ver los viaticos asignados');

      result.isEnableCheckList = false;
      result.isEnableStatusSupport = false;
      result.serviceClosed = false;
      result.pendingMoneyChecks = true;
      result.mandatoryStatus = result.status;

      result.mandatoryStatusId = result.mandatoryStatusId;
      result.mandatoryStatus = result.mandatoryStatus;
    } else if (result.statusId == 23 &&
        result.mandatoryStatusId == 23 &&
        result.nextMandatoryStatusId == 0 &&
        result.serviceClosed == true &&
        result.pendingMoneyChecks == false) {
      print('entraste para ver los viaticos asignados');

      result.isEnableCheckList = false;
      result.isEnableStatusSupport = false;
      result.serviceClosed = false;
      result.pendingMoneyChecks = false;
      result.mandatoryStatus = result.status;

      result.mandatoryStatusId = result.mandatoryStatusId;
      result.mandatoryStatus = result.mandatoryStatus;
    }

    //navigationService.navigate(DetailServicesScreen(data: data));
  }
}
*/