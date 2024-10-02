import 'dart:convert';

// import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String? name;
  String? firstName;
  String? lastName;
  String? phoneNumber;

  User({this.name, this.firstName, this.lastName, this.phoneNumber});

  // Future<http.Response> getUser() {}

  //Future<http.Response> saveUser(User user) async {
  Future<int> saveUser(User user) async {
    String? token;
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');

    Map data = {
      "user": {
        "userId": prefs.getInt('id'),
        "name": user.name,
        "firstName": user.firstName,
        "lastName": user.lastName
      },
      "token": token
    };
    var body = json.encode(data);
    print('body ${body}');

    // var url = Uri.parse('${baseUrl}index.php?r=esegadi/checklistpost');
    // http.Response response = await http.post(
    //   url,
    //   headers: headers,
    //   body: body,
    // );
    var respuesta = 200;
    return respuesta;
  }

  Future<int> updateUser(User user) async {
    String? token;
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');

    Map data = {
      "user": {
        "userId": prefs.getInt('id'),
        "name": user.name,
        "firstName": user.firstName,
        "lastName": user.lastName
      },
      "token": token
    };
    var body = json.encode(data);
    print('body ${body}');

    // var url = Uri.parse('${baseUrl}index.php?r=esegadi/checklistpost');
    // http.Response response = await http.post(
    //   url,
    //   headers: headers,
    //   body: body,
    // );
    var respuesta = 200;
    return respuesta;
  }

  // Future<http.Response> deleteUser() {}
}
