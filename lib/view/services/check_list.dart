import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:segadi/model/services/checklist.dart';
import 'package:segadi/model/services/detail_service.dart';
import 'package:segadi/view/home/routes.dart';

import 'package:segadi/view_model/globals.dart';
import 'package:segadi/view_model/services_operator/detail_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomDialog extends StatefulWidget {
  const CustomDialog({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final List<bool> _isChecked = [];
  bool canUpload = false;
  // ignore: non_constant_identifier_names
  List<CheckList> service_list = [];
  bool loading = true;

  late Future<DetailService>? detail;

  bool enableButton = false;

  @override
  void initState() {
    super.initState();

    getCheckList().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  Map<dynamic, dynamic> sumMap = {};

  bool detailFinished = false;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    // print(arguments['value']);
    final int id = arguments['id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check List'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        child: loading == true
            ? const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: service_list.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(service_list[index].option),
                    value: _isChecked[index],
                    onChanged: (val) {
                      setState(() {
                        _isChecked[index] = val!;
                        canUpload = true;
                        sumMap[service_list[index].id.toString()] = canUpload;
                      });
                    },
                  );
                },
              ),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          addOptionList(id);
        },
        child: const Icon(FontAwesomeIcons.save),
      ),*/
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      persistentFooterButtons: <Widget>[
        Expanded(
          child: SizedBox(
            width: 400,
            child: ElevatedButton(
              onPressed: canUpload
                  ? () {
                      addOptionList(id);
                    }
                  : null,
              //() => addOptionList(id),
              child: const Text('Guardar CheckList'),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<CheckList>> getCheckList() async {
    String token;

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/get-puntosrevision',
          'token': token,
        }))
        .timeout(const Duration(seconds: 90));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in data) {
        service_list.add(CheckList.fromJson(index));
      }
      // ignore: unused_local_variable
      for (var idx in service_list) {
        _isChecked.add(false);
      }

      return service_list;
    } else {
      return service_list;
    }
  }

  addOptionList(int id) async {
    http.Response response = await Detail.addOption(id, sumMap);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailServicesScreen(
            id: id,
          ),
        ),
      );
    }
  }
}
