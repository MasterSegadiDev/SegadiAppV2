import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:segadi/view/home/routes.dart';
import 'package:segadi/view_model/services_operator/detail_service.dart';

class TripClosureScreen extends StatefulWidget {
  const TripClosureScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _TripClosureState createState() => _TripClosureState();
}

class _TripClosureState extends State<TripClosureScreen> {
  @override
  void initState() {
    super.initState();
  }

  final ImagePicker imgpicker = ImagePicker();
  String imagepath = "";

  File? image;
  String imageEncode = "";

  String extension = "";

  int counter = 3;
  bool addImage = true;

  void decrementCounter() {
    setState(() {
      counter--;
    });

    if (counter == 0) {
      setState(() {
        addImage = false;
      });
      _showMyDialog();
    }
  }

  Future getAllImage() async {
    try {
      var pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        imagepath = pickedFile.path;

        extension = getFileExtension(imagepath)!;

        File? imagefile = File(imagepath); //convert Path to File
        setState(() => image = imagefile);
        Uint8List imagebytes = await imagefile.readAsBytes(); //convert to bytes
        String base64string =
            base64.encode(imagebytes); //convert bytes to base64 string
        imageEncode = base64string;
      } else {
        print("No image is selected.");
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
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

        extension = getFileExtension(imagepath)!;

        File? imagefile = File(imagepath); //convert Path to File
        setState(() => image = imagefile);
        Uint8List imagebytes = await imagefile.readAsBytes(); //convert to bytes
        String base64string =
            base64.encode(imagebytes); //convert bytes to base64 string
        imageEncode = base64string;
      } else {
        print("No image is selected.");
      }
    } on PlatformException catch (e) {
      print('Failed to capture image: $e');
    }
  }

  senDataImage(id, String imageEncode, String serviceIdExtension) async {
    http.Response response = await Detail.insertImageTripClosure(
        id, imageEncode, serviceIdExtension);
    print(response);

    if (response.statusCode == 200) {
      decrementCounter();
      setState(() {
        image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    final int id = arguments['id'];
    final String serviceId = arguments['serviceId'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre del viaje'),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Text(
              'Remision #: ${arguments['serviceId']}',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            )),
        backgroundColor: Colors.black,
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
                    height: 400,
                    width: 200,
                    child: Image.file(image!),
                  ),
            Text('Captura $counter evidencias para el cierre del viaje'),
            if (image != null)
              ElevatedButton(
                // ignore: sort_child_properties_last
                child: const Text('Enviar Evidencia '),
                /*onPressed: () =>
                    senDataImage(id, imageEncode, serviceId + extension),*/
                onPressed: addImage
                    ? () {
                        senDataImage(id, imageEncode, serviceId + extension);
                      }
                    : null,
              ),

            ElevatedButton(
              child: const Text('Selecciona imagenes de la galería'),
              onPressed: () => getAllImage(),
            ),

            TextButton(
              onPressed: () => captureImage(),
              child: const Icon(
                Icons.camera_alt,
                size: 50,
              ),
            ),
          ],
        ),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          addOptionList(id);
        },
        child: const Icon(FontAwesomeIcons.save),
      ),*/
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.phone),
        onPressed: () {
          // FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }

  late Timer _timer;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _timer = Timer(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });
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
}
