import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/auth/domain/use_cases/login_usecase.dart';
import 'package:segadi/features/auth/presentation/view_models/auth_notifier.dart';

import '../state/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    return AuthNotifier(
      getIt<LoginUseCase>(),
    );
  },
);
