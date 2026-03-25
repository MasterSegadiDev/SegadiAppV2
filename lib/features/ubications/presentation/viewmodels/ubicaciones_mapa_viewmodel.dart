import 'package:flutter/material.dart';
import 'package:segadi/core/theme/app_colors.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/domain/usecases/get_mapa_ubicaciones_usecase.dart';
import 'package:segadi/features/ubications/domain/usecases/registrar_movimiento_usecase.dart';
import 'package:segadi/utils/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TipoMovimiento { pisoCamion, camionPiso, reacomodo }

enum FaseReacomodo { ninguno, origen, destino, none }

class ReacomodoTemporal {
  UbicacionEntity? origen;
  UbicacionEntity? destino;
  String? motivo; // Ej: "Desbloqueo de Orden #64"
}

class UbicacionesMapaViewModel extends ChangeNotifier {
  final RegistrarMovimientoUseCase reacomodoUseCase;
  final GetMapaUbicacionesUseCase getMapaUbicacionesUseCase;

  FaseReacomodo get faseReacomodo => _faseReacomodo;
  UbicacionEntity? get containerParaMover => _containerParaMover;

  dynamic movimientoActivo;

  TipoMovimiento? movimientoActaul;
  Map<String, dynamic>? datosMovimiento;

  FaseReacomodo _faseReacomodo = FaseReacomodo.ninguno;
  UbicacionEntity? _containerParaMover;

  String get serieEnGancho => _containerParaMover?.serie ?? "Sin Serie";

  UbicacionesMapaViewModel({
    required this.getMapaUbicacionesUseCase,
    required this.reacomodoUseCase,
  });

  void cargarOrden(dynamic orden) {
    movimientoActivo = orden;

    print('movimiento activo ${movimientoActivo}');
    notifyListeners();
  }

  bool get enModoReacomodo => _faseReacomodo != FaseReacomodo.ninguno;

  void activarReacomodo(UbicacionEntity contenedor) {
    // 1. Sincronizamos: El contenedor que la app detectó como bloqueador
    // se convierte en nuestro ORIGEN para el movimiento.
    ubicacionOrigen = contenedor;
    _containerParaMover =
        contenedor; // Mantén esta si la usas para mostrar la serie en la UI

    // 2. Cambiamos la fase para que el mapa ahora acepte el toque de DESTINO
    _faseReacomodo = FaseReacomodo.destino;

    // 3. Limpiamos cualquier destino previo por si acaso
    ubicacionDestino = null;

    print(
        "Propagando Origen Inteligente: ${contenedor.serie} en nivel ${contenedor.nivel}");
    notifyListeners();
  }

  void cancelarReacomodo() {
    _faseReacomodo = FaseReacomodo.ninguno; // Apaga la barra naranja
    _containerParaMover = null;
    ubicacionDestino = null;
    ubicacionOrigen = null; // Suelta el contenedor "virtualmente"
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

  UbicacionEntity obtenerContenedorPrioritario(
      List<UbicacionEntity> niveles, UbicacionEntity objetivo) {
    // Convertimos el nivel del objetivo a entero una sola vez
    final int nivelObjetivo = int.parse(objetivo.nivel.toString());

    final bloqueadores = niveles.where((n) {
      // 1. Convertimos el nivel de la iteración actual a entero
      final int nivelActual = int.parse(n.nivel.toString());

      // 2. Ahora sí podemos usar '>'
      return nivelActual > nivelObjetivo && n.estatus.toLowerCase() != 'free';
    }).toList();

    if (bloqueadores.isEmpty) {
      return objetivo;
    } else {
      // También corregimos el sort para que sea numérico
      bloqueadores.sort((a, b) => int.parse(b.nivel.toString())
          .compareTo(int.parse(a.nivel.toString())));
      return bloqueadores.first;
    }
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

  void seleccionarOrigen(UbicacionEntity ubi) {
    // 1. Validamos que la ubicación NO esté libre (debe haber algo que mover)
    if (ubi.estatus.toLowerCase() != 'free') {
      ubicacionOrigen = ubi;

      // 2. Limpiamos el destino anterior por seguridad
      // (si el operador cambia de opinión sobre qué contenedor mover)
      ubicacionDestino = null;
      errorMessage = null; // Limpiamos errores previos

      print("Origen fijado: ${ubi.serie} en ${ubi.codigo}");
      notifyListeners();
    } else {
      // 3. Error: No puedes mover un espacio vacío
      errorMessage =
          "La ubicación ${ubi.codigo} está vacía. Selecciona un contenedor.";
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

  void limpiarSeleccion() {
    ubicacionOrigen = null;
    ubicacionDestino = null;
    notifyListeners();
  }

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
    final user = UserSession();
    final siteId = user.siteId;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final movimiento = MovimientoRegistro(
      crane_movement_id: null,
      movement_type: 'Reacomodo',
      crane_operator_id: user.id.toString(),
      container_location_id: int.parse(ubicacionOrigen!.id),
      new_container_location_id: ubicacionDestino!.id,
      container_number: _containerParaMover?.serie,
      status: null,
      token: token,
      weight: '',
      document_name: '',
      document: '',
      site_id: siteId ?? '',
    );

    await reacomodoUseCase.execute(movimiento);

    // 2. Limpiamos el modo reacomodo
    _faseReacomodo = FaseReacomodo.ninguno;
    _containerParaMover = null;

    // 3. Refrescamos el mapa para que el contenedor aparezca en su nuevo lugar
    await cargarMapa();

    // 4. Avisamos a la UI para que quite la barra naranja
    notifyListeners();
  }

  Future<void> ejecutarDespachoPisoCamion(UbicacionEntity ubi) async {
    print('ejecutando movimiento PISO-CAMION');
    final user = UserSession();
    final siteId = user.siteId;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final movimiento = MovimientoRegistro(
      crane_movement_id: movimientoEnProceso!.id,
      movement_type: 'Piso-Camion',
      crane_operator_id: user.id.toString(),
      container_location_id: int.parse(ubi.id),
      new_container_location_id: null,
      container_number: _containerParaMover?.serie,
      status: null,
      token: token,
      weight: '',
      document_name: '',
      document: '',
      site_id: siteId ?? '',
    );

    debugPrint('crane_movement_id ${movimiento.crane_movement_id}');

    //await reacomodoUseCase.execute(movimiento);

    //await cargarMapa();

    // 4. Avisamos a la UI para que quite la barra naranja
    notifyListeners();
  }
}
