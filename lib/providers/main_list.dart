import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:segadi/services/globals.dart';

class MainList {
  static final MainList _mainList = MainList._privade();

  MainList._privade();

  factory MainList() {
    return _mainList;
  }

  Future<List<Map<String, dynamic>>> get lists async {
    List<Map<String, dynamic>> lists = [];

    //final response = await http.get();
    var url = Uri.parse(baseURL + "main/options");

    http.Response response = await http.get(
      url,
      headers: headers,
    );

    print("json: ${response.body} ");

    //Map<String, dynamic> data = json.decode(response.body);

    //Map<String, dynamic> data = json.decode(response.body);
    List<dynamic> data = json.decode(response.body);
    print("Lista Mapeada: $data");

    /* data.forEach((index, contain) {
      lists.add(contain);
    });*/

    return lists;
  }
}
