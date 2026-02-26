import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/viewmodels/login/user_login.dart';

// ==========================================
// 1. MODELO DE DATOS
// ==========================================
class TripClosure {
  int? id;
  String? serviceId;
  String? extension;
  File? image;
  bool? closeTravel;

  TripClosure({
    this.id,
    this.serviceId,
    this.extension,
    this.image,
    this.closeTravel,
  });

  factory TripClosure.fromJson(Map<String, dynamic> json) => TripClosure(
        id: json["id"],
        serviceId: json["service_id"]?.toString(),
        extension: json["extension"],
        closeTravel: json["service_closed"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service_id": serviceId,
        "extension": extension,
        "service_closed": closeTravel,
      };
}

// ==========================================
// 2. SERVICIO DE RED (TRIP CLOSURE SERVICE)
// ==========================================
class TripClosureService {
  final Dio _dio;

  TripClosureService(this._dio);

  /// Inserta una imagen como evidencia para cierre de viaje
  Future<void> insertImageTripClosure({
    required int id,
    required String serviceId,
    required String imageBase64,
    required String extension,
  }) async {
    try {
      final token = await LoginViewModel.getSavedToken();

      final Map<String, dynamic> data = {
        "service_id": id,
        "token": token,
        "document_name": "$serviceId$extension",
        "document_description": "Evidencia Operador",
        "document_type": "POD Operador",
        "document": imageBase64,
      };

      await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/evidenciaspost'},
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error inesperado al guardar la evidencia');
    }
  }

  /// Obtiene el total de evidencias pendientes para un servicio
  Future<int> getTotalEvidencias(int serviceId) async {
    try {
      final token = await LoginViewModel.getSavedToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;

      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getevidenciasfaltantes',
          'token': token,
          'id': userId.toString(),
          'service_id': serviceId.toString(),
        },
      );

      final data = response.data;
      final remaining = data['remaining_evidences'];

      return remaining is int ? remaining : int.parse(remaining.toString());
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error al consultar evidencias pendientes');
    }
  }

  /// Cierra el viaje enviando la solicitud correspondiente
  Future<void> closeTravels(int serviceId) async {
    try {
      final token = await LoginViewModel.getSavedToken();

      final Map<String, dynamic> data = {
        "service_id": serviceId,
        "token": token,
        "close": 1,
      };

      await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/cierreevidenciaspost'},
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error inesperado al cerrar el viaje');
    }
  }
}
