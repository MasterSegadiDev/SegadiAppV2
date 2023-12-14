import 'package:flutter/material.dart';
import 'package:segadi/model/services/services.dart';
import 'package:segadi/repo/api_status.dart';
import 'package:segadi/view_model/services_operator/assigned_services.dart';

class ServiceViewModel extends ChangeNotifier {
  bool _loading = false;
  List<Services> _serviceListModel = [];
  late ServiceError _serviceError;

  bool get loading => _loading;
  List<Services> get serviceListModel => _serviceListModel;
  ServiceError get serviceError => _serviceError;

  ServiceViewModel() {
    getService();
  }

  setLoading(bool loading) async {
    _loading = loading;
    notifyListeners();
  }

  setServiceListModel(List<Services> serviceListModel) {
    _serviceListModel = serviceListModel;
  }

  setServiceError(ServiceError serviceError) {
    _serviceError = serviceError;
  }

  getService() async {
    print('obteniendo la lista de los servicios');
    setLoading(true);
    var response = await ServicesModel.getServices();
    if (response is Success) {
      setServiceListModel(response.response as List<Services>);
    }

    if (response is Failure) {
      ServiceError serviceError =
          ServiceError(code: response.code, message: response.errorResponse);
      setServiceError(serviceError);
    }
    setLoading(false);
  }
}

class ServiceError {
  int code;
  String message;

  ServiceError({required this.code, required this.message});
}
