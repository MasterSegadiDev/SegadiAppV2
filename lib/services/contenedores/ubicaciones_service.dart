import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segadi/models/contenedores/ubicacion.dart';
import 'package:segadi/utils/global_variables.dart';

class UbicacionesService {
  Future<List<Ubicacion>> fetchUbicaciones({
    required String siteId,
  }) async {
    final url = Uri.parse(
      '${GlobalVariables.baseUrl}index.php?r=esegadi/getubicaciones'
      '&id=100&site_id=$siteId&token=1000',
    );

    final resp =
        await http.get(url, headers: const {"Accept": "application/json"});

    if (resp.statusCode != 200)
      throw Exception('Error cargando ubicaciones: ${resp.statusCode}');

    final jsonData = json.decode(resp.body) as Map<String, dynamic>;
    final raw = jsonData['ubicaciones'];
    if (raw is! List) return [];

    return raw
        .map((e) => Ubicacion.fromJson(e))
        .where((u) => u.id.isNotEmpty)
        .toList();
  }
}
