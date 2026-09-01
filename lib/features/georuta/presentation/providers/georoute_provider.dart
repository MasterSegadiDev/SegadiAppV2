import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/features/georuta/presentation/state/georoute_state.dart';

import '../../../../app/di/injection_container.dart';
import '../viewmodels/georoute_viewmodel.dart';

final georouteViewModelProvider =
    StateNotifierProvider.autoDispose<GeorouteViewModel, GeorouteState>(
  (ref) {
    final viewModel = getIt<GeorouteViewModel>();

    ref.onDispose(
      viewModel.dispose,
    );

    return viewModel;
  },
);
