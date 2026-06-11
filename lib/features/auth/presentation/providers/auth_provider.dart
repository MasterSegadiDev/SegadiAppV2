import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/auth/domain/use_cases/login_usecase.dart';
import 'package:segadi/features/auth/presentation/view_models/auth_notifier.dart';

import '../../data/datasources/auth_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';

import '../state/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final datasource = AuthRemoteDatasourceImpl();

    final repository = AuthRepositoryImpl(
      datasource,
    );

    final loginUseCase = LoginUseCase(
      repository,
    );

    return AuthNotifier(
      loginUseCase,
    );
  },
);
