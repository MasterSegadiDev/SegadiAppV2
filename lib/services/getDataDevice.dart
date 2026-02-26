// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:segadi/models/device/device.dart';
// import 'package:segadi/utils/global_variables.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class InfoDeviceSystemERP {
//   final String baseUrl = GlobalVariables.baseUrl;
//   final Map<String, String> headers = GlobalVariables.headers;

//   Future<http.Response> getDataDeviceSystem() async {
//     String? token;
//     int? id;
//     final prefs = await SharedPreferences.getInstance();

//     token = prefs.getString('token');
//     id = prefs.getInt('id');
//     var route = 'index.php';

//     var response = await http.get(
//       Uri.parse(baseUrl + route).replace(
//         queryParameters: {
//           'r': 'esegadi/getidedispositivo',
//           'token': token.toString(),
//           'id': id.toString(),
//         },
//       ),
//     );

//     return response;
//   }

//   Future<http.Response> saveDataDevice(DeviceInfo dataDevice) async {
//     String? token;
//     int? id;
//     final prefs = await SharedPreferences.getInstance();

//     token = prefs.getString('token');
//     id = prefs.getInt('id');

//     Map data = {
//       "token": token,
//       "id": id,
//       "nombre": dataDevice.name,
//       "apellido_paterno": dataDevice.firstName,
//       "apellido_materno": dataDevice.lastName,
//       "telefono_empresa": dataDevice.phoneNumberJob,
//       "telefono_personal": dataDevice.phoneNumberPerson,
//       "ide_dispositivo": dataDevice.idDevice,
//       "modelo_dispositivo": dataDevice.modelDevice,
//       "device": dataDevice.deviceInfo,
//       "host": dataDevice.hostDevice,
//     };
//     var body = json.encode(data);

//     var url = Uri.parse('${baseUrl}index.php?r=esegadi/equipopost');
//     http.Response response = await http.post(
//       url,
//       headers: headers,
//       body: body,
//     );
//     return response;
//   }
// }
