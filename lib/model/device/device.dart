import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfo {
  String? idDevice;
  String? modelDevice;
  String? deviceInfo;
  String? hostDevice;

  DeviceInfo({
    this.idDevice,
    this.modelDevice,
    this.deviceInfo,
    this.hostDevice,
  });

  Future<http.Response> getDataDevice() async {
    String? token;
    int? id;
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    id = prefs.getInt('id');
    var route = 'index.php';

    var response = await http.get(
      Uri.parse(baseURL + route).replace(
        queryParameters: {
          'r': 'esegadi/getdetalle',
          //'id_remision': id.toString(),
          'token': token,
          'id': id,
        },
      ),
    );
    return response;
  }

  //Future<http.Response> saveDataDevice(int id, DeviceInfo dataDevice) async {
  Future<String> saveDataDevice(int id, DeviceInfo dataDevice) async {
    String? token;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    Map data = {
      "service": {"service_id": id, "data": dataDevice},
      "token": token
    };
    var body = json.encode(data);
    print(body);

    // var url = Uri.parse('${baseURL}index.php?r=esegadi/checklistpost');
    // http.Response response = await http.post(
    //   url,
    //   headers: headers,
    //   body: body,
    // );

    return body;
  }
}
