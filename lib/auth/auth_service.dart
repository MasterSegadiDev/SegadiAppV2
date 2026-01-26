import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> loginWithUsername({
    required String username,
    required String password,
  }) async {
    final email = '$username@segadi.app';

    print('este es email que vas a enviar a firebase: ${email}');

    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }
}
