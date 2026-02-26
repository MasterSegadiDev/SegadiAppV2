import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/viewmodels/login/user_login.dart';

// ==========================================
// 1. MODELO DE DATOS
// ==========================================
class TravelExpenses {
  int? id;
  int? paymentConceptId;
  String? paymentConcept;
  String? paymentTotal;
  double? import;
  bool? pendingMoneyChecks;

  TravelExpenses({
    this.id,
    this.paymentConceptId,
    this.paymentConcept,
    this.paymentTotal,
    this.import,
    this.pendingMoneyChecks,
  });

  factory TravelExpenses.fromJson(Map<String, dynamic> json) => TravelExpenses(
        id: json["id"],
        paymentConceptId: json["payment_concept_id"],
        paymentConcept: json["payment_concept"],
        paymentTotal: json["payment_total"],
        pendingMoneyChecks: json["pending_money_checks"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "payment_concept_id": paymentConceptId,
        "payment_concept": paymentConcept,
        "payment_total": paymentTotal,
        "pending_money_checks": pendingMoneyChecks,
      };
}

// ==========================================
// 2. SERVICIO DE RED (DATA SOURCE)
// ==========================================
class TravelExpensesService {
  final Dio _dio;

  TravelExpensesService(this._dio);

  /// Obtener la lista de viáticos/comprobaciones
  Future<List<TravelExpenses>> getData(int remitionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;
      final token = prefs.getString('token') ?? '';

      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getcomprobaciones',
          'id': userId.toString(),
          'id_remision': remitionId.toString(),
          'token': token,
        },
      );

      final List<dynamic> data = response.data;
      return data.map((json) => TravelExpenses.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error al consultar los viáticos');
    }
  }

  /// Insertar un nuevo concepto e importar imagen
  /// Retorna [true] si el servicio se cerró automáticamente, [false] si sigue abierto.
  Future<bool> insertImport({
    required int serviceId,
    required int conceptId,
    required dynamic importTotal,
    required String commentary,
    required String name,
    required String? imageBytes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final Map<String, dynamic> data = {
        "service_id": serviceId,
        "token": token,
        "money_check_id": conceptId,
        "total_used": importTotal,
        "comments": commentary,
        "document_name": name,
        "document": imageBytes,
      };

      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/comprobacionespost'},
        data: data,
      );

      // Mapeamos la respuesta para revisar si quedan pendientes
      final result = TravelExpenses.fromJson(response.data);

      // Lógica de negocio: si pendingMoneyChecks es false, cerramos el viaje
      if (result.pendingMoneyChecks == false) {
        final successClose = await closeService(serviceId);
        return successClose;
      }

      return false;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error al insertar el concepto de gasto');
    }
  }

  /// Cerrar el viaje/servicio
  Future<bool> closeService(int serviceId) async {
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

      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error al finalizar el cierre del viaje');
    }
  }
}
