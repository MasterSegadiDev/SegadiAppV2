// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:segadi/models/services/trip_closure.dart';
// import 'package:segadi/services/operatorServices/ServicesListApi.dart';
// import 'package:segadi/utils/closeTripResult.dart';
// import 'package:segadi/utils/user_session.dart';
// import 'package:segadi/models/services/checklist.dart';
// import 'package:segadi/models/services/detail_service.dart';
// import 'package:segadi/utils/global_variables.dart';
// import 'package:segadi/views/services/sendEvidences.dart';

// class DetailViewModelOld extends ChangeNotifier {
//   // ===========================================================================
//   // DEPENDENCIAS Y SERVICIOS
//   // ===========================================================================
//   final DetailServices _detailService = DetailServices();
//   final NewCheckList _itemCheckList = NewCheckList();

//   final ServicesApi servicesApi;

//   DetailViewModelOld({required this.servicesApi});

//   final TripClosure _tripClosureService = TripClosure();

//   // ===========================================================================
//   // PROPIEDADES DE ESTADO
//   // ===========================================================================
//   int _serviceDetailId = GlobalVariables.serviceDetailId;
//   DetailService? _item;
//   final List<CheckList> _items = [];
//   final Set<int> _optionSelect = {};

//   // ===========================================================================
//   // VARIABLES DE CONTROL Y MENSAJES
//   // ===========================================================================
//   bool _bandera = true;
//   String _operatorRole = '';
//   String? _errorMessage;
//   String _url = '';
//   String _errorMessageUrl = '';
//   bool _isSaving = false;

//   // ===========================================================================
//   // GETTERS PÚBLICOS
//   // ===========================================================================
//   DetailService? get item => _item;
//   List<CheckList> get items => _items;
//   Set<int> get optionSelect => _optionSelect;
//   bool get bandera => _bandera;
//   String get operatorRole => _operatorRole;
//   String? get errorMessage => _errorMessage;
//   String get url => _url;
//   String get errorMessageUrl => _errorMessageUrl;
//   bool get isSaving => _isSaving;

//   // ===========================================================================
//   // ACCIONES PÚBLICAS
//   // ===========================================================================

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   void checkMandatoryStatus(BuildContext context) async {
//     if (item?.mandatoryStatusId == 10) {
//       final result = Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (_) => SendEvidenceScreenOld(
//                   id: item!.id!,
//                   serviceId: item!.service!,
//                 )),
//       );

//       if (result == true) {
//         updateDetail();
//       }
//     }
//   }

//   void setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   Future<void> updateDetail() async => await _updateDetail();

//   Future<void> setNewDetail(DetailService detailServiceModel) async {
//     _serviceDetailId = detailServiceModel.id!;
//     await _updateDetail();
//   }

//   Future<void> fetchItems() async {
//     _optionSelect.clear();
//     final fetchedItems = await _itemCheckList.fetchItems();
//     _items
//       ..clear()
//       ..addAll(fetchedItems);
//     notifyListeners();
//   }

//   void toggleItem(int index, int id) {
//     final item = _items[index];
//     item.isChecked = !item.isChecked;

//     item.isChecked ? _optionSelect.add(id) : _optionSelect.remove(id);
//     notifyListeners();
//   }

//   Future<void> save() async {
//     if (_isSaving) return;

//     _isSaving = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       if (_optionSelect.isEmpty) {
//         _errorMessage =
//             'Necesitas seleccionar al menos una opción del checklist.';
//         return;
//       }

//       final response = await _itemCheckList.saveCheckList(
//           _serviceDetailId, _optionSelect.toList());

//       if (response.statusCode == 200) {
//         await _updateDetail();
//         await fetchItems();
//       } else {
//         _errorMessage =
//             'Error al guardar el checklist. Código: ${response.statusCode}';
//       }
//     } catch (e) {
//       _errorMessage = 'Error inesperado al guardar: $e';
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }

//   Future<void> changeStatusService(int statusId) async {
//     final user = UserSession();
//     _errorMessage = null;

//     setLoading(true);

//     try {
//       final response =
//           await _detailService.changeStatusService(_serviceDetailId, statusId);
//       print('ESTATUS DEL RESPONSE AIRBAG: $response');

//       if (statusId == 2 && user.userRoll == 'No') {
//         print('YA PASASTE EL FILTRO DEL ESTATUS Y DEL USER ROLL');
//         final restInit =
//             await _detailService.changeStatusOperatorAirbag('active');
//         print(
//             'YA PASASTE EL FILTRO DEL ESTATUS Y DEL USER ROLL: ${restInit.body}');
//       } else if (statusId == 23) {
//         final restFinshed =
//             await _detailService.changeStatusOperatorAirbag('inactive');
//         print('YA PASASTE EL FILTRO DEL ESTATUS Y DEL USER ROLL: $restFinshed');
//       }

//       if (response.statusCode == 200) {
//         await _updateDetail();
//       } else {
//         _errorMessage =
//             'Error al cambiar el estatus del servicio. Código: ${response.statusCode}';
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = 'Error inesperado: $e';
//       notifyListeners();
//     } finally {
//       setLoading(false);
//     }
//   }

//   /// ✅ Método renombrado para coincidir con la vista
//   Future<void> changeStatusSupport(int statusId, String status) async {
//     _errorMessage = null;

//     await _handleResponse(
//       _detailService.changeStatusSupport(
//         _serviceDetailId,
//         statusId,
//         status,
//       ),
//     );
//   }

//   // ===========================================================================
//   // MÉTODOS PRIVADOS
//   // ===========================================================================

//   Future<void> _updateDetail() async {
//     _item = await _detailService.getDetail(_serviceDetailId);
//     notifyListeners();
//   }

//   Future<void> _handleResponse(Future<dynamic> responseFuture,
//       {Future<void> Function()? onSuccess}) async {
//     try {
//       final response = await responseFuture;

//       if (response.statusCode == 200) {
//         if (onSuccess != null) await onSuccess();
//         await _updateDetail();
//       } else {
//         _errorMessage = 'Error en la operación. Código: ${response.statusCode}';
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = 'Error inesperado: $e';
//       notifyListeners();
//     }
//   }

//   Future<void> refreshDetail(int id) async {
//     _item = await _detailService.getDetail(id);
//     notifyListeners();
//   }

//   Future<CloseTripResult> closeTrip(int id) async {
//     try {
//       final response = await _tripClosureService.closeTravels(id);

//       if (response.statusCode == 200) {
//         getItemsOperator();
//         return CloseTripResult(success: true);
//       } else {
//         return CloseTripResult(
//           success: false,
//           message: 'Error al cerrar el viaje: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       return CloseTripResult(
//         success: false,
//         message: 'Excepción al cerrar el viaje: $e',
//       );
//     }
//   }

//   Future<void> getItemsOperator() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       await servicesApi.fetchAssignedServices();
//     } catch (e) {
//       _errorMessage = 'No se han podido obtener los servicios asignados.';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
