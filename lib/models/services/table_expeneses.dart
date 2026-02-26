import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/core/network/api_exceptions.dart';

class TableExpenses {
  int? id;
  String? paymentConcept;
  String? totalUsed;
  String? paymentDocument;
  String? paymentExtention;
  int? image;

  TableExpenses({
    this.id,
    this.paymentConcept,
    this.totalUsed,
    this.paymentDocument,
    this.paymentExtention,
    this.image,
  });

  factory TableExpenses.fromJson(Map<String, dynamic> json) => TableExpenses(
      id: json["id"],
      paymentConcept: json["payment_concept"],
      totalUsed: json["total_used"],
      paymentDocument: json["payment_document"],
      paymentExtention: json["payment_extension"],
      image: json["image"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "payment_concept": paymentConcept,
        "total_used": totalUsed,
        "payment_document": paymentDocument,
        "payment_extension": paymentExtention,
        "image": image
      };
}

// --- SERVICIO (Lógica de red) ---
class ExpensesService {
  final Dio _dio;

  ExpensesService(this._dio);

  Future<List<TableExpenses>> getTravelExpenses(int remitionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;
      final token = prefs.getString('token') ?? '';

      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getcomprobacionestabla',
          'id': userId.toString(),
          'id_remision':
              remitionId.toString(), // Usamos el ID que viene por parámetro
          'token': token,
        },
      );

      // Dio ya entrega la respuesta decodificada como List o Map
      if (response.data is List) {
        return (response.data as List)
            .map((item) => TableExpenses.fromJson(item))
            .toList();
      }

      return []; // Si no hay datos, devolvemos lista vacía
    } on DioException catch (e) {
      // Usamos tu capturador de errores profesional
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error inesperado al cargar viáticos');
    }
  }
}
