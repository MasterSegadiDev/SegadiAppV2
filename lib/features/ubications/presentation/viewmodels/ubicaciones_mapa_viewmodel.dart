import 'package:flutter/material.dart';

import 'package:segadi/features/ubications/domain/entities/movimiento_entity.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';
import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';

import 'package:segadi/features/ubications/domain/usecases/get_mapa_ubicaciones_usecase.dart';
import 'package:segadi/features/ubications/domain/usecases/registrar_movimiento_usecase.dart';

import 'package:segadi/features/ubications/presentation/viewmodels/mapa_movimiento_state.dart';

import 'package:segadi/features/ubications/enums/tipo_movimiento.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UbicacionesMapaViewModel extends ChangeNotifier {
  final GetMapaUbicacionesUseCase getMapaUbicacionesUseCase;

  final RegistrarMovimientoUseCase registrarMovimientoUseCase;

  UbicacionesMapaViewModel({
    required this.getMapaUbicacionesUseCase,
    required this.registrarMovimientoUseCase,
  });

  // ==============================
  // REACOMODO STATE
  // ==============================
  UbicacionEntity? origenReacomodo;
  UbicacionEntity? destinoReacomodo;

  UbicacionEntity? origenManual;
  UbicacionEntity? destinoManual;

  UbicacionEntity? objetivoFinal;
  List<UbicacionEntity> bloqueadores = [];

  /*
  =========================================================
  STATE
  =========================================================
  */

  MapaMovimientoState _state = MapaMovimientoState.initial();
  MapaMovimientoState get state => _state;

  String? _token;
  String? get token => _token;

  void _emit(
    MapaMovimientoState newState,
  ) {
    _state = newState;

    notifyListeners();
  }

  /*
  =========================================================
  LOAD MAPA
  =========================================================
  */

  Future<void> cargarMapa() async {
    _emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final mapa = await getMapaUbicacionesUseCase.execute();

      if (mapa == null) {
        _emit(
          state.copyWith(
            isLoading: false,
            error: 'No se pudo cargar el mapa',
          ),
        );

        return;
      }

      _emit(
        state.copyWith(
          mapa: mapa,
          isLoading: false,
        ),
      );
    } catch (e) {
      _emit(
        state.copyWith(
          isLoading: false,
          error: 'Error cargando mapa: $e',
        ),
      );
    }
  }

  /*
  =========================================================
  HELPERS
  =========================================================
  */

  bool estaLibre(UbicacionEntity u) {
    return u.estado.toLowerCase() == 'free';
  }

  bool estaOcupado(UbicacionEntity u) {
    return u.estado.toLowerCase() == 'used';
  }

  /*
  =========================================================
  OBTENER NIVELES
  =========================================================
  */

  List<UbicacionEntity> obtenerNivelesEspacio(
    String area,
    int espacio,
  ) {
    final mapa = state.mapa;

    if (mapa == null) {
      return [];
    }

    final niveles = mapa.ubicaciones.where(
      (u) {
        return u.area == area && u.espacio == espacio;
      },
    ).toList();

    niveles.sort(
      (a, b) => b.nivel.compareTo(a.nivel),
    );

    return niveles;
  }

  /*
  =========================================================
  OBTENER ESPACIOS
  =========================================================
  */

  List<int> getEspaciosNumericos(
    String area,
  ) {
    final mapa = state.mapa;

    if (mapa == null) {
      return [];
    }

    final espacios = mapa.ubicaciones
        .where(
          (u) => u.area == area,
        )
        .map(
          (u) => u.espacio,
        )
        .toSet()
        .toList();

    espacios.sort();

    return espacios;
  }

  /*
  =========================================================
  BUSCAR UBICACIÓN
  =========================================================
  */

  UbicacionEntity? buscarUbicacion(
    String area,
    int espacio,
    int nivel,
  ) {
    try {
      return state.mapa?.ubicaciones.firstWhere(
        (u) => u.area == area && u.espacio == espacio && u.nivel == nivel,
      );
    } catch (_) {
      return null;
    }
  }

  /*
  =========================================================
  VALIDAR EXTRACCIÓN
  =========================================================
  */

  bool puedeExtraerse(
    UbicacionEntity ubicacion,
    List<UbicacionEntity> niveles,
  ) {
    final hayAlgoArriba = niveles.any(
      (n) {
        return n.nivel > ubicacion.nivel && estaOcupado(n);
      },
    );

    return !hayAlgoArriba;
  }

  /*
  =========================================================
  BLOQUEADORES
  =========================================================
  */

  List<UbicacionEntity> obtenerBloqueadores() {
    final objetivo = state.contenedorObjetivo;

    if (objetivo == null) {
      return [];
    }

    return state.mapa!.ubicaciones.where((u) {
      return u.area == objetivo.area &&
          u.espacio == objetivo.espacio &&
          u.nivel > objetivo.nivel &&
          u.estaOcupado;
    }).toList()
      ..sort((a, b) => b.nivel.compareTo(a.nivel));
  }

  UbicacionEntity? obtenerBloqueadorPrincipal(
    UbicacionEntity objetivo,
    List<UbicacionEntity> niveles,
  ) {
    final bloqueadores = obtenerBloqueadores();

    if (bloqueadores.isEmpty) {
      return null;
    }

    return bloqueadores.first;
  }

  bool get tieneBloqueadores {
    return obtenerBloqueadores().isNotEmpty;
  }

  /*
  =========================================================
  REQUIERE REACOMODO
  =========================================================
  */

  bool requiereReacomodo(
    UbicacionEntity objetivo,
    List<UbicacionEntity> niveles,
  ) {
    return obtenerBloqueadores().isNotEmpty;
  }

  /*
  =========================================================
  INICIAR MOVIMIENTO
  =========================================================
  */

  Future<void> iniciarMovimiento(
    MovimientoEntity movimiento,
  ) async {
    _emit(
      state.copyWith(
        ordenActiva: movimiento,
        tipoMovimiento: movimiento.tipo,
        paso: PasoMovimiento.validarOrden,
      ),
    );

    switch (movimiento.tipo) {
      case TipoMovimiento.pisoCamion:
        await iniciarPisoCamion(movimiento);
        break;

      case TipoMovimiento.camionPiso:
        await iniciarCamionPiso(movimiento);
        break;

      case TipoMovimiento.reacomodoManual:
        iniciarReacomodoManual();
        break;

      default:
        _emit(
          state.copyWith(
            error: 'Tipo de movimiento inválido',
          ),
        );
    }
  }

  /*
  =========================================================
  BUSCAR CONTENEDOR ORDEN
  =========================================================
  */

  /*
  =========================================================
  VALIDAR SERIE
  =========================================================
  */

  bool validarSerie(
    MovimientoEntity mov,
    UbicacionEntity ubicacion,
  ) {
    final serieMapa = (ubicacion.serie ?? '').trim().toUpperCase();

    final serieOrden = mov.serieObjetivo.trim().toUpperCase();

    return serieMapa == serieOrden;
  }

  /*
  =========================================================
  MOVIMIENTO PISO -> CAMIÓN
  =========================================================
  */

  Future<void> iniciarPisoCamion(
    MovimientoEntity movimiento,
  ) async {
    // ========================================
    // 1. BUSCAR UBICACIÓN ORIGEN
    // ========================================
    final ubicacion = buscarUbicacion(
      movimiento.area,
      movimiento.espacio,
      movimiento.nivel,
    );

    if (ubicacion == null) {
      _emit(
        state.copyWith(
          error: 'No se encontró la ubicación del contenedor en el mapa',
        ),
      );
      return;
    }

    // ========================================
    // 2. VALIDAR SERIE
    // ========================================
    if (ubicacion.serie != movimiento.serieObjetivo) {
      _emit(
        state.copyWith(
          error: 'El número de serie no coincide con el movimiento',
        ),
      );
      return;
    }

    // ========================================
    // 3. DETECTAR BLOQUEADORES (LISTA COMPLETA)
    // ========================================
    final bloqueadores = state.mapa?.ubicaciones.where((u) {
          final mismoStack =
              u.area == ubicacion.area && u.espacio == ubicacion.espacio;

          final arriba = (u.nivel ?? 0) > (ubicacion.nivel ?? 0);

          final ocupado = u.estaOcupado;

          return mismoStack && arriba && ocupado;
        }).toList() ??
        [];

    // ========================================
    // 4. ORDENAR BLOQUEADORES (IMPORTANTE)
    // ========================================
    bloqueadores.sort(
      (a, b) => (a.nivel ?? 0).compareTo(b.nivel ?? 0),
    );

    // ========================================
    // 5. EMITIR ESTADO INICIAL
    // ========================================
    _emit(
      state.copyWith(
        tipoMovimiento: TipoMovimiento.pisoCamion,
        ordenActiva: movimiento,
        contenedorObjetivo: ubicacion,

        // 👇 IMPORTANTE: LISTA COMPLETA
        bloqueadores: bloqueadores,

        // 👇 NO decidir aquí el flujo
        paso: bloqueadores.isNotEmpty
            ? PasoMovimiento.seleccionarContenedorBloqueador
            : PasoMovimiento.confirmarSalida,
      ),
    );
  }

  /*
  =========================================================
  CONFIRMAR REACOMODO
  =========================================================
  */

  // Future<void> confirmarReacomodo() async {
  //   final origen = state.origen;

  //   final destino = state.destino;

  //   if (origen == null || destino == null) {
  //     return;
  //   }

  //   try {
  //     _emit(
  //       state.copyWith(
  //         isLoading: true,
  //       ),
  //     );

  //     final movimiento = MovimientoRegistro(
  //       token: '',
  //       weight: '',
  //       document_name: '',
  //       document: '',
  //       site_id: '',
  //       crane_movement_id: null,
  //       movement_type: 'REACOMODO_MANUAL',
  //       crane_operator_id: null,
  //       container_location_id: int.tryParse(origen.id) ?? 0,
  //       container_number: origen.serie,
  //       new_container_location_id: destino.id,
  //       status: 'CONFIRMADO',
  //       service_id: null,
  //     );

  //     await registrarMovimientoUseCase.execute(
  //       movimiento,
  //     );

  //     _emit(
  //       state.copyWith(
  //         isLoading: false,
  //         paso: PasoMovimiento.completado,
  //         mensaje: 'Reacomodo realizado',
  //       ),
  //     );

  //     await cargarMapa();
  //   } catch (e) {
  //     _emit(
  //       state.copyWith(
  //         isLoading: false,
  //         error: 'Error reacomodando: $e',
  //       ),
  //     );
  //   }
  // }

  /*
  =========================================================
  REGISTRAR PISO -> CAMION
  =========================================================
  */

  Future<bool> registrarMovimientoPisoCamion(
    UbicacionEntity origen,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('id') ?? 0;
      final siteId = prefs.getString('site_id') ?? '';
      /*
    ======================================
    LOADING
    ======================================
    */

      _emit(
        state.copyWith(
          isRegistrandoMovimiento: true,
        ),
      );

      /*
    ======================================
    VALIDAR ID UBICACION
    ======================================
    */

      if (origen.id == null) {
        throw Exception(
          'La ubicación no tiene ID',
        );
      }

      /*
    ======================================
    VALIDAR ORDEN ACTIVA
    ======================================
    */

      final movimientoOrden = state.ordenActiva;

      if (movimientoOrden == null) {
        throw Exception(
          'No existe orden activa',
        );
      }

      /*
    ======================================
    CREAR MOVIMIENTO
    ======================================
    */

      final movimiento = MovimientoRegistro(
        crane_movement_id: int.parse(
          movimientoOrden.id.toString(),
        ),
        movement_type: 'Piso-Camion',
        crane_operator_id: userId.toString(),

        /*
      ==================================
      UBICACION ACTUAL
      ==================================
      */

        container_location_id: int.parse(
          origen.id.toString(),
        ),

        /*
      ==================================
      NO HAY DESTINO
      ==================================
      */

        new_container_location_id: null,

        /*
      ==================================
      CONTENEDOR
      ==================================
      */

        container_number: origen.serie ?? '',

        /*
      ==================================
      EXTRA
      ==================================
      */

        status: null,
        token: prefs.getString('token') ?? '',
        weight: '',
        document_name: '',
        document: '',
        site_id: siteId,
      );

      /*
    ======================================
    GUARDAR MOVIMIENTO
    ======================================
    */

      final response = await registrarMovimientoUseCase(
        movimiento,
      );

      if (!response.success) {
        _emit(
          state.copyWith(
            isRegistrandoMovimiento: false,
            error: 'No se pudo registrar la salida',
          ),
        );

        return false;
      }

      /*
    ======================================
    LIBERAR UBICACION
    ======================================
    */

      origen.estado = 'Free';

      origen.serie = null;

      /*
    ======================================
    ACTUALIZAR UI
    ======================================
    */

      origenReacomodo = null;
      destinoReacomodo = null;

      _emit(
        state.copyWith(
          isRegistrandoMovimiento: false,
          mensaje: 'Salida realizada correctamente',
          paso: PasoMovimiento.completado,
          contenedorObjetivo: null,
          ordenActiva: null,
          origen: null,
          destino: null,
          tipoMovimiento: TipoMovimiento.ninguno,
          error: null,
        ),
      );
      /*
    ======================================
    RECARGAR MAPA
    ======================================
    */

      //2await cargarMapa();

      return true;
    } catch (e) {
      _emit(
        state.copyWith(
          isRegistrandoMovimiento: false,
          error: e.toString(),
        ),
      );

      return false;
    }
  }

  /*
  =========================================================
  RESET
  =========================================================
  */

  /*
  =========================================================
  COLOR ESPACIO
  =========================================================
  */

  Color getEspacioColor(
    List<UbicacionEntity> niveles,
  ) {
    final ocupados = niveles.where(
      (n) => estaOcupado(n),
    );

    if (ocupados.isEmpty) {
      return Colors.green.shade100;
    }

    if (ocupados.length == niveles.length) {
      return Colors.red.shade200;
    }

    return Colors.orange.shade100;
  }

  /*
  =========================================================
  ESTADO VISUAL ESPACIO
  =========================================================
  */

  EstadoVisualEspacio getEstadoVisualEspacio(
    String area,
    int espacio,
    List<UbicacionEntity> niveles,
  ) {
    final state = this.state;

    /*
  =========================================
  OBJETIVO
  =========================================
  */

    if (state.contenedorObjetivo != null) {
      final objetivo = state.contenedorObjetivo!;

      if (objetivo.area == area && objetivo.espacio == espacio) {
        return EstadoVisualEspacio.objetivo;
      }
    }

    /*
  =========================================
  BLOQUEADOR
  =========================================
  */

    if (state.bloqueador != null) {
      final bloqueador = state.bloqueador!;

      if (bloqueador.area == area && bloqueador.espacio == espacio) {
        return EstadoVisualEspacio.bloqueador;
      }
    }

    /*
  =========================================
  ORIGEN MANUAL
  =========================================
  */

    if (state.origen != null &&
        state.tipoMovimiento == TipoMovimiento.reacomodoManual) {
      final origen = state.origen!;

      if (origen.area == area && origen.espacio == espacio) {
        return EstadoVisualEspacio.origenManual;
      }
    }

    /*
  =========================================
  DESTINO MANUAL
  =========================================
  */

    if (state.destino != null &&
        state.tipoMovimiento == TipoMovimiento.reacomodoManual) {
      final destino = state.destino!;

      if (destino.area == area && destino.espacio == espacio) {
        return EstadoVisualEspacio.destinoManual;
      }
    }

    return EstadoVisualEspacio.normal;
  }

  /*
=========================================================
OBTENER NIVELES DEL ESPACIO
=========================================================
*/

  List<UbicacionEntity> obtenerNivelesPorEspacio(
    String area,
    int espacio,
  ) {
    return state.mapa?.ubicaciones.where((u) {
          return u.area == area && u.espacio == espacio;
        }).toList() ??
        [];
  }

  /*
=========================================================
FUNCIONES PISO - CAMION, CAMION - PISO Y REACOMODO MANUAL     
=========================================================
*/
// =========================================

  // ===============================
  // INICIAR PISO -> CAMIÓN
  // ===============================
  void iniciarMovimientoPisoCamion(MovimientoEntity orden) {
    _emit(_state.copyWith(
      ordenActiva: orden,
      paso: PasoMovimiento.validarOrden,
      origen: null,
      destino: null,
    ));
  }

  // ===============================
  // VALIDAR BLOQUEADORES
  // ===============================
  // List<UbicacionEntity> validarBloqueadores(
  //   List<UbicacionEntity> niveles,
  //   UbicacionEntity objetivo,
  // ) {
  //   final nivelObjetivo = int.tryParse(objetivo.nivel.toString());

  //   if (nivelObjetivo == null) return [];

  //   return niveles.where((n) {
  //     final nivelActual = int.tryParse(n.nivel.toString());

  //     if (nivelActual == null) return false;

  //     final ocupado = n.estado.toLowerCase() == 'used';

  //     return ocupado && nivelActual > nivelObjetivo;
  //   }).toList()
  //     ..sort((a, b) {
  //       final na = int.tryParse(b.nivel.toString()) ?? 0;
  //       final nb = int.tryParse(a.nivel.toString()) ?? 0;
  //       return na.compareTo(nb);
  //     });
  // }

  // ===============================
  // ACTIVAR REACOMODO (ORIGEN)
  // ===============================
  void activarReacomodoOrigen(UbicacionEntity origen) {
    _emit(_state.copyWith(
      paso: PasoMovimiento.seleccionarDestinoReacomodo,
      origen: origen,
    ));
  }

  // ===============================
  // SELECCION DESTINO PISO->CAMIÓN
  // ===============================
  void seleccionarDestinoSalida(UbicacionEntity destino) {
    _emit(_state.copyWith(
      destino: destino,
      paso: PasoMovimiento.confirmarSalida,
    ));
  }

  // ===============================
  // RESET
  // ===============================
  void reset() {
    _emit(MapaMovimientoState.initial());
    origenManual = null;
    destinoManual = null;
  }

  // ==============================
  // REACOMODO - ORIGEN
  // ==============================

  seleccionarOrigenReacomodo(UbicacionEntity origen) {
    origenReacomodo = origen;

    _state = _state.copyWith(
      paso: PasoMovimiento.seleccionarDestinoReacomodo,
    );

    notifyListeners();
  }

  // ==============================
  // REACOMODO - DESTINO
  // ==============================

  Future<void> seleccionarDestinoReacomodo(
    UbicacionEntity destino,
    List<UbicacionEntity> niveles,
  ) async {
    // VALIDACIÓN 1: no mismo espacio
    if (origenReacomodo == null) return;

    if (origenReacomodo!.area == destino.area &&
        origenReacomodo!.espacio == destino.espacio) {
      _error("No puedes mover dentro del mismo espacio");
      return;
    }

    // VALIDACIÓN 2: destino libre
    if (destino.estado != 'Free') {
      _error("Destino ocupado");
      return;
    }

    final esReacomodoManual =
        state.tipoMovimiento == TipoMovimiento.reacomodoManual;

    if (esReacomodoManual && _hayHuecosInvalidos(niveles)) {
      _error("Estructura inválida de niveles");
      return;
    }

    destinoReacomodo = destino;

    _state = _state.copyWith(
      paso: PasoMovimiento.confirmarReacomodo,
    );

    notifyListeners();
  }

  // ==============================
  // EJECUTAR REACOMODO
  // ==============================

  Future<bool> ejecutarReacomodo() async {
    if (origenReacomodo == null || destinoReacomodo == null) {
      return false;
    }

    // ❌ VALIDACIÓN CRÍTICA
    if (origenReacomodo!.id == destinoReacomodo!.id) {
      return false;
    }

    // ❌ NO MISMO ESPACIO
    if (origenReacomodo!.espacio == destinoReacomodo!.espacio &&
        origenReacomodo!.area == destinoReacomodo!.area) {
      return false;
    }

    notifyListeners();
    return true;
    // return exito;
  }

  // ==============================
  // PISO → CAMIÓN FINAL
  // ==============================

  Future<bool> confirmarSalidaPisoCamion() async {
    if (objetivoFinal == null) return false;

    try {
      _reset();

      return true;
    } catch (_) {
      _error("Error al confirmar salida");
      return false;
    }
  }

  // ==============================
  // VALIDACIÓN BLOQUEADORES
  // ==============================

  List<UbicacionEntity> validarBloqueadores(
    List<UbicacionEntity> niveles,
    UbicacionEntity objetivo,
  ) {
    final nivelObjetivo = int.tryParse(objetivo.nivel.toString());
    if (nivelObjetivo == null) return [];

    return niveles.where((n) {
      final nivelActual = int.tryParse(n.nivel.toString());
      if (nivelActual == null) return false;

      final ocupado = n.estado == 'Used';

      return ocupado && nivelActual > nivelObjetivo;
    }).toList()
      ..sort((a, b) => int.parse(b.nivel.toString())
          .compareTo(int.parse(a.nivel.toString())));
  }

  // ==============================
  // VALIDACIÓN STACK (HUECOS)
  // ==============================

  bool _hayHuecosInvalidos(List<UbicacionEntity> niveles) {
    final ordenados = [...niveles]..sort((a, b) => a.nivel.compareTo(b.nivel));

    bool encontradoOcupado = false;

    for (final n in ordenados) {
      final ocupado = n.estado == 'Used';

      if (!ocupado) {
        if (encontradoOcupado) return true;
      } else {
        encontradoOcupado = true;
      }
    }

    return false;
  }

  // ==============================
  // RESET
  // ==============================

  void _reset() {
    origenReacomodo = null;
    destinoReacomodo = null;
    objetivoFinal = null;
    bloqueadores = [];

    _state = _state.copyWith(
      paso: PasoMovimiento.completado,
    );

    notifyListeners();
  }

  // ==============================
  // ERROR HANDLER
  // ==============================

  void _error(String msg) {
    _state = _state.copyWith(
      paso: PasoMovimiento.error,
    );

    notifyListeners();
  }

  bool puedeColocar(List<UbicacionEntity> niveles, UbicacionEntity destino) {
    final nivel = int.tryParse(destino.nivel.toString()) ?? 0;

    for (int i = nivel - 1; i >= 1; i--) {
      final inferior = niveles.where(
          (n) => int.tryParse(n.nivel.toString()) == i && n.estado == 'Used');

      if (inferior.isNotEmpty) {
        return false;
      }
    }

    return true;
  }

  // ======================================
// CONFIRMAR REACOMODO
// ======================================
  Future<bool> confirmarReacomodo() async {
    try {
      if (origenReacomodo == null || destinoReacomodo == null) {
        debugPrint('origen reacomodo ${origenReacomodo} ');
        debugPrint('destino reacomodo ${destinoReacomodo} ');

        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('id') ?? 0;
      final siteId = prefs.getString('site_id') ?? '';

      final origen = origenReacomodo!;
      final destino = destinoReacomodo!;

      if (origen.id == null || destino.id == null) {
        debugPrint('AQUI ESTAS EN ORIGEN Y DESTINO NULL');

        throw Exception(
          'No se encontraron IDs de ubicaciones',
        );
      }

      final movimiento = MovimientoRegistro(
        crane_movement_id: null,
        movement_type: 'Reacomodo',
        crane_operator_id: userId.toString(),
        container_location_id: int.parse(
          origen.id.toString(),
        ),
        new_container_location_id: destino.id.toString(),
        container_number: origen.serie ?? '',
        status: null,
        token: prefs.getString('token') ?? '',
        weight: '',
        document_name: '',
        document: '',
        site_id: siteId,
      );

      debugPrint('ARRAY MOVIMIENTO :  ${movimiento.toString()}');
      final response = await registrarMovimientoUseCase(
        movimiento,
      );

      /*
    ======================================
    ACTUALIZAR MAPA LOCAL
    ======================================
    */

      destino.estado = 'Used';
      destino.serie = origen.serie;

      origen.estado = 'Free';
      origen.serie = null;

      /*
    ======================================
    LIMPIAR FLUJO
    ======================================
    */

      origenReacomodo = null;
      destinoReacomodo = null;

      _emit(
        state.copyWith(
          error: null,
        ),
      );

      return true;
    } catch (e, stack) {
      _emit(
        state.copyWith(
          error: e.toString(),
        ),
      );

      debugPrint(
        'ERROR REACOMODO: $e',
      );

      debugPrint(
        stack.toString(),
      );

      return false;
    }
  }

  puedeColocarContenedor({required UbicacionEntity destino}) {
    return true;
  }

  /*
  =============================================
  MOVIMIENTO CAMION - PISO 
  */

  UbicacionEntity? destinoIngreso;

  Future<void> iniciarCamionPiso(
    MovimientoEntity movimiento,
  ) async {
    _emit(
      state.copyWith(
        tipoMovimiento: TipoMovimiento.camionPiso,
        ordenActiva: movimiento,
        paso: PasoMovimiento.seleccionarDestinoIngreso,
        error: null,
        mensaje: 'Selecciona una ubicacion para dejar el contenedor',
      ),
    );
  }

  bool validarDestinoIngreso(
    List<UbicacionEntity> niveles,
    UbicacionEntity destino,
  ) {
    if (!destino.estaLibre) {
      return false;
    }

    final nivelDestino = int.tryParse(destino.nivel.toString()) ?? 0;

    /*
  =====================================
  NIVEL 1 SIEMPRE VÁLIDO
  =====================================
  */

    if (nivelDestino == 1) {
      return true;
    }

    /*
  =====================================
  NIVEL INFERIOR
  =====================================
  */

    final nivelInferior = niveles.firstWhere(
      (n) => (int.tryParse(n.nivel.toString()) ?? 0) == nivelDestino - 1,
    );

    /*
  =====================================
  DEBE ESTAR OCUPADO
  =====================================
  */

    return nivelInferior.estaOcupado;
  }

  void seleccionarDestinoIngreso(
    UbicacionEntity destino,
  ) {
    destinoIngreso = destino;

    _emit(
      state.copyWith(
        paso: PasoMovimiento.confirmarIngreso,
      ),
    );
  }

  Future<bool> registrarMovimientoCamionPiso(
    UbicacionEntity destino,
  ) async {
    try {
      _emit(
        state.copyWith(
          isRegistrandoMovimiento: true,
          error: null,
        ),
      );

      /*
    =====================================
    VALIDAR ORDEN
    =====================================
    */

      final m = state.ordenActiva;

      if (m == null) {
        throw Exception('No existe orden activa');
      }

      /*
    =====================================
    VALIDAR DESTINO LIBRE
    =====================================
    */

      if (!destino.estaLibre) {
        throw Exception('La ubicación ya está ocupada');
      }

      /*
    =====================================
    VALIDAR SOPORTE
    =====================================
    */

      final nivelesMismoEspacio = state.mapa!.ubicaciones.where((u) {
        return u.area == destino.area && u.espacio == destino.espacio;
      }).toList();

      final valido = validarDestinoIngreso(
        nivelesMismoEspacio,
        destino,
      );

      if (!valido) {
        throw Exception(
          'El contenedor quedaría flotando',
        );
      }

      /*
    =====================================
    PREFS
    =====================================
    */

      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('id') ?? 0;

      final siteId = prefs.getString('site_id') ?? '';

      /*
    =====================================
    CREAR MOVIMIENTO
    =====================================
    */

      final movimiento = MovimientoRegistro(
        crane_movement_id: int.tryParse(m.id.toString()),
        movement_type: 'Camion-Piso',
        crane_operator_id: userId.toString(),

        /*
      =====================================
      DESTINO
      =====================================
      */

        container_location_id: int.tryParse(destino.id.toString()),
        new_container_location_id: null,

        /*
      =====================================
      CONTENEDOR
      =====================================
      */

        container_number: m.serieObjetivo,

        /*
      =====================================
      EXTRA
      =====================================
      */

        status: null,
        token: prefs.getString('token') ?? '',
        weight: '',
        document_name: '',
        document: '',
        site_id: siteId,
      );

      /*
=====================================
API
=====================================
*/

      final response = await registrarMovimientoUseCase(
        movimiento,
      );

/*
=====================================
ERROR API
=====================================
*/

      if (!response.success) {
        _emit(
          state.copyWith(
            isLoading: false,
            error:
                'Ha ocurrido un error inesperado, no se pudo registrar el movimiento Camión - Piso',
          ),
        );

        return false;
      }

      destino.estado = 'Used';

      destino.serie = m.serieObjetivo;

      _emit(
        state.copyWith(
          isRegistrandoMovimiento: false,
          ordenActiva: null,
          destino: null,
          contenedorObjetivo: null,
          tipoMovimiento: TipoMovimiento.ninguno,
          paso: PasoMovimiento.completado,
          mensaje: 'Ingreso realizado correctamente',
          error: null,
        ),
      );
      return true;
    } catch (e) {
      _emit(
        state.copyWith(
          isRegistrandoMovimiento: false,
          error: e.toString(),
        ),
      );

      return false;
    }
  }
/*
======================================================
REACOMODO MANUAL 
======================================================
*/

  void iniciarReacomodoManual() {
    origenManual = null;
    destinoManual = null;

    _emit(
      state.copyWith(
        tipoMovimiento: TipoMovimiento.reacomodoManual,
        paso: PasoMovimiento.seleccionarOrigenManual,
        mensaje: 'Seleccione contenedor origen',
        error: null,
      ),
    );
  }

  // ======================================
// SELECCIONAR ORIGEN MANUAL
// ======================================

  void seleccionarOrigenManual(
    UbicacionEntity origen,
  ) {
    origenManual = origen;

    _emit(
      state.copyWith(
        paso: PasoMovimiento.seleccionarDestinoManual,
        mensaje: 'Seleccione destino',
        error: null,
      ),
    );
  }

  // ======================================
// VALIDAR DESTINO REACOMODO
// TRUE = ERROR
// FALSE = VALIDO
// ======================================
  bool validarDestinoReacomodo(
    List<UbicacionEntity> niveles,
    UbicacionEntity origen,
    UbicacionEntity destino,
  ) {
    /*
  =========================================
  NO MOVER AL MISMO ESPACIO
  =========================================
  */

    if (origen.area == destino.area && origen.espacio == destino.espacio) {
      return false;
    }

    /*
  =========================================
  DESTINO OCUPADO
  =========================================
  */

    final destinoLibre = destino.estado.toString().toLowerCase() == 'free';

    if (!destinoLibre) {
      return false;
    }

    /*
  =========================================
  NIVEL DESTINO
  =========================================
  */

    final nivelDestino = int.tryParse(destino.nivel.toString()) ?? 0;

    /*
  =========================================
  NIVEL 1 SIEMPRE VALIDO
  =========================================
  */

    if (nivelDestino == 1) {
      return true;
    }

    /*
  =========================================
  VALIDAR SOPORTE INFERIOR
  =========================================
  */

    for (int nivelInferior = 1; nivelInferior < nivelDestino; nivelInferior++) {
      /*
    =========================================
    BUSCAR NIVEL INFERIOR
    =========================================
    */

      final inferiores = niveles.where(
        (n) =>
            n.area == destino.area &&
            n.espacio == destino.espacio &&
            (int.tryParse(
                      n.nivel.toString(),
                    ) ??
                    0) ==
                nivelInferior,
      );

      /*
    =========================================
    SI NO EXISTE EL NIVEL
    =========================================
    */

      if (inferiores.isEmpty) {
        return false;
      }

      final inferior = inferiores.first;

      /*
    =========================================
    VALIDAR OCUPADO
    =========================================
    */

      final inferiorOcupado =
          inferior.estado.toString().toLowerCase() == 'used';

      /*
    =========================================
    SI EL INFERIOR ESTA LIBRE
    =========================================
    */

      if (!inferiorOcupado) {
        return false;
      }
    }

    /*
  =========================================
  DESTINO VALIDO
  =========================================
  */

    return true;
  }
  // ======================================
// VALIDAR CONTENEDORES ARRIBA
// ======================================

  bool tieneContenedoresArriba(
    List<UbicacionEntity> niveles,
    UbicacionEntity objetivo,
  ) {
    final nivelObjetivo = int.tryParse(
          objetivo.nivel.toString(),
        ) ??
        0;

    return niveles.any((n) {
      final nivelActual = int.tryParse(
            n.nivel.toString(),
          ) ??
          0;

      return n.estaOcupado && nivelActual > nivelObjetivo;
    });
  }

  // ======================================
// CONFIRMAR REACOMODO MANUAL
// ======================================
  Future<bool> confirmarReacomodoManual() async {
    try {
      /*
    =====================================
    VALIDACIONES
    =====================================
    */

      if (origenManual == null || destinoManual == null) {
        return false;
      }

      /*
    =====================================
    LOADING
    =====================================
    */

      _emit(
        state.copyWith(
          isRegistrandoMovimiento: true,
          error: null,
        ),
      );

      /*
    =====================================
    CREAR MOVIMIENTO
    =====================================
    */
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('id') ?? 0;
      final siteId = prefs.getString('site_id') ?? '';

      final movimiento = MovimientoRegistro(
        crane_movement_id: null,
        movement_type: 'Reacomodo',
        crane_operator_id: userId.toString(),

        /*
      =====================================
      ORIGEN
      =====================================
      */

        container_location_id: int.parse(
          origenManual!.id.toString(),
        ),

        /*
      =====================================
      DESTINO
      =====================================
      */

        new_container_location_id: destinoManual!.id.toString(),

        /*
      =====================================
      CONTENEDOR
      =====================================
      */

        container_number: origenManual!.serie ?? '',
        status: null,
        token: prefs.getString('token') ?? '',
        weight: '',
        document_name: '',
        document: '',
        site_id: siteId ?? '',
      );

      /*
    =====================================
    API
    =====================================
    */

      final response = await registrarMovimientoUseCase(
        movimiento,
      );

      if (!response.success) {
        _emit(
          state.copyWith(
            isRegistrandoMovimiento: false,
            error:
                'Ha ocurrido un error inesperado, no se puedo registrar el reacomodo.',
          ),
        );

        return false;
      }
      /*
    =====================================
    ACTUALIZAR MAPA LOCAL
    =====================================
    */

      destinoManual!.estado = 'Used';

      destinoManual!.serie = origenManual!.serie;

      origenManual!.estado = 'Free';

      origenManual!.serie = null;

      /*
    =====================================
    LIMPIAR FLUJO
    =====================================
    */

      origenManual = null;

      destinoManual = null;

      /*
    =====================================
    COMPLETADO
    =====================================
    */

      _emit(
        state.copyWith(
          isRegistrandoMovimiento: false,
          paso: PasoMovimiento.seleccionarOrigenManual,
          mensaje: 'El reacomodo se ha realizado correctamente',
          tipoMovimiento: null,
        ),
      );
      return true;
    } catch (e) {
      _emit(
        state.copyWith(
          isRegistrandoMovimiento: false,
          error: e.toString(),
        ),
      );

      return false;
    }
  }

  void seleccionarDestinoManual(
    UbicacionEntity destino,
    List<UbicacionEntity> niveles,
  ) {
    final origen = origenManual;

    if (origen == null) {
      return;
    }

    final valido = validarDestinoReacomodo(
      niveles,
      origen,
      destino,
    );

    if (!valido) {
      _emit(
        state.copyWith(
          error: 'Destino inválido',
        ),
      );

      return;
    }

    destinoManual = destino;

    _emit(
      state.copyWith(
        mensaje: 'Confirmar reacomodo',
        error: null,
      ),
    );
  }

  /*
  =======================================
  SETEAR VARIABLE REACOMODO AL CANCELAR 
  */

  void setPasoMovimiento(
    PasoMovimiento paso,
  ) {
    _emit(
      state.copyWith(
        paso: paso,
      ),
    );
  }

  void cancelarOrigenManual() {
    origenManual = null;

    destinoManual = null;

    _emit(
      state.copyWith(
        paso: PasoMovimiento.seleccionarOrigenManual,
      ),
    );
  }
}
