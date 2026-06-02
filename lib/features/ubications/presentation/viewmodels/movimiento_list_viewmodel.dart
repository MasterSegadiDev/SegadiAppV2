import 'package:flutter/material.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_entity.dart';
import 'package:segadi/features/ubications/domain/usecases/get_movimientos_usecase.dart';
import 'package:segadi/features/ubications/enums/contenedor_objetivo.dart';

class MovimientoListViewModel extends ChangeNotifier {
  final GetMovimientosUseCase getMovimientosUseCase;

  MovimientoListViewModel({
    required this.getMovimientosUseCase,
  });

  List<MovimientoEntity> movimientos = [];

  bool isLoading = false;

  String? errorMessage;

  Future<void> loadMovimientos(String siteId) async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    final result = await getMovimientosUseCase.execute(siteId);

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (list) {
        movimientos = list.map((m) {
          return MovimientoEntity(
            id: m.id,
            folio: m.folio,
            tipo: m.tipo, // 👈 YA VIENE BIEN DEL MODEL
            area: m.area,
            espacio: m.espacio,
            nivel: m.nivel,
            contenedorA: m.contenedorA,
            contenedorB: m.contenedorB,
            contenedorObjetivo: m.contenedorObjetivo,
            servicio: m.servicio,
            operador: m.operador,
            unidad: m.unidad,
            localUnidad: m.localUnidad,
            estadoContenedor: m.estadoContenedor,
            ubicacionId: m.ubicacionId,
            estatus: m.estatus,
            operadorLocal: m.operadorLocal,
            comentarios: m.comentarios,
          );
        }).toList();
      },
    );

    isLoading = false;

    notifyListeners();
  }

  ContenedorObjetivo convertirContenedorObjetivo(
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'contenedor a':
        return ContenedorObjetivo.a;

      case 'contenedor b':
        return ContenedorObjetivo.b;

      default:
        return ContenedorObjetivo.a;
    }
  }
}
