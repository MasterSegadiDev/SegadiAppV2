import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

// ignore: camel_case_types
class localAuth {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;
    try {
      return await _auth.authenticate(
          localizedReason: "Lector de Biometria para SEGADI",
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: false,
            biometricOnly: true,
          ));
    } on PlatformException {
      return false;
    }
  }
}
