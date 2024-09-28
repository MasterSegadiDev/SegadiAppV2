import 'package:device_info_plus/device_info_plus.dart';
import 'package:segadi/model/device/device.dart';

class DeviceInfoRespository {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<DeviceInfo> getDeviceInfo() async {
    final deviceInfo = await _deviceInfoPlugin.androidInfo;
    final deviceData = deviceInfo.data;
    print(
        'IDE DEL DISPOSITIVO: ${deviceData['id']} MODELO DEL DISPOSITIVO: ${deviceData['model']} DEVICE: ${deviceData['device']} HOST: ${deviceData['host']}');

    return DeviceInfo(
      idDevice: deviceData['id'] ?? 'Unknown',
      hostDevice: deviceData['host'] ?? 'Unknown',
      modelDevice: deviceData['model'] ?? 'Unknown',
      deviceInfo: deviceData['device'] ?? 'Unknown',
    );
  }
}
