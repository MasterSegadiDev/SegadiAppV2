import 'package:flutter/material.dart';
import 'package:segadi/core/theme/app_colors.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/domain/usecases/get_mapa_ubicaciones_usecase.dart';
import 'package:segadi/features/ubications/domain/usecases/registrar_movimiento_usecase.dart';

enum TipoMovimiento { pisoCamion, camionPiso, reacomodo }

enum FaseReacomodo { ninguno, origen, destino, none }

class ReacomodoTemporal {
  UbicacionEntity? origen;
  UbicacionEntity? destino;
  String? motivo; // Ej: "Desbloqueo de Orden #64"
}

class UbicacionesMapaViewModel extends ChangeNotifier {
  final GetMapaUbicacionesUseCase getMapaUbicacionesUseCase;
  final RegistrarMovimientoUseCase registrarMovimientoUseCase;
  dynamic movimientoActivo;

  TipoMovimiento? movimientoActaul;
  Map<String, dynamic>? datosMovimiento;

  FaseReacomodo _faseReacomodo = FaseReacomodo.ninguno;
  UbicacionEntity? _containerParaMover;

  String get serieEnGancho => _containerParaMover?.serie ?? "Sin Serie";

  UbicacionesMapaViewModel({
    required this.getMapaUbicacionesUseCase,
    required this.registrarMovimientoUseCase,
  });

  void cargarOrden(dynamic orden) {
    movimientoActivo = orden;
    notifyListeners();
  }

  bool get enModoReacomodo => _faseReacomodo != FaseReacomodo.ninguno;

  void activarReacomodo(UbicacionEntity contenedor) {
    _containerParaMover = contenedor; // Guardamos el objeto completo
    _faseReacomodo = FaseReacomodo.destino;
    notifyListeners();
  }

  void cancelarReacomodo() {
    _faseReacomodo = FaseReacomodo.ninguno; // Apaga la barra naranja
    _containerParaMover = null; // Suelta el contenedor "virtualmente"
    notifyListeners(); // Refresca la tableta para quitar la barra
  }

  /// 3. VALIDACIÓN DE SALIDA DIRECTA (La que ya tenías)
  bool puedeRealizarSalidaDirecta(
      UbicacionEntity asignado, List<UbicacionEntity> niveles) {
    int nivelObj = int.tryParse(asignado.nivel) ?? 0;
    // Si hay algún nivel superior ocupado, retorna false (bloqueado)
    return !niveles.any((n) =>
        (int.tryParse(n.nivel) ?? 0) > nivelObj &&
        n.estatus.toLowerCase() == 'used');
  }

  UbicacionesMapEntity? ubicacionesMapEntity;
  bool isLoading = false;
  String? errorMessage;

  Movimiento? movimientoEnProceso;
  UbicacionEntity? ubicacionOrigen;
  UbicacionEntity? ubicacionDestino;

  String? mensajeValidacion;

// paleta de colores para mostrar los espacios
  Color getEspacioColor(List<UbicacionEntity> niveles) {
    int libres = niveles.where((n) => n.estatus.toLowerCase() == "free").length;

    switch (libres) {
      case 3:
        return AppColors.disponibilidad3;
      case 2:
        return AppColors.disponibilidad2;
      case 1:
        return AppColors.disponibilidad1;
      case 0:
        return AppColors.disponibilidad0;
      default:
        return AppColors.background;
    }
  }

//recibe el tipo de movimiento y lo filtra
  void prepararMovimiento([Movimiento? mov]) {
    // Los corchetes [] lo hacen opcional
    ubicacionDestino = null;
    ubicacionOrigen = null;
    mensajeValidacion = null;

    if (mov != null) {
      // CASO: VIENE DE LA LISTA (Piso-Camion o Camion-Piso)
      movimientoEnProceso = mov;
      final tipoStr = mov.tipoMovimiento.toLowerCase();

      if (tipoStr.contains('piso-camion')) {
        movimientoActaul = TipoMovimiento.pisoCamion;
      } else if (tipoStr.contains('camion-piso')) {
        movimientoActaul = TipoMovimiento.camionPiso;
      }

      // Buscamos el origen automáticamente por la serie que viene en el movimiento
      if (ubicacionesMapEntity != null && mov.serieReal.isNotEmpty) {
        try {
          ubicacionOrigen = ubicacionesMapEntity!.ubicaciones.firstWhere(
            (u) => u.serie == mov.serieReal,
          );
        } catch (_) {
          ubicacionOrigen = null;
        }
      }
    } else {
      // CASO: REACOMODO MANUAL (Botón flotante)
      movimientoEnProceso = null;
      movimientoActaul = TipoMovimiento.reacomodo;
      print("REACOMODO");
    }

    notifyListeners();
  }

  void intentarSeleccionarUbicacion(
      UbicacionEntity ubi, List<UbicacionEntity> nivelesDelEspacio) {
    mensajeValidacion = null;

    switch (movimientoActaul) {
      case TipoMovimiento.pisoCamion:
        _manejarPisoCamion(ubi, nivelesDelEspacio);
        break;
      case TipoMovimiento.camionPiso:
        _manejarCamionPiso(ubi, nivelesDelEspacio);
        break;
      case TipoMovimiento.reacomodo:
        _manejarReacomodo(ubi, nivelesDelEspacio);
        break;
      default:
        break;
    }
    notifyListeners();
  }

  List<int> obtenerNivelesObstruyendo(List<UbicacionEntity> nivelesDelEspacio) {
    List<int> obstrucciones = [];
    if (movimientoActivo == null) return obstrucciones;

    // Sacamos el level de la orden (ej: "2")
    int nivelOrden = int.tryParse(movimientoActivo['level'].toString()) ?? 0;

    for (var n in nivelesDelEspacio) {
      // Usamos el ID o posición de la entidad para saber su nivel físico
      // Suponiendo que tu entidad tiene un campo 'nivelFisico'
      int nivelFisico = int.tryParse(n.nivel) ?? 0;

      if (nivelFisico > nivelOrden && n.estatus.toLowerCase() == 'used') {
        obstrucciones.add(nivelFisico);
      }
    }
    return obstrucciones;
  }

  void _manejarPisoCamion(UbicacionEntity ubi, List<UbicacionEntity> niveles) {
    // Primero: Debe estar ocupado para poder sacarlo
    if (ubi.estatus.toLowerCase() == 'free') {
      mensajeValidacion = "Esta ubicación está vacía.";
      return;
    }
    // Segundo: Aplicamos regla de extracción (nada encima)
    if (puedeExtraer(ubi, niveles)) {
      ubicacionOrigen = ubi; // Confirmamos que este es el que sale
    } else {
      mensajeValidacion =
          "Bloqueado: Mueva los contenedores superiores primero.";
    }
  }

  void _manejarCamionPiso(UbicacionEntity ubi, List<UbicacionEntity> niveles) {
    // Primero: Debe estar libre para poder ponerlo
    if (ubi.estatus.toLowerCase() != 'free') {
      mensajeValidacion = "Ubicación ocupada.";
      return;
    }
    // Segundo: Aplicamos regla de depósito (sustento abajo)
    if (puedeDepositar(ubi, niveles)) {
      ubicacionDestino = ubi;
    } else {
      mensajeValidacion = "Inválido: Debe usar el nivel inferior disponible.";
    }
  }

  void _manejarReacomodo(UbicacionEntity ubi, List<UbicacionEntity> niveles) {
    // Si no tenemos origen, estamos seleccionando qué mover
    if (ubicacionOrigen == null) {
      if (ubi.estatus.toLowerCase() == 'used' && puedeExtraer(ubi, niveles)) {
        ubicacionOrigen = ubi;
      } else {
        mensajeValidacion = "Seleccione un contenedor sin nada encima.";
      }
    }
    // Si ya tenemos origen, estamos seleccionando a dónde llevarlo
    else {
      if (ubi.estatus.toLowerCase() == 'free' && puedeDepositar(ubi, niveles)) {
        ubicacionDestino = ubi;
      } else {
        mensajeValidacion = "Destino inválido para reacomodo.";
      }
    }
  }

  Future<void> cargarMapa() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resultado = await getMapaUbicacionesUseCase.execute();

      if (resultado != null) {
        // DEBUG: Verifica que las listas no lleguen vacías
        print("✅ Áreas: ${resultado.areas.length}");
        print("✅ Ubicaciones: ${resultado.ubicaciones.length}");

        ubicacionesMapEntity = resultado;
      } else {
        errorMessage = "El servidor devolvió un mapa vacío.";
      }
    } catch (e, stacktrace) {
      // CRÍTICO: Imprime el stacktrace para ver si el error es en el Factory fromJson
      print("❌ ERROR FATAL AL CARGAR MAPA: $e");
      print("DEBUG STACKTRACE: $stacktrace");

      errorMessage = "Error al procesar datos del mapa: $e";
    } finally {
      isLoading = false;
      _faseReacomodo = FaseReacomodo.ninguno;
      _containerParaMover = null;
      notifyListeners();
    }
  }

  /// Selecciona una ubicación del mapa como destino
  void seleccionarDestino(UbicacionEntity ubi) {
    // Solo permitimos seleccionar si la ubicación está libre (Free)
    if (ubi.estatus.toLowerCase() == 'free') {
      ubicacionDestino = ubi;
      notifyListeners();
    } else {
      // Opcional: Notificar que la ubicación está ocupada
      errorMessage = "La ubicación ${ubi.codigo} ya está ocupada.";
      notifyListeners();
    }
  }

  /// Ejecuta el registro final en el servidor
  Future<bool> confirmarRegistro(String comentarios) async {
    if (movimientoEnProceso == null || ubicacionDestino == null) {
      errorMessage = "Falta seleccionar un movimiento o un destino.";
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    final success = await registrarMovimientoUseCase.execute(
      movimientoId: movimientoEnProceso!.id,
      ubicacionDestinoId: ubicacionDestino!.id,
      comentarios: comentarios,
    );

    if (success) {
      // Limpiamos la selección tras el éxito
      movimientoEnProceso = null;
      ubicacionDestino = null;
      ubicacionOrigen = null;
      await cargarMapa(); // Refrescamos el mapa para ver los nuevos estados
    } else {
      errorMessage = "Error al registrar el movimiento en el sistema.";
    }

    isLoading = false;
    notifyListeners();
    return success;
  }

  ////// funciones para el movimiento de contenedores //////////////
  ///
  ///

  /// funcion para poner Piso - Camion
  bool puedeExtraer(
      UbicacionEntity nivelTocado, List<UbicacionEntity> nivelesDelEspacio) {
    // Si toco el Nivel 1, reviso si el 2 o 3 están ocupados (Used)
    if (nivelTocado.nivel == "1") {
      return !nivelesDelEspacio.any(
          (n) => (n.nivel == "2" || n.nivel == "3") && n.estatus == "Used");
    }
    // Si toco el Nivel 2, reviso si el 3 está ocupado
    if (nivelTocado.nivel == "2") {
      return !nivelesDelEspacio
          .any((n) => n.nivel == "3" && n.estatus == "Used");
    }
    // El Nivel 3 siempre se puede extraer si está ocupado
    return true;
  }

  /// funcion y logica para el movimiento piso - camion
  ///

  //pendiente de revisar por que esta realiza la validacion
  // bool puedeRealizarSalidaDirecta(
  //     UbicacionEntity asignada, List<UbicacionEntity> todosLosNiveles) {
  //   // Regla: No debe haber ningún contenedor en niveles superiores con estatus 'Used'

  //   int nivelAsignado =
  //       int.parse(asignada.nivel); // Convertimos "1", "2" o "3" a int

  //   // Buscamos si hay niveles mayores al asignado que estén ocupados
  //   bool estaBloqueado = todosLosNiveles.any((n) {
  //     int nivelIterado = int.parse(n.nivel);
  //     return nivelIterado > nivelAsignado && n.estatus.toLowerCase() == 'used';
  //   });

  //   return !estaBloqueado;
  // }

  /// funcion y logica camion - piso
  ///

  bool puedeDepositar(
      UbicacionEntity nivelTocado, List<UbicacionEntity> nivelesDelEspacio) {
    // 1. El espacio debe estar libre
    if (nivelTocado.estatus.toLowerCase() != 'free') return false;

    int nivelDeseado = int.parse(nivelTocado.nivel);

    // Si es Nivel 1, siempre se puede (si está free)
    if (nivelDeseado == 1) return true;

    // Si es Nivel 2 o 3, verificamos que el nivel inmediatamente inferior esté ocupado
    int nivelInferior = nivelDeseado - 1;
    return nivelesDelEspacio.any((n) =>
        int.parse(n.nivel) == nivelInferior &&
        n.estatus.toLowerCase() == 'used');
  }

  void finalizarReacomodo(UbicacionEntity destino) async {
    // 1. Aquí harías tu petición HTTP a la API de reacomodo
    // await api.moverContenedor(_containerParaMover.serie, destino.id);

    print(
        "Movimiento exitoso de ${_containerParaMover?.serie} a ${destino.area}-${destino.espacio}-${destino.nivel}");

    // 2. Limpiamos el modo reacomodo
    _faseReacomodo = FaseReacomodo.ninguno;
    _containerParaMover = null;

    // 3. Refrescamos el mapa para que el contenedor aparezca en su nuevo lugar
    await cargarMapa();

    // 4. Avisamos a la UI para que quite la barra naranja
    notifyListeners();
  }
}
