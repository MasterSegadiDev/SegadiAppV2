import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/core/network/api_exceptions.dart';

// ==========================================
// MODELO DE DATOS (Services)
// ==========================================
class Services {
  int? id;
  String? service;
  String? client;
  String? origin;
  String? destination;
  String? loadDate;
  String? unloadDate;
  String? documenter;
  String? status;
  String? scaleOne;
  String? scaleTwo;

  Services({
    this.id,
    this.service,
    this.client,
    this.origin,
    this.destination,
    this.loadDate,
    this.unloadDate,
    this.documenter,
    this.status,
    this.scaleOne,
    this.scaleTwo,
  });

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        id: json["id"],
        service: json["service"],
        client: json["client"],
        origin: json["origin"],
        destination: json["destination"],
        loadDate: json["load_date"],
        unloadDate: json["unload_date"],
        documenter: json["documenter"],
        status: json["status"] ?? 'Sin Estatus',
        scaleOne: json["stopover_1"],
        scaleTwo: json["stopover_2"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service": service,
        "client": client,
        "origin": origin,
        "destination": destination,
        "load_date": loadDate,
        "unload_date": unloadDate,
        "documenter": documenter,
        "status": status,
        "stopover_1": scaleOne,
        "stopover_2": scaleTwo,
      };
}

// ==========================================
// SERVICIO DE RED (ServicesApi)
// ==========================================
class ServicesApi {
  final Dio _dio;

  ServicesApi(this._dio);

  Future<List<Services>> fetchItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('id') ?? 0;
      final String? token = prefs.getString('token');

      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getactivas',
          'id': userId.toString(),
          'token': token,
        },
      );

      // Dio ya convierte la respuesta a List<dynamic> automáticamente
      if (response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => Services.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      // Usamos tu capturador de errores profesional
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException("Error al cargar la lista de servicios.");
    }
  }
}
