import 'package:segadi/core/device/firebase/firebase_service.dart';

import '../repositories/fcm_token_repository.dart';

class RegisterFcmTokenUseCase {
  final FirebaseService firebaseService;
  final FcmTokenRepository repository;

  RegisterFcmTokenUseCase({
    required this.firebaseService,
    required this.repository,
  });

  Future<void> call() async {
    final token = await firebaseService.getToken();

    if (token == null || token.isEmpty) {
      throw StateError('No se pudo obtener el token FCM');
    }

    await repository.registerToken(token);
  }
}
