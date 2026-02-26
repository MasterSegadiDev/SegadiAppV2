// import 'dart:convert';

// import 'package:segadi/utils/global_variables.dart';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// List<CheckList> checkListFromJson(String str) =>
//     List<CheckList>.from(json.decode(str).map((x) => CheckList.fromJson(x)));

// String checkListToJson(List<CheckList> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class CheckList {
//   int? id;
//   String? option;
//   int? sequence;
//   bool isChecked;

//   CheckList({
//     this.id,
//     this.option,
//     this.sequence,
//     this.isChecked = false,
//   });

//   factory CheckList.fromJson(Map<String, dynamic> json) => CheckList(
//         id: json["id"],
//         option: json["option"],
//         sequence: json["sequence"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "option": option,
//         "sequence": sequence,
//       };
// }

// class NewCheckList {
//   final String baseUrl = GlobalVariables.baseUrl;
//   final Map<String, String> headers = GlobalVariables.headers;

//   Future<List<CheckList>> fetchItems() async {
//     String? token;
//     List<CheckList> serviceList = [];
//     final prefs = await SharedPreferences.getInstance();

//     //token = await storage.read(key: 'token');
//     token = prefs.getString('token');

//     var route = 'index.php';

//     var response = await http.get(
//       Uri.parse(baseUrl + route).replace(
//         queryParameters: {
//           'r': 'esegadi/get-puntosrevision',
//           'token': token,
//         },
//       ),
//     );

//     var data = jsonDecode(response.body.toString());

//     if (response.statusCode == 200) {
//       for (Map<String, dynamic> index in data) {
//         serviceList.add(CheckList.fromJson(index));
//       }

//       return serviceList;
//     } else {
//       throw Exception('Failed to load check list');
//     }
//   }

//   Future<http.Response> saveCheckList(int id, List checkList) async {
//     String? token;
//     final prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token');

//     Map data = {
//       "service": {"service_id": id, "list": checkList},
//       "token": token
//     };
//     var body = json.encode(data);

//     var url = Uri.parse('${baseUrl}index.php?r=esegadi/checklistpost');
//     // print('URL CHECKLIST:' + url.toString());
//     http.Response response = await http.post(
//       url,
//       headers: headers,
//       body: body,
//     );
//     // print('RESPUESTA DEL CHECK LIST : ${response.statusCode}');
//     return response;
//   }
// }
