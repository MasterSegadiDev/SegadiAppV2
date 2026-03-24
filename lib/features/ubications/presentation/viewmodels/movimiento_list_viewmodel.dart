import 'package:flutter/material.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';
import 'package:segadi/features/ubications/domain/usecases/get_movimientos_usecase.dart';

class MovimientoListViewModel extends ChangeNotifier {
  final GetMovimientosUseCase getMovimientosUseCase;

  MovimientoListViewModel({required this.getMovimientosUseCase});

  List<Movimiento> movimientos = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMovimientos(String siteId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await getMovimientosUseCase.execute(siteId);

    result.fold(
      (error) => errorMessage = error.toString(),
      (list) => movimientos = list,
    );

    isLoading = false;
    notifyListeners();
  }
}
