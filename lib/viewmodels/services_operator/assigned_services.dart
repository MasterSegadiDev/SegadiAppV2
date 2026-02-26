// import 'package:flutter/foundation.dart';
// import 'package:segadi/models/services/services.dart';
// import 'package:segadi/exceptions/messages.dart';
// import 'package:segadi/services/operatorServices/ServicesListApi.dart';

// class ServicesViewModel extends ChangeNotifier {
//   final ServicesApi _api;

//   ServicesViewModel(this._api);

//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _sessionExpired = false;
//   List<Services> _items = [];

//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get sessionExpired => _sessionExpired;
//   List<Services> get items => List.unmodifiable(_items);

//   Future<void> fetchItems({bool forceRefresh = false}) async {
//     if (_isLoading && !forceRefresh) return;

//     _setLoading(true);
//     _errorMessage = null;
//     _sessionExpired = false;

//     try {
//       _items = await _api.fetchAssignedServices();
//     } on ApiException catch (e) {
//       if (e.message.contains('Sesión expirada')) {
//         _sessionExpired = true;
//       } else {
//         _errorMessage = e.message;
//       }
//     } on NetworkException catch (e) {
//       _errorMessage = e.message;
//     } catch (_) {
//       _errorMessage = 'Error inesperado. Intenta nuevamente.';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> onRefresh() async {
//     await fetchItems(forceRefresh: true);
//   }

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
// }
