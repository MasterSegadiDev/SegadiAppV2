// // To parse this JSON data, do
// //
// //     final detailService = detailServiceFromJson(jsonString);

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:segadi/utils/global_variables.dart';
// import 'package:segadi/viewmodels/login/user_login.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// DetailService detailServiceFromJson(String str) =>
//     DetailService.fromJson(json.decode(str));

// String detailServiceToJson(DetailService data) => json.encode(data.toJson());

// class DetailService {
//   int? id;
//   String? service;
//   String? serviceType;
//   String? senderBusinessName;
//   String? senderName;
//   String? senderPhoneNumber;
//   String? senderStreet;
//   String? senderOutdoorNumber;
//   String? senderInteriorNumber;
//   String? senderCountry;
//   String? senderState;
//   int? senderZipCode;
//   String? recipientBusinessName;
//   String? recipientName;
//   String? recipientPhoneNumber;
//   String? recipientStreet;
//   String? recipientOutdoorNumber;
//   String? recipientInteriorNumber;
//   String? recipientCountry;
//   String? recipientState;
//   int? recipientZipCode;
//   int? statusId;
//   String? status;
//   String? type;
//   int? mandatoryStatusId;
//   String? mandatoryStatus;
//   int? nextMandatoryStatusId;
//   String? nextMandatoryStatus;
//   bool? isEnableButton;
//   bool? statusSupport;
//   int? statusSupportId;
//   Map<String, bool>? list;
//   bool? isEnableCheckList;
//   bool? isEnableTripClosure;
//   bool? isEnableRouteFinished;
//   bool? isEnableStatusSupport;
//   bool? isEnableContinueRute;
//   bool? serviceClosed;
//   int? remainingEvidences;
//   bool? pendingMoneyChecks;
//   String? statusSupportModal;

//   bool? isButtonEnabledBano;
//   bool? isButtonEnabledComer;
//   bool? isButtonEnabledDormir;
//   bool? isButtonEnabledGas;

//   bool? isEvidence;

//   bool? eirSent;

//   DetailService({
//     this.id,
//     this.service,
//     this.serviceType,
//     this.senderBusinessName,
//     this.senderName,
//     this.senderPhoneNumber,
//     this.senderStreet,
//     this.senderOutdoorNumber,
//     this.senderInteriorNumber,
//     this.senderCountry,
//     this.senderState,
//     this.senderZipCode,
//     this.recipientBusinessName,
//     this.recipientName,
//     this.recipientPhoneNumber,
//     this.recipientStreet,
//     this.recipientOutdoorNumber,
//     this.recipientInteriorNumber,
//     this.recipientCountry,
//     this.recipientState,
//     this.recipientZipCode,
//     this.statusId,
//     this.status,
//     this.type,
//     this.mandatoryStatusId,
//     this.mandatoryStatus,
//     this.nextMandatoryStatusId,
//     this.nextMandatoryStatus,
//     this.isEnableButton,
//     this.statusSupport,
//     this.statusSupportId,
//     this.list,
//     this.isEnableCheckList,
//     this.isEnableTripClosure,
//     this.isEnableRouteFinished,
//     this.isEnableStatusSupport,
//     this.isEnableContinueRute,
//     this.serviceClosed,
//     this.remainingEvidences,
//     this.pendingMoneyChecks,
//     this.statusSupportModal,
//     this.isButtonEnabledBano,
//     this.isButtonEnabledComer,
//     this.isButtonEnabledDormir,
//     this.isButtonEnabledGas,
//     this.isEvidence,
//     this.eirSent,
//   });

//   factory DetailService.fromJson(Map<String, dynamic> json) => DetailService(
//       id: json["id"],
//       service: json["service"],
//       serviceType: json["service_type"],
//       senderBusinessName: json["sender_business_name"],
//       senderName: json["sender_name"],
//       senderPhoneNumber: json["sender_phone_number"],
//       senderStreet: json["sender_street"],
//       senderOutdoorNumber: json["sender_outdoor_number"],
//       senderInteriorNumber: json["sender_interior_number"],
//       senderCountry: json["sender_country"],
//       senderState: json["sender_state"],
//       senderZipCode: json["sender_zip_code"],
//       recipientBusinessName: json["recipient_business_name"],
//       recipientName: json["recipient_name"],
//       recipientPhoneNumber: json["recipient_phone_number"],
//       recipientStreet: json["recipient_street"],
//       recipientOutdoorNumber: json["recipient_outdoor_number"],
//       recipientInteriorNumber: json["recipient_interior_number"],
//       recipientCountry: json["recipient_country"],
//       recipientState: json["recipient_state"],
//       recipientZipCode: json["recipient_zip_code"],
//       statusId: json["status_id"],
//       status: json['status'],
//       type: json['type'],
//       mandatoryStatusId: json["mandatory_status_id"],
//       mandatoryStatus: json["mandatory_status"],
//       nextMandatoryStatusId: json["next_mandatory_status_id"],
//       nextMandatoryStatus: json["next_mandatory_status"],
//       // Valores por defecto para evitar nulos
//       isEnableButton: false,
//       statusSupport: false,
//       statusSupportId: 0,
//       list: json["list"] is Map
//           ? Map.from(json["list"]).map((k, v) => MapEntry<String, bool>(k, v))
//           : null,
//       isEnableCheckList: false,
//       isEnableTripClosure: false,
//       isEnableRouteFinished: false,
//       isEnableStatusSupport: false,
//       isEnableContinueRute: false,
//       serviceClosed: json["service_closed"],
//       remainingEvidences: json["remaining_evidences"],
//       pendingMoneyChecks: json["pending_money_checks"],
//       isEvidence: json['evidence'],
//       isButtonEnabledBano: true,
//       isButtonEnabledComer: true,
//       isButtonEnabledDormir: true,
//       isButtonEnabledGas: true,
//       eirSent: json['eir_sent']);

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "service": service,
//         "service_type": serviceType,
//         "sender_business_name": senderBusinessName,
//         "sender_name": senderName,
//         "sender_phone_number": senderPhoneNumber,
//         "sender_street": senderStreet,
//         "sender_outdoor_number": senderOutdoorNumber,
//         "sender_interior_number": senderInteriorNumber,
//         "sender_country": senderCountry,
//         "sender_state": senderState,
//         "sender_zip_code": senderZipCode,
//         "recipient_business_name": recipientBusinessName,
//         "recipient_name": recipientName,
//         "recipient_phone_number": recipientPhoneNumber,
//         "recipient_street": recipientStreet,
//         "recipient_outdoor_number": recipientOutdoorNumber,
//         "recipient_interior_number": recipientInteriorNumber,
//         "recipient_country": recipientCountry,
//         "recipient_state": recipientState,
//         "recipient_zip_code": recipientZipCode,
//         "status_id": statusId,
//         "status": status,
//         "type": type,
//         "mandatory_status_id": mandatoryStatusId,
//         "mandatory_status": mandatoryStatus,
//         "next_mandatory_status_id": nextMandatoryStatusId,
//         "next_mandatory_status": nextMandatoryStatus,
//         "is_enable_button": isEnableButton,
//         "status_support": statusSupport,
//         "statu_support_id": statusSupportId,
//         "list": list != null
//             ? Map.from(list!).map((k, v) => MapEntry<String, dynamic>(k, v))
//             : null,
//         "is_enable_checklist": isEnableCheckList,
//         "is_enable_trip_closure": isEnableTripClosure,
//         "is_enable_route_finished": isEnableRouteFinished,
//         "is_enable_status_support": isEnableStatusSupport,
//         "is_enable_continue_rute": isEnableContinueRute,
//         "service_closed": serviceClosed,
//         "remaining_evidences": remainingEvidences,
//         "pending_money_checks": pendingMoneyChecks,
//         "evidence": isEvidence,
//         "eir_sent": eirSent
//       };
// }

// class DetailServices {
//   final String baseUrl = GlobalVariables.baseUrl;
//   final Map<String, String> headers = GlobalVariables.headers;

//   final String baseUrlAirbag = GlobalVariablesAirbag.baseUrl;
//   final Map<String, String> headersAirbag = GlobalVariablesAirbag.headers;

//   Future<DetailService> getDetail(int id) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt('id') ?? 0;
//       final token = prefs.getString('token') ?? '';

//       final uri = Uri.parse('$baseUrl/index.php').replace(queryParameters: {
//         'r': 'esegadi/getdetalle',
//         'id_remision': id.toString(),
//         'token': token,
//         'id': userId.toString(),
//       });

//       debugPrint('🚀 [getDetail] Consultando detalle id=$id');

//       final response = await http.get(uri).timeout(const Duration(seconds: 15));

//       if (response.statusCode != 200) {
//         debugPrint('❌ Error HTTP (${response.statusCode}) al obtener detalle');
//         throw Exception('Error al comunicarse con el servidor');
//       }

//       final body = json.decode(response.body);
//       final result = DetailService.fromJson(body);

//       // --- Inicialización ---
//       result.statusSupportModal =
//           result.type?.isEmpty ?? true ? 'begin' : result.statusSupportModal;
//       final sid = result.statusId ?? 0;
//       final mid = result.mandatoryStatusId ?? 0;
//       final nextMid = result.nextMandatoryStatusId ?? 0;
//       final serviceType = (result.serviceType ?? '').trim().toLowerCase();

//       debugPrint(
//           '📦 [DetalleServicio] id=$id | status=$sid | tipo=$serviceType');

//       // Helper para evitar repetir código
//       void setCommonFlags({
//         bool enableBtn = false,
//         bool enableSupport = false,
//         bool enableCheckList = false,
//         bool enableTripClosure = false,
//         bool pendingChecks = false,
//       }) {
//         result
//           ..isEnableButton = enableBtn
//           ..isEnableStatusSupport = enableSupport
//           ..isEnableCheckList = enableCheckList
//           ..isEnableTripClosure = enableTripClosure
//           ..pendingMoneyChecks = pendingChecks
//           ..mandatoryStatusId = nextMid
//           ..mandatoryStatus = result.nextMandatoryStatus;
//       }

//       // --- Lógica de negocio principal ---
//       if (result.list != null &&
//           result.nextMandatoryStatusId == 2 &&
//           result.mandatoryStatusId == 0 &&
//           result.statusId == 1) {
//         setCommonFlags(enableBtn: true, enableSupport: false);
//         print('✅ estas en estatus 1 y habilitando boton, desactivando soporte');
//       } else if (result.list != null &&
//           result.nextMandatoryStatusId == 2 &&
//           result.statusId == 0 &&
//           result.mandatoryStatusId == 0) {
//         setCommonFlags(enableBtn: true, enableSupport: false);
//         print('✅ Habilitando boton estatus monitoreo y desactivando soporte');
//       } else if (result.list == null) {
//         setCommonFlags(enableCheckList: true);
//         print('📝 Habilitando checklist (lista vacía)');
//       } else if (sid >= 0 &&
//           mid >= 0 &&
//           result.list != null &&
//           result.nextMandatoryStatusId != 0 &&
//           result.nextMandatoryStatusId != 23) {
//         setCommonFlags(enableBtn: true, enableSupport: true);
//         print('✅ Habilitando botón (estatus y checklist válidos)');
//       } else if (nextMid > 2 && result.list != null) {
//         setCommonFlags(enableBtn: true, enableSupport: true);
//         print('✅ Habilitando botón y soporte (siguiente estatus mayor a 2)');
//       } else if (result.nextMandatoryStatusId == 0 &&
//           result.mandatoryStatusId == 23 &&
//           result.statusId == 23) {
//         setCommonFlags(enableSupport: false);
//         print(
//             'ℹ️ estas en nextMandatoryStatusId 0, mandatoryStatusId 23 y statusId 23');
//       }

//       // --- Casos de descanso ---
//       if ([22, 24, 38, 39].contains(sid) && result.type == "begin") {
//         setCommonFlags(enableSupport: true);
//         result
//           ..isEnableContinueRute = true
//           ..statusSupportId = sid
//           ..statusSupportModal = 'end'
//           ..isButtonEnabledBano = sid == 24
//           ..isButtonEnabledComer = sid == 22
//           ..isButtonEnabledDormir = sid == 38
//           ..isButtonEnabledGas = sid == 39;
//       }

//       // --- Validaciones por tipo ---
//       if (serviceType == 'cajaseca' && sid == 23 && result.isEvidence == true) {
//         result.pendingMoneyChecks = true;
//       }

//       if (sid == 23 && mid == 23) {
//         result
//           ..isEnableButton = false
//           ..mandatoryStatusId = mid
//           ..mandatoryStatus = result.status;
//       }

//       // --- Contenedor ---
//       if (sid == 23 && mid == 23 && serviceType == 'contenedor') {
//         if (result.eirSent == false) {
//           debugPrint('🚚 Cierre de viaje: contenedor sin EIR');
//           result.serviceClosed = true;
//         } else if (result.eirSent == true &&
//             result.pendingMoneyChecks == true) {
//           debugPrint('💸 Pendiente de viáticos: contenedor');
//           result.pendingMoneyChecks = true;
//         }
//       }

//       // --- Caja seca ---
//       if (sid == 23 &&
//           mid == 23 &&
//           serviceType == 'cajaseca' &&
//           result.pendingMoneyChecks == true) {
//         debugPrint('💸 Pendiente de viáticos: caja seca');
//       }

//       result.mandatoryStatusId = result.nextMandatoryStatusId;
//       if (result.nextMandatoryStatus == null ||
//           result.nextMandatoryStatus == '') {
//         result.mandatoryStatus = result.status;
//       } else {
//         result.mandatoryStatus = result.nextMandatoryStatus;
//       }
//       //result.mandatoryStatus = result.nextMandatoryStatus ?? ;

//       debugPrint('''
//                 🧩 --- VALIDACIÓN FINAL ---
//                 Remisión: $id
//                 Tipo servicio: ${result.type}
//                 Estatus: ${result.status}
//                 nexmandatoryStatus: ${result.nextMandatoryStatus}
//                 nextMandatoryStatusId: $nextMid
//                 mandatoryStatusId: $mid
//                 statusId: $sid
//                 Tipo: $serviceType
//                 EIR enviado: ${result.eirSent}
//                 Pendiente viáticos: ${result.pendingMoneyChecks}
//                 ------------------------------
//                 ''');

//       return result;
//     } on TimeoutException {
//       debugPrint('⏱ Tiempo de espera agotado (timeout)');
//       throw Exception('Tiempo de espera agotado. Intenta nuevamente.');
//     } catch (e, stack) {
//       debugPrint('💥 Error en getDetail: $e');
//       debugPrint('📜 StackTrace: $stack');
//       rethrow; // Deja que el caller maneje el error según la UI
//     }
//   }

//   // Future<DetailService> getDetail(id) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final userId = prefs.getInt('id') ?? 0;
//   //   final token = prefs.getString('token') ?? '';

//   //   final route = 'index.php';

//   //   final uri = Uri.parse(baseUrl + route).replace(
//   //     queryParameters: {
//   //       'r': 'esegadi/getdetalle',
//   //       'id_remision': id.toString(),
//   //       'token': token,
//   //       'id': userId.toString(),
//   //     },
//   //   );

//   //   final response = await http.get(uri);

//   //   if (response.statusCode == 200) {
//   //     final body = json.decode(response.body);
//   //     final result = DetailService.fromJson(body);

//   //     if (result.type == '') {
//   //       result.statusSupportModal = 'begin';
//   //     }

//   //     print('Estatus nexMandatory Status: ${result.nextMandatoryStatus}');
//   //     print('MandatoryStatusId: ${result.nextMandatoryStatusId}');
//   //     if (result.list != null &&
//   //         result.statusId == 2 &&
//   //         result.mandatoryStatusId == 0) {
//   //       result.isEnableCheckList = false;
//   //       result.isEnableStatusSupport = true;
//   //       result.isEnableTripClosure = false;
//   //       result.pendingMoneyChecks = false;
//   //       result.isEnableButton = true;
//   //     } else if (result.statusId == 0 &&
//   //         result.mandatoryStatusId == 0 &&
//   //         result.list == null) {
//   //       result.isEnableStatusSupport = false;
//   //       result.isEnableTripClosure = false;
//   //       result.pendingMoneyChecks = false;
//   //       result.isEnableCheckList = true;
//   //       result.mandatoryStatusId = result.nextMandatoryStatusId ?? 0;
//   //       result.mandatoryStatus = result.nextMandatoryStatus ?? '';
//   //     } else if ((result.statusId == 0 || result.statusId == 1) &&
//   //         result.mandatoryStatusId == 0 &&
//   //         (result.nextMandatoryStatusId ?? 0) == 2 &&
//   //         result.list != null) {
//   //       result.isEnableButton = true;
//   //       result.isEnableStatusSupport = false;
//   //       result.isEnableCheckList = false;
//   //       result.isEnableTripClosure = false;
//   //       result.pendingMoneyChecks = false;
//   //       result.mandatoryStatusId = result.nextMandatoryStatusId ?? 0;
//   //       result.mandatoryStatus = result.nextMandatoryStatus ?? '';
//   //     } else if ((result.nextMandatoryStatusId ?? 0) > 2 &&
//   //         result.list != null &&
//   //         result.type != "begin") {
//   //       result.isEnableButton = true;
//   //       result.isEnableStatusSupport = true;
//   //       result.isEnableCheckList = false;
//   //       result.isEnableTripClosure = false;
//   //       result.pendingMoneyChecks = false;
//   //       result.mandatoryStatusId = result.nextMandatoryStatusId ?? 0;
//   //       result.mandatoryStatus = result.nextMandatoryStatus ?? '';
//   //     }

//   //     if ([22, 24, 38, 39].contains(result.statusId) &&
//   //         result.type == "begin") {
//   //       result.isEnableButton = false;
//   //       result.isEnableContinueRute = true;
//   //       result.isEnableStatusSupport = true;
//   //       result.isEnableTripClosure = false;
//   //       result.pendingMoneyChecks = false;
//   //       result.isEnableCheckList = false;
//   //       result.statusSupportId = result.statusId;
//   //       result.mandatoryStatusId = result.nextMandatoryStatusId ?? 0;
//   //       result.mandatoryStatus = result.nextMandatoryStatus ?? '';
//   //       result.statusSupportModal = 'end';

//   //       result.isButtonEnabledBano = result.statusId == 24;
//   //       result.isButtonEnabledComer = result.statusId == 22;
//   //       result.isButtonEnabledDormir = result.statusId == 38;
//   //       result.isButtonEnabledGas = result.statusId == 39;
//   //     }

//   //     print('--- Validación de estatus servicio ---');
//   //     print('nextMandatoryStatus: ${result.nextMandatoryStatusId}');
//   //     print('nextMandatoryStatus: ${result.nextMandatoryStatus}');
//   //     print('mandatoryStatusId: ${result.mandatoryStatusId}');
//   //     print('serviceType: ${result.serviceType}');
//   //     print('eirSent: ${result.eirSent}');
//   //     print('pendingMoneyChecks: ${result.pendingMoneyChecks}');

//   //     final serviceType = result.serviceType!.trim().toLowerCase();

//   //     // --- Caso CONTENEDOR ---
//   //     if (result.statusId == 23 &&
//   //         result.mandatoryStatusId == 23 &&
//   //         serviceType == 'contenedor') {
//   //       if (result.eirSent == false) {
//   //         print('🚚 Cierre de viaje para contenedor (sin EIR enviado)');
//   //         result.serviceClosed = true;
//   //       } else if (result.eirSent == true &&
//   //           result.pendingMoneyChecks == true) {
//   //         print('💸 Activando comprobación de viáticos para contenedor');
//   //         result.pendingMoneyChecks = true;
//   //       }
//   //       result.mandatoryStatusId = result.nextMandatoryStatusId ?? 0;
//   //       result.mandatoryStatus = result.nextMandatoryStatus ?? '';
//   //     }

//   //     // --- Caso CAJA SECA ---
//   //     else if (result.statusId == 23 &&
//   //         result.mandatoryStatusId == 23 &&
//   //         serviceType == 'cajaseca') {
//   //       if (result.pendingMoneyChecks == true) {
//   //         print('💸 Activando comprobación de viáticos para caja seca');
//   //         result.pendingMoneyChecks = true;
//   //         result.mandatoryStatusId = result.nextMandatoryStatusId ?? 0;
//   //         result.mandatoryStatus = result.nextMandatoryStatus ?? '';
//   //       }
//   //     }

//   //     return result;
//   //   } else {
//   //     throw Exception('Failed to load detail');
//   //   }
//   // }

//   Future<http.Response> changeStatusService(int serviceId, int statusId) async {
//     final token = await LoginViewModel.getSavedToken();

//     final data = {
//       "service_id": serviceId,
//       "status_id": statusId,
//       "token": token,
//     };

//     print('Change Status Service Data: $data');

//     final body = json.decode(data.toString());
//     final url = Uri.parse('${baseUrl}index.php?r=esegadi/estatuspost');

//     final response = await http.post(
//       url,
//       headers: headers,
//       body: body,
//     );
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     return response;
//   }

//   Future<http.Response> changeStatusOperatorAirbag(String status) async {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('number_employe') ?? '';

//     final data = {"force": status};
//     final body = json.encode(data);
//     final url = Uri.parse('${baseUrlAirbag}$userId/changeAppStatus');

//     final response = await http.post(
//       url,
//       headers: headersAirbag,
//       body: body,
//     );
//     return response;
//   }

//   Future<http.Response> changeStatusSupport(
//       int serviceId, int statusId, String type) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     final data = {
//       "service_id": serviceId,
//       "status_id": statusId,
//       "type": type,
//       "token": token,
//     };

//     final body = json.encode(data);
//     final url = Uri.parse('${baseUrl}index.php?r=esegadi/estatus-soportepost');

//     final response = await http.post(
//       url,
//       headers: headers,
//       body: body,
//     );

//     return response;
//   }

//   Future<bool> close(int serviceId) async {
//     final token = await LoginViewModel.getSavedToken();

//     if (token == null) {
//       throw Exception("Token no disponible");
//     }

//     final Map<String, dynamic> data = {
//       "service_id": serviceId,
//       "token": token,
//       "close": 1,
//     };

//     final url = Uri.parse('${baseUrl}index.php?r=esegadi/cierreevidenciaspost');

//     final response = await http.post(
//       url,
//       headers: headers,
//       body: jsonEncode(data),
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//           'Error al cerrar el viaje (status: ${response.statusCode})');
//     }

//     return true;
//   }
// }
