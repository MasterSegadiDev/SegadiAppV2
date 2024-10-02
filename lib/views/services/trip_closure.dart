import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/messages.dart';
import 'package:segadi/models/services/detail_service.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';
import 'package:segadi/viewmodels/services_operator/trip_closure.dart';

class TripClosureScreen extends StatefulWidget {
  const TripClosureScreen({Key? key}) : super(key: key);

  @override
  _TripClosureState createState() => _TripClosureState();
}

class _TripClosureState extends State<TripClosureScreen> {
  final ImagePicker imgpicker = ImagePicker();
  String imagepath = "";

  File? image;
  String imageEncode = "";

  int? evidentias;

  String exts = "";
  bool addImage = true;

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
        //setState(() => image = imagefile);
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
  }

  @override
  Widget build(BuildContext context) {
    final viewModelTripClosure = Provider.of<TripClosureViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cierre del viaje',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Text(
              'Remisión: ${viewModelTripClosure.tripClosure.serviceId} ',
              style: const TextStyle(color: Colors.white, fontSize: 15),
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
            if (viewModelTripClosure.imageFile == null)
              const Center()
            else
              SizedBox(
                height: 300,
                width: 200,
                child: Image.file(File(viewModelTripClosure.imagepath)),
              ),
            Text(
                'Para cerrar el viaje puedes capturar maximo ${viewModelTripClosure.numberTotalEvidentias} imagenes'),
            if (viewModelTripClosure.imageFile != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFF2C522A),
                ),
                onPressed: () {
                  closeTravel(context);
                },
                child: const Text(
                  'Enviar Evidencia ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            TextButton(
              onPressed: () => viewModelTripClosure.captureImage(),
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
          FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }

  Future<void> closeTravel(BuildContext context) {
    final viewModelTripClosure =
        Provider.of<TripClosureViewModel>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cierre del viaje'),
          content: const Text(
            '¿Quieres cerrar el viaje con la imagen captura?',
          ),
          actions: <Widget>[
            Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C522A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        fixedSize: const Size(250, double.infinity),
                      ),
                      onPressed: () async {
                        await viewModelTripClosure.saveImage(
                          viewModelTripClosure.tripClosure.id!,
                          viewModelTripClosure.tripClosure.serviceId!,
                          viewModelTripClosure.tripClosure.closeTravel = false,
                        );

                        if (viewModelTripClosure.isServiceClosed == false) {
                          Navigator.of(context).pop();
                          scaffoldMessengerSuccessEvidentia(
                              context, viewModelTripClosure.successMessage!);
                        } else if (viewModelTripClosure.isServiceClosed ==
                            true) {
                          scaffoldMessengerSuccessEvidentia(
                              context, viewModelTripClosure.successMessage!);

                          Future.delayed(const Duration(seconds: 2), () {
                            final detailServiceModel = DetailService(
                                id: viewModelTripClosure.tripClosure.id);
                            Provider.of<DetailViewModel>(context, listen: false)
                                .setNewDetail(detailServiceModel);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: const Text(
                        'Agregar mas evidencias',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C522A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          fixedSize: const Size(250, double.infinity)),
                      onPressed: () async {
                        await viewModelTripClosure.saveImage(
                          viewModelTripClosure.tripClosure.id!,
                          viewModelTripClosure.tripClosure.serviceId!,
                          viewModelTripClosure.tripClosure.closeTravel = true,
                        );
                        if (viewModelTripClosure.isServiceClosed == true) {
                          scaffoldMessengerSuccessEvidentia(
                              context, viewModelTripClosure.successMessage!);

                          Future.delayed(const Duration(seconds: 2), () {
                            final detailServiceModel = DetailService(
                                id: viewModelTripClosure.tripClosure.id);
                            Provider.of<DetailViewModel>(context, listen: false)
                                .setNewDetail(detailServiceModel);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: const Text(
                        'Cerrar viaje',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }
}
