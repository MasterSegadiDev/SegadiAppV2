import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segadi/core/network/api_result.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:segadi/exceptions/messages.dart';

class DetailServiceApi {
  DetailServiceApi();

  Future<Map<String, dynamic>> fetchDetailRaw(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getInt('id') ?? 0;

    final uri = Uri.parse('${GlobalVariables.baseUrl}/index.php')
        .replace(queryParameters: {
      'r': 'esegadi/getdetalle',
      'id_remision': id.toString(),
      'token': token,
      'id': userId.toString(),
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw ApiException('Error HTTP ${response.statusCode}');
    }

    return json.decode(response.body);
  }

  Future<ApiResult> changeStatus({
    required int serviceId,
    required int statusId,
  }) async {
    final token = await LoginViewModel.getSavedToken();

    final uri =
        Uri.parse('${GlobalVariables.baseUrl}index.php?r=esegadi/estatuspost');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'service_id': serviceId.toString(),
        'status_id': statusId.toString(),
        'token': token,
      },
    );

    print('object --- Response changeStatus: ${response.statusCode}');

    if (response.statusCode != 200) {
      try {
        final decoded = jsonDecode(response.body);

        return ApiResult.failure(
          decoded['error_message']?.toString() ??
              decoded['message']?.toString() ??
              'Error HTTP ${response.statusCode}',
        );
      } catch (e) {
        return ApiResult.failure('Error HTTP ${response.statusCode}');
      }
    }

    final json = jsonDecode(response.body);

    /// ✅ TU BACKEND = éxito si viene "status"
    if (json['status'] != null) {
      return ApiResult.success(json['status']);
    }

    return ApiResult.failure('Respuesta inválida del servidor');
  }
}
