import 'package:segadi/features/local_service/domain/usecases/get_active_stretch.dart';
import 'package:segadi/features/local_service/domain/usecases/update_stretch_status.dart';
import 'package:segadi/features/local_service/presentation/states/stretch_state.dart';

import '../../domain/enums/tramo_status.dart';

class TramoViewModel {
  final GetActiveTramoUseCase getActiveTramoUseCase;

  final UpdateTramoStatusUseCase updateTramoStatusUseCase;

  TramoViewModel({
    required this.getActiveTramoUseCase,
    required this.updateTramoStatusUseCase,
  });

  Future<TramoState> getActiveTramo(
    String operadorId,
  ) async {
    try {
      final tramo = await getActiveTramoUseCase(
        operadorId,
      );

      if (tramo == null) {
        return const TramoEmpty();
      }

      return TramoLoaded(
        tramo: tramo,
      );
    } catch (e) {
      return TramoError(
        message: e.toString(),
      );
    }
  }

  Future<bool> updateStatus({
    required String referralId,
    required int tramoIndex,
    required TramoStatus status,
  }) async {
    try {
      await updateTramoStatusUseCase(
        referralId: referralId,
        tramoIndex: tramoIndex,
        status: status,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
