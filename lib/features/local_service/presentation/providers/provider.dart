import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/local_service/presentation/states/stretch_state.dart';
import 'package:segadi/features/local_service/presentation/viewmodels/stretch_viewmodel.dart';

import '../../domain/enums/tramo_status.dart';

final tramoProvider = NotifierProvider<TramoNotifier, TramoState>(
  TramoNotifier.new,
);

class TramoNotifier extends Notifier<TramoState> {
  late final TramoViewModel _viewModel;

  String? _operadorId;

  @override
  TramoState build() {
    _viewModel = getIt<TramoViewModel>();

    return const TramoInitial();
  }

  Future<void> load(
    String operadorId,
  ) async {
    debugPrint(
      '🟡 TRAMO PROVIDER load: $operadorId',
    );
    _operadorId = operadorId;

    state = const TramoLoading();

    state = await _viewModel.getActiveTramo(
      operadorId,
    );
    debugPrint(
      '🟢 TRAMO STATE: ${state.runtimeType}',
    );
  }

  Future<void> refresh() async {
    final operadorId = _operadorId;

    if (operadorId == null) {
      return;
    }

    state = await _viewModel.getActiveTramo(
      operadorId,
    );
  }

  Future<bool> changeStatus(
    TramoStatus newStatus,
  ) async {
    final current = state;

    if (current is! TramoLoaded) {
      return false;
    }

    state = current.copyWith(
      updatingStatus: true,
    );

    final success = await _viewModel.updateStatus(
      referralId: current.tramo.referralId,
      tramoIndex: current.tramo.tramoIndex,
      status: newStatus,
    );

    if (!success) {
      state = current.copyWith(
        updatingStatus: false,
      );

      return false;
    }

    await refresh();

    return true;
  }

  void clear() {
    _operadorId = null;

    state = const TramoInitial();
  }
}
