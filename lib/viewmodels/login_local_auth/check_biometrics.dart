// import 'package:local_auth/local_auth.dart';

// Future<void> checkBiometrics() async {
//   bool canCheckBiometrics;
//   List<BiometricType> availableBiometrics;

//   final LocalAuthentication auth = LocalAuthentication();

//   try {
//     // Verifica si se puede usar la biometría
//     canCheckBiometrics = await auth.canCheckBiometrics;

//     // Obtén la lista de tipos de biometría disponibles
//     availableBiometrics = await auth.getAvailableBiometrics();

//     if (canCheckBiometrics) {
//       print("El dispositivo puede usar biometría.");
//     } else {
//       print("El dispositivo NO puede usar biometría.");
//     }

//     if (availableBiometrics.contains(BiometricType.fingerprint)) {
//       print("El dispositivo tiene lector de huellas dactilares.");
//     } else {
//       print("El dispositivo NO tiene lector de huellas dactilares.");
//     }
//   } catch (e) {
//     print(e);
//   }
// }
