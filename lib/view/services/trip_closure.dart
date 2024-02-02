import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/view/services/detail_service.dart';
import 'dart:io';

import '../../view_model/services_operator/detail_service.dart';

import 'package:http/http.dart' as http;

class TripClosureScreen extends StatefulWidget {
  final int id;

  const TripClosureScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _TripClosureState createState() => _TripClosureState(id);
}

class _TripClosureState extends State<TripClosureScreen> {
  _TripClosureState(this.id);
  final int id;

  final ImagePicker imgpicker = ImagePicker();
  String imagepath = "";

  File? image;
  String imageEncode = "";
  String serviceId = "";
  int? evidentias;

  String exts = "";

  int counter = 0;
  String numRemision = "";
  bool addImage = true;

  getEvidentias(int id) async {
    Map responseMap = await Detail().getEvidentias(id);
    print(responseMap);

    setState(() {
      counter = responseMap["remaining_evidences"];
    });
  }

  void decrementCounter() {
    if (counter > 0) {
      setState(() {
        counter--;
      });
      //getEvidentias(id);
    }
  }

  String? getFileExtension(String imagepath) {
    try {
      return ".${imagepath.split('.').last}";
    } catch (e) {
      return null;
    }
  }

  Future captureImage() async {
    try {
      var pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        imagepath = pickedFile.path;
        exts = getFileExtension(imagepath)!;
        File? imagefile = File(imagepath);
        setState(() => image = imagefile);
        Uint8List imagebytes = await imagefile.readAsBytes();
        String base64string = base64.encode(imagebytes);
        imageEncode = base64string;
      }
    } on PlatformException catch (e) {
      return e;
    }
  }

  @override
  void initState() {
    super.initState();
    getEvidentias(id);
  }

  @override
  Widget build(BuildContext context) {
    //final evidentias = Provider.of<ServiceViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cierre del viaje',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        bottom: const PreferredSize(
            preferredSize: Size.zero,
            child: Text(
              'Remisión: ',
              style: TextStyle(color: Colors.white, fontSize: 15),
            )),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ignore: unnecessary_null_comparison
            image == null
                ? const Center()
                : SizedBox(
                    height: 300,
                    width: 200,
                    child: Image.file(image!),
                  ),
            Text(
                'Para cerrar el viaje puedes capturar maximo ${counter} imagenes'),
            if (image != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF2C522A)),
                onPressed: addImage
                    ? () {
                        closeTravel(context, id, imageEncode, exts);
                      }
                    : null,
                child: const Text(
                  'Enviar Evidencia ',
                  style: TextStyle(color: Colors.white),
                ),
              ),

            TextButton(
              onPressed: () => captureImage(),
              child: const Icon(
                Icons.camera_alt,
                color: Color(0xFF2C522A),
                size: 50,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.phone,
          color: Colors.white,
        ),
        onPressed: () {
          // FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Cierre de viaje exitoso'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Has enviado las evidencias necesarias para comprobar tu cierre de viaje'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> closeTravel(BuildContext context, id, imageEncode, exts) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: const Text(
            '¿Quieres cerrar el viaje con la imagen captura?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('+ Evidencias'),
              onPressed: () {
                getValueFalse(id, imageEncode, exts);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Si'),
              onPressed: () {
                getValueTrue(id, imageEncode, exts);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getValueTrue(id, imageEncode, exts) async {
    http.Response response =
        await Detail.insertImageTripClosure(id, imageEncode, exts);

    if (response.statusCode == 200) {
      closeTravel1(id);

      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DetailServicesScreen(
            id: id,
          ),
        ),
      );
    }
  }

  getValueFalse(id, imageEncode, exts) async {
    http.Response response =
        await Detail.insertImageTripClosure(id, imageEncode, exts);
    Navigator.of(context).pop();
  }

  Future<http.Response> closeTravel1(id) async {
    http.Response response = await Detail().closeTravel(id);

    return response;
  }
}
