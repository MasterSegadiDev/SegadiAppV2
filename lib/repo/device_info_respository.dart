import 'package:device_info_plus/device_info_plus.dart';
import 'package:segadi/models/device/device.dart';

class DeviceInfoRespository {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<DeviceInfo> getDeviceInfo() async {
    final deviceInfo = await _deviceInfoPlugin.androidInfo;
    final deviceData = deviceInfo.data;

    return DeviceInfo(
      idDevice: deviceData['id'] ?? 'Unknown',
      hostDevice: deviceData['host'] ?? 'Unknown',
      modelDevice: deviceData['model'] ?? 'Unknown',
      deviceInfo: deviceData['device'] ?? 'Unknown',
    );
  }
}
