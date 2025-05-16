// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:segadi/models/containers/container_movement.dart';

// class ContainerService {
//   final String apiUrl =
//       "http://198.251.68.42/SEGADI/web/index.php?r=esegadi/getubicaciones&id=100&token=1000"; // Reemplaza con tu URL real

//   Future<ResponseData?> fetchContenedores() async {
//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         print(json.decode(response.body));
//         return ResponseData.fromJson(response.body);
//       } else {
//         throw Exception("Error al cargar datos");
//       }
//     } catch (e) {
//       print("Error: $e");
//       return null;
//     }
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:segadi/models/containers/container_movement.dart';

// class ContainerService {
//   Future<ContainerData> fetchContainerData() async {
//     final response = await http.get(Uri.parse(
//         "http://198.251.68.42/DesarrolloSEGADI/web/index.php?r=esegadi/getubicaciones&id=100&token=1000"));

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       return ContainerData.fromJson(jsonData);
//     } else {
//       throw Exception("Error al cargar los datos");
//     }
//   }
// }
