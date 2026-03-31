import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:segadi/core/theme/app_colors.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/domain/usecases/get_mapa_ubicaciones_usecase.dart';
import 'package:segadi/features/ubications/domain/usecases/registrar_movimiento_usecase.dart';
import 'package:segadi/utils/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TipoMovimiento { pisoCamion, camionPiso, reacomodo, ninguno }

enum FaseReacomodo { ninguno, origen, destino, none }

class ReacomodoTemporal {
  UbicacionEntity? origen;
  UbicacionEntity? destino;
  String? motivo; // Ej: "Desbloqueo de Orden #64"
}

class UbicacionesMapaViewModel extends ChangeNotifier {
  final RegistrarMovimientoUseCase reacomodoUseCase;
  final GetMapaUbicacionesUseCase getMapaUbicacionesUseCase;

  UbicacionEntity? get containerParaMover => _containerParaMover;
  UbicacionEntity? _containerParaMover;

  TipoMovimiento? movimientoActual;
  dynamic movimientoActivo;
  Map<String, dynamic>? datosMovimiento;
  Movimiento? movimientoEnProceso;

  //NUEVO bloque
  UbicacionesMapEntity? ubicacionesMapEntity;
  bool isLoading = false;
  String? errorMessage;
  String? mensajeValidacion;

  // Control de Movimiento
  UbicacionEntity? ubicacionOrigen;
  UbicacionEntity? ubicacionDestino;
  FaseReacomodo _faseReacomodo = FaseReacomodo.ninguno;

  // Getters para la UI
  FaseReacomodo get faseReacomodo => _faseReacomodo;
  bool get enModoReacomodo => _faseReacomodo != FaseReacomodo.ninguno;
  String get serieEnGancho => _containerParaMover?.serie ?? '';

  UbicacionesMapaViewModel({
    required this.getMapaUbicacionesUseCase,
    required this.reacomodoUseCase,
  });

  ///////////////////FUNCION PARA MOSTRAR BOTON REACOMODO EN EL MAPA SOLO CUANDO VENGA DE LA LISTA DE MOVIMIENTOS //////////
  ///

  bool showButtonReacomodo(UbicacionesMapaViewModel vm) {
    if (vm.movimientoActual == TipoMovimiento.reacomodo) {
      return false;
    }

    if (vm.movimientoActual == TipoMovimiento.camionPiso) {
      return false;
    }

    if (vm.movimientoActual == TipoMovimiento.pisoCamion) {
      return false;
    }

    return true;
  }

  //// FUNCION AUXILIAR PARA RESETEAR LOS VALORES /////

  void limpiarEstado() {
    // 1. Limpiamos las referencias de ubicación
    ubicacionOrigen = null;
    ubicacionDestino = null;

    // 2. Limpiamos el contenedor que estaba "en el gancho"
    _containerParaMover = null;

    // 3. Reset de la fase de reacomodo
    _faseReacomodo = FaseReacomodo.ninguno;

    // 4. Limpiamos mensajes de error o validación previos
    mensajeValidacion = null;
    errorMessage = null;

    // 5. Notificamos a la UI para que refresque (ej. quitar bordes azules)
    notifyListeners();
  }

  /// FUNCION PARA CAMBIAR LA FASE QUE ES EL TIPO DE MOVIMIENTO //////////

  //FUNCION PARA EXTRAER EL CONTENEDOR DEL //PRIMERA FUNCION AUXILIAR PARA EL MOVIMIENTO DE CONTENEDORES

  bool puedeExtraer(
      UbicacionEntity nivelTocado, List<UbicacionEntity> nivelesDelEspacio) {
    int nTocado = int.tryParse(nivelTocado.nivel) ?? 0;

    // Un contenedor está bloqueado si existe algún nivel ARRIBA (> nTocado)
    // que tenga estatus 'Used'.
    bool tieneAlgoEncima = nivelesDelEspacio.any((n) =>
        (int.tryParse(n.nivel) ?? 0) > nTocado &&
        n.estatus.toLowerCase() == 'used');

    return !tieneAlgoEncima;
  }

  //////////////////FUNCION PARA VALIDAR CUAL CONTENEDOR MOVER ////////////////////////
  ///

  String get serieActiva {
    // PRIORIDAD 1: Si hay algo que el usuario tocó en el mapa (Piso-Camión o Reacomodo)
    if (_containerParaMover != null && _containerParaMover!.serie != null) {
      return _containerParaMover!.serie!;
    }

    // PRIORIDAD 2: Si venimos del listado y la orden dice qué contenedor mover (A o B)
    if (movimientoEnProceso != null) {
      final mov = movimientoEnProceso!;

      // Si la orden especifica el B, intentamos usar el B
      if (mov.contenedorAMover.contains("Contenedor B") &&
          mov.contenedorB.isNotEmpty) {
        return mov.contenedorB;
      }

      // Por defecto o si es el A, usamos la serie A
      return mov.contenedorA.isNotEmpty ? mov.contenedorA : mov.serieReal;
    }

    return "Sin Serie";
  }

  //FUNCION PARA DEPOSITAR EL CONTENEDOR EN PISO // SEGUNADA FUNCION AUXILIAR PARA EL MOVIMIENTO DE CONTENEDORES

  // REGLA: ¿Puedo poner un contenedor aquí?
  bool puedeDepositar(
      UbicacionEntity nivelTocado, List<UbicacionEntity> nivelesDelEspacio) {
    if (nivelTocado.estatus.toLowerCase() != 'free') return false;

    int nDeseado = int.tryParse(nivelTocado.nivel) ?? 0;
    if (nDeseado == 1) return true; // El piso siempre recibe

    // Para niveles 2 o 3, el nivel de justo abajo (nDeseado - 1) DEBE estar ocupado
    return nivelesDelEspacio.any((n) =>
        (int.tryParse(n.nivel) ?? 0) == (nDeseado - 1) &&
        n.estatus.toLowerCase() == 'used');
  }

  void cargarOrden(dynamic orden) {
    movimientoActivo = orden;

    notifyListeners();
  }

  ///////FUNCION PARA ENVIAR DATOS AL SERVIDOR DEPENDIENDO EL TIPO DE MOVIMIENTO ///////////////
  Future<void> _registrarTipoDeMovimiento({
    required String tipo, // 'Reacomodo', 'Piso-Camion', 'Camion-Piso'
    String? origenId,
    String? destinoId,
    int? movementId,
  }) async {
    final user = UserSession();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // --- PASO PREVIO: Lógica Inteligente de IDs ---
    int? finalOrigen;
    String? finalDestino;

    if (tipo == 'Camion-Piso') {
      // 🚩 CORRECCIÓN CRÍTICA:
      // Si el servidor rechaza el null en origen, mandamos el ID de la celda aquí.
      finalOrigen = int.tryParse(destinoId ?? '');
      finalDestino = null; // O puedes repetir destinoId si el API pide ambos
    } else if (tipo == 'Piso-Camion') {
      finalOrigen = int.tryParse(origenId ?? '');
      finalDestino = null;
    } else {
      // Reacomodo
      finalOrigen = int.tryParse(origenId ?? '');
      finalDestino = destinoId;
    }
    final movimiento = MovimientoRegistro(
      crane_movement_id: movementId,
      movement_type: tipo,
      crane_operator_id: user.id.toString(),

      // Ahora enviamos el ID donde el servidor lo espera
      container_location_id: finalOrigen,
      new_container_location_id: finalDestino,

      container_number: serieActiva,
      token: token,
      site_id: user.siteId ?? '',
      weight: '',
      document_name: '',
      document: '',
      status: null,
    );

    print(movimiento.toJson());

    try {
      await reacomodoUseCase.execute(movimiento);

      // Si todo salió bien, refrescamos el mapa
      await cargarMapa();
    } catch (e) {
      errorMessage = "Error al registrar $tipo: $e";
      notifyListeners();
      rethrow; // Lanzamos el error para que la función que llamó a esta sepa que falló
    }
  }

  ///FUNCION PARA REGISTRAR EL REACOMODO ///////////////////

  void finalizarReacomodo(UbicacionEntity destino) async {
    if (ubicacionOrigen == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await _registrarTipoDeMovimiento(
        tipo: 'Reacomodo',
        origenId: ubicacionOrigen!.id,
        destinoId: destino.id,
      );

      limpiarEstado();
    } catch (e) {
      errorMessage = "No se pudo completar el reacomodo";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

////// FUNCION PARA REGISTRAR EL MOVIMIENTO PISO CAMION /////////////
  ///

  Future<bool> registrarMovimientoPisoCamion(UbicacionEntity ubi) async {
    // 1. Validamos que tengamos el ID del movimiento necesario
    final idMovimientoProceso = movimientoEnProceso?.id;

    if (idMovimientoProceso == null) {
      errorMessage =
          "Error: No hay un ID de movimiento activo para este despacho.";
      notifyListeners();
      return false;
    }

    // 2. Iniciamos estado de carga para bloquear la UI (importante en ZTE para evitar doble clic)
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 3. Llamamos a la función centralizada que ya creamos
      await _registrarTipoDeMovimiento(
        tipo: 'Piso-Camion',
        origenId: ubi.id,
        movementId: idMovimientoProceso, // Aseguramos que sea String
      );

      // 4. Si el servidor respondió OK, limpiamos todo para el siguiente contenedor
      limpiarEstado();

      // Opcional: Puedes guardar un mensaje de éxito temporal
      mensajeValidacion = "Despacho de serie ${ubi.serie} exitoso";
      return true;
    } catch (e) {
      // 5. Manejo de errores
      errorMessage = "Error al despachar: $e";
      return false;
    } finally {
      // 6. Pase lo que pase, quitamos el loader
      isLoading = false;
      notifyListeners();
    }
  }

  //////////////////// FUNCION PARA REGISTRAR MOVIMIENTO CAMION - PISO ///////////
  ///

  Future<bool> registrarMovimientoCamionPiso(UbicacionEntity ubi) async {
    final idMovimientoProceso = movimientoEnProceso?.id;
    final numeroSerie = serieActiva;

    if (idMovimientoProceso == null || numeroSerie == "Sin Serie") {
      errorMessage = "Error: Datos de la orden incompletos.";
      notifyListeners();
      return false;
    }

    debugPrint(
        'se insertara movimiento tipo PISO - CAMION, destino id: ${ubi.id} movimiento id: ${idMovimientoProceso} numero de serie: ${numeroSerie}');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _registrarTipoDeMovimiento(
        tipo: 'Camion-Piso',
        destinoId: ubi.id,
        movementId: idMovimientoProceso,
      );

      // GUARDAMOS LOS DATOS ANTES DE LIMPIAR (Para el mensaje de éxito)
      // Usamos el operador ?? para evitar el Null Check Error
      //final serieFinalizada = ubi.serie ?? 'Desconocida';

      // 4. Limpiamos estado DESPUÉS de asegurar los datos
      limpiarEstado();

      //mensajeValidacion = "Entrada de serie $serieFinalizada exitosa";

      // IMPORTANTE: Quitamos el loader aquí antes del return true
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error en camion - piso: $e');
      errorMessage = "Error al despachar: $e";
      isLoading = false; // Quitamos loader en caso de error
      notifyListeners();
      return false;
    }
    // ELIMINAMOS EL FINALLY CON RETURN PARA EVITAR SOBREESCRITURA
  }

  ///////////////////////FUNCION PARA PINTAR LOS ESPACIOS /////////////////////////

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

  /////////////////FUNCION PARA CENTRALIZA, FILTRAR Y EVITAR EL ERROR EN EL ORDENAMIENTO DE LOS ESPACIOS //////////////
  ///

  List<UbicacionEntity> getNivelesDelEspacio(
      String areaNombre, String numEspacio) {
    if (ubicacionesMapEntity == null) return [];

    // Filtramos que coincida el área y el número de espacio
    final lista = ubicacionesMapEntity!.ubicaciones
        .where((u) => u.area == areaNombre && u.espacio == numEspacio)
        .toList();

    // Ordenamos por nivel (del 1 al 3) usando matemáticas, no Strings
    lista.sort((a, b) =>
        (int.tryParse(a.nivel) ?? 0).compareTo(int.tryParse(b.nivel) ?? 0));

    return lista;
  }

  ///// FUNCION PARA OBTENER LOS NUMEROS DE ESPACIOS, ESTA LIGADA LA FUNCION _buildAreaColumn //////////
  ///
  List<String> getEspaciosNumericos(String areaNombre) {
    if (ubicacionesMapEntity == null) return [];

    return ubicacionesMapEntity!.ubicaciones
        .where((u) => u.area == areaNombre)
        .map((u) => u.espacio)
        .where((e) => int.tryParse(e) != null) // Limpieza de datos basura
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }

  //// FUNCION PARA GESTIONAR EL ESPACIO ////////////
  ///

  //////////FUNCION PARA CARGAR EL MAPA ///////////////////////
  ///

  Future<void> cargarMapa() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resultado = await getMapaUbicacionesUseCase.execute();

      if (resultado != null) {
        ubicacionesMapEntity = resultado;
      } else {
        errorMessage = "El servidor devolvió un mapa vacío.";
      }
    } catch (e) {
      errorMessage = "Error al procesar datos del mapa: $e";
    } finally {
      isLoading = false;
      _faseReacomodo = FaseReacomodo.ninguno;
      _containerParaMover = null;
      notifyListeners();
    }
  }

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

    notifyListeners();
  }

  void cancelarReacomodo({bool resetearTipoMovimiento = false}) {
    // 1. Siempre regresamos a la fase inicial para poder elegir un nuevo origen
    _faseReacomodo = FaseReacomodo.ninguno;

    // 2. Limpiamos los contenedores y ubicaciones "en el gancho"
    _containerParaMover = null;
    ubicacionOrigen = null;
    ubicacionDestino = null;

    // 3. Lógica de resetear el tipo de movimiento
    if (resetearTipoMovimiento) {
      // Solo lo ponemos en ninguno si realmente queremos salir del modo mapa/reacomodo
      movimientoActual = TipoMovimiento.ninguno;
    }

    debugPrint(
        'Estado tras cancelar: Fase: $_faseReacomodo | Mov: $movimientoActual');
    notifyListeners();
  }

  void prepararReacomodoManual() {
    movimientoActual = TipoMovimiento.reacomodo;
    _faseReacomodo = FaseReacomodo.origen;
    ubicacionOrigen = null;
    notifyListeners();
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

//recibe el tipo de movimiento y lo filtra
  void prepararMovimiento([Movimiento? mov]) {
    // 1. Limpiamos estados previos
    ubicacionDestino = null;
    ubicacionOrigen = null;
    mensajeValidacion = null;

    if (mov != null) {
      // ✅ Ahora es seguro imprimir porque ya comprobamos que NO es nulo
      print(
          'Nuevo movimiento: ${mov.tipoMovimiento} en ${mov.area}-${mov.espacio}');

      // CASO: VIENE DE LA LISTA (Piso-Camion o Camion-Piso)
      movimientoEnProceso = mov;
      final tipoStr = mov.tipoMovimiento.toLowerCase();

      if (tipoStr.contains('piso-camion')) {
        movimientoActual = TipoMovimiento.pisoCamion;
      } else if (tipoStr.contains('camion-piso')) {
        movimientoActual = TipoMovimiento.camionPiso;
      }

      // Búsqueda automática de ubicación en el mapa
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
      // ✅ CASO: REACOMODO MANUAL (Sin movimiento previo)
      print('Iniciando modo Reacomodo Manual');
      movimientoEnProceso = null;
      movimientoActual = TipoMovimiento.reacomodo;
    }

    notifyListeners();
  }

  void intentarSeleccionarUbicacion(
      UbicacionEntity ubi, List<UbicacionEntity> nivelesDelEspacio) {
    mensajeValidacion = null;

    switch (movimientoActual) {
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

  void seleccionarOrigen(UbicacionEntity ubi) {
    // 1. Validamos que la ubicación NO esté libre (debe haber algo que mover)
    if (ubi.estatus.toLowerCase() != 'free') {
      ubicacionOrigen = ubi;

      // 2. Limpiamos el destino anterior por seguridad
      // (si el operador cambia de opinión sobre qué contenedor mover)
      ubicacionDestino = null;
      errorMessage = null; // Limpiamos errores previos

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
}
