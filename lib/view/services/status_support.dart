import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/view_model/services_operator/detail_service.dart';

class StatusSupport extends StatefulWidget {
  const StatusSupport({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<StatusSupport> {
  @override
  void initState() {
    super.initState();
  }

  Map<dynamic, dynamic> sumMap = {};

  bool detailFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status de soporte'),
        backgroundColor: Colors.green,
      ),
      body: SizedBox(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          childAspectRatio: 8.0 / 9.0,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                addStatusSupport(value: 24);
              },
              child: const Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        child: Image(
                          width: 50,
                          height: 100,
                          color: Colors.blue,
                          image: AssetImage("assets/images/toilet.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                addStatusSupport(value: 22);
              },
              child: const Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        child: Image(
                          width: 50,
                          height: 100,
                          color: Colors.orange,
                          image: AssetImage("assets/images/restaurant.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                addStatusSupport(value: 38);
              },
              child: const Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        child: Image(
                          width: 50,
                          height: 100,
                          color: Colors.black,
                          image: AssetImage("assets/images/sleeping.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                addStatusSupport(value: 39);
              },
              child: const Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        child: Image(
                          width: 50,
                          height: 100,
                          color: Colors.greenAccent,
                          image: AssetImage("assets/images/gas.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      persistentFooterButtons: <Widget>[
        Expanded(
          child: SizedBox(
            width: 400,
            child: ElevatedButton(
              // ignore: dead_code
              onPressed: true ? () {} : null,
              //() => addOptionList(id),
              child: const Text('Continuar Ruta'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> addStatusSupport({required int value}) async {
    int id = 0;
    http.Response response = await Detail.addStatusSupport(id, value, 'begin');
    if (response.statusCode == 200) {
      setState(() {});
    }
  }
}
