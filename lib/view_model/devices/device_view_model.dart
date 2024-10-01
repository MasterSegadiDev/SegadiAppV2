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

  bool _isValidName = false;
  bool get isValidName => _isValidName;

  bool _isValid = false;
  bool get isValid => _isValid;

  bool _isValidFirstName = false;
  bool get isValidFirstName => _isValidFirstName;

  bool _isValidLastName = false;
  bool get isValidLastName => _isValidLastName;

  bool _isValidPhoneJob = false;
  bool get isValidPhoneJob => _isValidPhoneJob;

  bool _isValidPhonePerson = false;
  bool get isValidPhonePerson => _isValidPhonePerson;

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

  String _phoneNumberJob = '';
  String get phoneNumberJob => _phoneNumberJob;

  String _phoneNumberPerson = '';
  String get phoneNumberPerson => _phoneNumberPerson;

  BuildContext get context => context;

  set phoneNumber(String value) {
    _phoneNumberJob = value;
    notifyListeners();
  }

  String _input = '';
  bool _isValidInput = true;

  String get input => _input;
  bool get isValidInput => _isValidInput;

  void validateInputName(String valueName) {
    print('value entrado desde input: ${valueName}');
    _input = valueName;
    _isValidName = _input.isNotEmpty && _input.length >= 3;
    _nameUser = valueName;
    print(_nameUser);
    notifyListeners();
  }

  void validateInputFirstName(String valueFirstName) {
    print('value entrado desde input: ${valueFirstName}');
    _input = valueFirstName;
    _isValidFirstName = _input.isNotEmpty && _input.length >= 3;
    _firsName = valueFirstName;
    print(_firsName);
    notifyListeners();
  }

  void validateInputPhoneJob(String valuePhoneJob) {
    print('value entrado desde input: ${valuePhoneJob}');
    _input = valuePhoneJob;
    _isValidPhoneJob = _input.isNotEmpty && _input.length >= 3;
    _phoneNumberJob = valuePhoneJob;
    print(_phoneNumberJob);
    notifyListeners();
  }

  void validateInputPhonePerson(String valuePhonePerson) {
    print('value entrado desde input: ${valuePhonePerson}');
    _input = valuePhonePerson;
    _isValidPhonePerson = _input.isNotEmpty && _input.length >= 3;
    _phoneNumberPerson = valuePhonePerson;
    print(_phoneNumberPerson);
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
    var id = 'RSR1.201013.002';

    _deviceInfo = (await _deviceInfoRepository.getDeviceInfo()) as DeviceInfo?;

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
    _isLoading = true;
    notifyListeners();

    if (_nameUser.isNotEmpty &&
        _firsName.isNotEmpty &&
        _lastName.isNotEmpty &&
        _phoneNumberJob.isNotEmpty &&
        _phoneNumberPerson.isNotEmpty) {
      _deviceInfo =
          (await _deviceInfoRepository.getDeviceInfo()) as DeviceInfo?;

      var user = User(
        name: _nameUser,
        firstName: _firsName,
        lastName: _lastName,
        phoneNumber: _phoneNumberJob,
      );

      var rest = await _user.saveUser(user);
      if (rest == 200) {
        _bandera = true;
        _isLoading = false;
      }
    }
    notifyListeners();
  }
}
