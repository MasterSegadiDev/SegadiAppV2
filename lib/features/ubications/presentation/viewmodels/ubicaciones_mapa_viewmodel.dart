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
    required String tipo,
    String? origenId,
    String? destinoId,
    int? movementId,
  }) async {
    final user = UserSession();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final movimiento = MovimientoRegistro(
      crane_movement_id:
          movementId, // id del movimiento, este viene del listado
      movement_type: tipo,
      crane_operator_id: user.id.toString(),
      container_location_id: int.parse(origenId!),
      new_container_location_id: destinoId, // Solo para Reacomodo/Camion-Piso
      container_number: _containerParaMover?.serie,
      token: token,
      site_id: user.siteId ?? '',
      weight: '',
      document_name: '',
      document: '',
      status: null,
    );

    try {
      await reacomodoUseCase.execute(movimiento);
      await cargarMapa(); // Refresca el mapa automáticamente
    } catch (e) {
      errorMessage = "Error al registrar: $e";
      notifyListeners();
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
        tipo: 'Camion-Piso',
        destinoId: ubi.id,
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
    } finally {
      // 6. Pase lo que pase, quitamos el loader
      isLoading = false;
      notifyListeners();
      return false;
    }
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

  void cancelarReacomodo() {
    // 1. Regresamos la fase a ninguno o inicio
    _faseReacomodo = FaseReacomodo.ninguno;

    // 2. Limpiamos las variables de control
    _containerParaMover = null;
    ubicacionOrigen = null;
    ubicacionDestino = null;

    // 3. Si tienes un booleano 'enModoReacomodo', ponlo en false
    // enModoReacomodo = false;

    notifyListeners(); // Esto le avisa al mapa que ya no debe pedir destino
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
