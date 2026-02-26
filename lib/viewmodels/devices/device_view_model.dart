// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:segadi/models/device/device.dart';
// import 'package:segadi/repo/device_info_respository.dart';
// import 'package:segadi/services/getDataDevice.dart';

// class DeviceInfoViewModel extends ChangeNotifier {
//   // final DeviceInfo _deviceModel = DeviceInfo();
//   final DeviceInfoRespository _deviceInfoRepository;
//   final InfoDeviceSystemERP _infoDeviceSystemERP;

//   DeviceInfo? _deviceInfo;
//   bool _isLoading = false;

//   DeviceInfoViewModel(this._deviceInfoRepository, this._infoDeviceSystemERP);

//   String _errorMessage = '';
//   String get errorMessage => _errorMessage;

//   DeviceInfo? get deviceInfo => _deviceInfo;
//   bool get isLoading => _isLoading;

//   DeviceInfo? _deviceInfoServe;
//   DeviceInfo? get deviceInfoServe => _deviceInfoServe;

//   bool _isValidName = false;
//   bool get isValidName => _isValidName;

//   bool _isValid = false;
//   bool get isValid => _isValid;

//   late var _device_on_system_app = null;
//   get device_on_system_app => _device_on_system_app;

//   late var _device_on_system = null;
//   get device_on_system => _device_on_system;

//   bool _isValidFirstName = false;
//   bool get isValidFirstName => _isValidFirstName;

//   bool _isValidLastName = false;
//   bool get isValidLastName => _isValidLastName;

//   bool _isValidPhoneJob = false;
//   bool get isValidPhoneJob => _isValidPhoneJob;

//   bool _isValidPhonePerson = false;
//   bool get isValidPhonePerson => _isValidPhonePerson;

//   bool _bandera = false;
//   bool get bandera => _bandera;

//   String _nameUser = '';
//   String get nameUser => _nameUser;

//   set nameUser(String value) {
//     _nameUser = value;
//     notifyListeners();
//   }

//   String _firsName = '';
//   String get firstName => _firsName;

//   set firstName(String value) {
//     _firsName = value;
//     notifyListeners();
//   }

//   String _lastName = '';
//   String get lastName => _lastName;

//   set lastName(String value) {
//     _lastName = value;
//     notifyListeners();
//   }

//   String _phoneNumberJob = '';
//   String get phoneNumberJob => _phoneNumberJob;

//   String _phoneNumberPerson = '';
//   String get phoneNumberPerson => _phoneNumberPerson;

//   BuildContext get context => context;

//   set phoneNumber(String value) {
//     _phoneNumberJob = value;
//     notifyListeners();
//   }

//   String _input = '';
//   bool _isValidInput = true;

//   String get input => _input;
//   bool get isValidInput => _isValidInput;

//   void validateInputName(String valueName) {
//     print('value entrado desde input: ${valueName}');
//     _input = valueName;
//     _isValidName = _input.isNotEmpty && _input.length >= 3;
//     _nameUser = valueName;
//     print(_nameUser);
//     notifyListeners();
//   }

//   void validateInputFirstName(String valueFirstName) {
//     print('value entrado desde input: ${valueFirstName}');
//     _input = valueFirstName;
//     _isValidFirstName = _input.isNotEmpty && _input.length >= 3;
//     _firsName = valueFirstName;
//     print(_firsName);
//     notifyListeners();
//   }

//   void validateInputPhoneJob(String valuePhoneJob) {
//     print('value entrado desde input: ${valuePhoneJob}');
//     _input = valuePhoneJob;
//     _isValidPhoneJob = _input.isNotEmpty && _input.length >= 3;
//     _phoneNumberJob = valuePhoneJob;
//     print(_phoneNumberJob);
//     notifyListeners();
//   }

//   void validateInputPhonePerson(String valuePhonePerson) {
//     print('value entrado desde input: ${valuePhonePerson}');
//     _input = valuePhonePerson;
//     _isValidPhonePerson = _input.isNotEmpty && _input.length >= 3;
//     _phoneNumberPerson = valuePhonePerson;
//     print(_phoneNumberPerson);
//     notifyListeners();
//   }

//   Future<void> fetchDeviceInfo() async {
//     _isLoading = true;
//     notifyListeners();

//     _deviceInfo = (await _deviceInfoRepository.getDeviceInfo()) as DeviceInfo?;

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<List> validateDeviceInfo() async {
//     _errorMessage.isEmpty;
//     notifyListeners();

//     _deviceInfo = (await _deviceInfoRepository.getDeviceInfo()) as DeviceInfo?;
//     http.Response response = await _infoDeviceSystemERP.getDataDeviceSystem();
//     print('data device: ${json.decode(response.body)}');
//     Map responseMap = json.decode(response.body);

//     if (_deviceInfo!.idDevice == responseMap["ide_dispositivo"]) {
//       _isValid = true;
//     } else {
//       _isValid = false;
//     }
//     if (responseMap['device_on_system'] == null) {
//       _errorMessage = responseMap['error_message'];
//       _isValid = false;
//       _device_on_system = null;
//       _device_on_system_app = false;
//     }
//     if (responseMap['device_on_system_app'] == null) {
//       _errorMessage = responseMap['error_message'];
//       _isValid = false;
//       _device_on_system = true;
//       _device_on_system_app = null;
//     }

//     var array = [
//       _errorMessage, //0
//       _isValid, //1
//       _device_on_system, //2
//       _device_on_system_app //3
//     ];

//     print(array);

//     return array;
//   }

//   Future<void> saveDataDevice() async {
//     _isLoading = true;
//     notifyListeners();

//     if (_nameUser.isNotEmpty &&
//         _firsName.isNotEmpty &&
//         _lastName.isNotEmpty &&
//         _phoneNumberJob.isNotEmpty &&
//         _phoneNumberPerson.isNotEmpty) {
//       _deviceInfo =
//           (await _deviceInfoRepository.getDeviceInfo()) as DeviceInfo?;

//       var newUserDevice = DeviceInfo(
//           name: _nameUser,
//           firstName: _firsName,
//           lastName: _lastName,
//           phoneNumberJob: _phoneNumberJob,
//           phoneNumberPerson: _phoneNumberPerson,
//           idDevice: _deviceInfo!.idDevice,
//           hostDevice: _deviceInfo!.hostDevice,
//           modelDevice: _deviceInfo!.modelDevice,
//           deviceInfo: _deviceInfo!.deviceInfo);

//       http.Response response =
//           await _infoDeviceSystemERP.saveDataDevice(newUserDevice);

//       // var rest = await _user.saveUser(user);
//       if (response.statusCode == 200) {
//         _bandera = true;
//         _isLoading = false;
//       }
//     }
//     notifyListeners();
//   }
// }
