import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/model/services/trip_closure.dart';
import 'package:segadi/view_model/globals.dart';

class TripClosureViewModel extends ChangeNotifier {
  final TripClosure _tripClosure = TripClosure();
  late TripClosure tripClosure;

  String _items = '';
  String get items => _items;

  File? _image;
  File? get image => _image;

  int _numberTotalEvidentias = 0;
  int get numberTotalEvidentias => _numberTotalEvidentias;

  String _imagepath = "";
  String get imagepath => _imagepath;

  int? evidentias;

  String _exts = "";
  String get exts => _exts;

  String _imageEncode = "";
  String get imageEncode => _imageEncode;

  bool addImage = true;

  int _serviceIdOld = 0;
  int get serviceIdOld => _serviceIdOld;

  bool _isLoading = false;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  XFile? get imageFile => _imageFile;

  bool _isServiceClosed = false;
  bool get isServiceClosed => _isServiceClosed;

  bool _changePage = false;
  bool get changePage => _changePage;

  Future<void> captureImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _imageFile = pickedFile;
      _imagepath = pickedFile.path;
      _exts = getFileExtension(imagepath)!;

      File? imagefile = File(imagepath);
      Uint8List imagebytes = await imagefile.readAsBytes();
      String base64string = base64.encode(imagebytes);
      _imageEncode = base64string;

      notifyListeners();
    }
  }

  String? getFileExtension(String imagepath) {
    try {
      return ".${imagepath.split('.').last}";
    } catch (e) {
      return null;
    }
  }

  void setNewDetail(TripClosure tripClosureModel) async {
    tripClosure = tripClosureModel;

    serviceDetailId = 0;
    serviceDetailId = tripClosure.id!;

    _imageFile = null;
    _imagepath = "";
    _exts = "";
    _imageEncode = "";


    _numberTotalEvidentias =
        (await _tripClosure.getTotalEvidentias(serviceDetailId)) as int;

    notifyListeners();
  }

  Future<void> saveImage(int id, String serviceId, bool closeTravel) async {
    if (closeTravel == true) {
    
      var rest = await _tripClosure.closeTravels(id);
      if (rest.statusCode == 200) {
        _isServiceClosed = true;
        _successMessage = 'Tu viaje se ha cerrado con éxito';
      } else {
        throw Exception('Ha ocurrido un error al cerrar el viaje');
      }
    } else {
      

      await _tripClosure.insertImageTripClosure(
          id, serviceId, imageEncode, exts);

      _numberTotalEvidentias = await _tripClosure.getTotalEvidentias(id);

      if (_numberTotalEvidentias > 0) {
        _isServiceClosed = false;
        _successMessage = 'La captura se ha enviado con éxito';
      }
      if (_numberTotalEvidentias == 0) {
        var rest = await _tripClosure.closeTravels(id);
        if (rest.statusCode == 200) {
          _isServiceClosed = true;
          _successMessage = 'Tu viaje se ha cerrado con éxito';
        }
      }
    }
    _imageFile = null;
    _imagepath = "";
    _exts = "";
    _imageEncode = "";
    notifyListeners();
  }
}
