import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/auth/data/models/user_model.dart';
import 'package:segadi/security/session_manager.dart';

final currentUserProvider = FutureProvider<UserModel?>(
  (
    ref,
  ) async {
    return SessionManager.getCurrentUser();
  },
);
