import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:segadi/model/device/device.dart';
import 'package:segadi/model/user/user.dart';
import 'package:segadi/repo/device_info_respository.dart';

class DeviceInfoViewModel extends ChangeNotifier {
  final DeviceInfo _deviceModel = DeviceInfo();
  final DeviceInfoRespository _deviceInfoRepository;

  final User _user = User();
  DeviceInfo? _deviceInfo;
  bool _isLoading = false;

  DeviceInfoViewModel(this._deviceInfoRepository);

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  DeviceInfo? get deviceInfo => _deviceInfo;
  bool get isLoading => _isLoading;

  DeviceInfo? _deviceInfoServe;
  DeviceInfo? get deviceInfoServe => _deviceInfoServe;

  bool _isValid = false;
  bool get isValid => _isValid;

  bool _bandera = false;
  bool get bandera => _bandera;

  String _nameUser = '';
  String get nameUser => _nameUser;

  set nameUser(String value) {
    _nameUser = value;
    notifyListeners();
  }

  String _firsName = '';
  String get firstName => _firsName;

  set firstName(String value) {
    _firsName = value;
    notifyListeners();
  }

  String _lastName = '';
  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  BuildContext get context => context;

  set phoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  Future<void> fetchDeviceInfo() async {
    _isLoading = true;
    notifyListeners();

    _deviceInfo = (await _deviceInfoRepository.getDeviceInfo()) as DeviceInfo?;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> validateDeviceInfo() async {
    var id = 'RSR1.201013.001';

    _deviceInfo = (await _deviceInfoRepository.getDeviceInfo()) as DeviceInfo?;
    //var data = await _deviceModel.getDataDevice();
    //Map responseMap = json.decode(data as String);
    //print(responseMap);

    if (_deviceInfo!.idDevice!.isNotEmpty &&
        _deviceInfo!.idDevice == id &&
        _deviceInfo!.modelDevice! == 'sdk_gphone_x86' &&
        _deviceInfo!.deviceInfo! == 'generic_x86_arm') {
      _isValid = true;
    } else {
      _isValid = false;
    }
    print(_isValid);

    return _isValid;
  }

  Future<void> saveDataDevice() async {
    _deviceInfo = (await _deviceInfoRepository.getDeviceInfo()) as DeviceInfo?;
    print(_deviceInfo!.hostDevice);

    // print(
    //     'nombre: ${_nameUser} apellido pa: ${_firsName}  apellido ma: ${_lastName} telefono: ${_phoneNumber}');

    var user = User(
      name: _nameUser,
      firstName: _firsName,
      lastName: _lastName,
      phoneNumber: _phoneNumber,
    );

    var rest = await _user.saveUser(user);
    print(rest);

    if (rest == 200) {
      _bandera = true;
    } else {
      _bandera = false;
      _errorMessage = 'Ha ocurrido un error';
    }

    // if (_nameUser.isNotEmpty) {
    //   _bandera = true;
    // }

    notifyListeners();
  }
}
