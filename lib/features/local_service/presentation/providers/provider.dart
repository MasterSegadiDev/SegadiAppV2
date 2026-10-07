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
  TramoViewModel get _viewModel => getIt<TramoViewModel>();

  //String? _operadorId;

  @override
  TramoState build() => const TramoInitial();

  Future<void> load() async {
    state = const TramoLoading();
    state = await _viewModel.getActiveTramo();
  }

  Future<void> refresh() async {
    state = await _viewModel.getActiveTramo();
  }

  Future<bool> changeStatus(TramoStatus newStatus) async {
    final current = state;
    if (current is! TramoLoaded) return false;

    state = current.copyWith(updatingStatus: true);

    try {
      final success = await _viewModel.updateStatus(
        referralId: current.tramo.referralId,
        tramoIndex: current.tramo.tramoIndex,
        status: newStatus,
      );

      if (!success) {
        state = current.copyWith(updatingStatus: false);
        return false;
      }

      // Reemplaza el estado completo con el tramo nuevo (updatingStatus = false)
      await refresh();
      return true;
    } catch (_) {
      state = current.copyWith(updatingStatus: false);
      return false;
    }
  }

  void clear() {
    //_operadorId = null;

    state = const TramoInitial();
  }
}
