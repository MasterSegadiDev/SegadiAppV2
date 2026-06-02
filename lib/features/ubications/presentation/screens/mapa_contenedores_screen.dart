import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/ubications/data/models/ubicaciones_mapa_model.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/enums/tipo_movimiento.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/mapa_movimiento_state.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';
import 'package:segadi/features/ubications/widgets/niveles_espacios_modal.dart';
import 'package:segadi/features/ubications/widgets/selector_camion_piso.modal.dart';
import 'package:segadi/features/ubications/widgets/selector_piso_camion.modal.dart';
import 'package:segadi/features/ubications/widgets/selector_reacomodo_manual_modal.dart';

class GestionInventarioPage extends StatefulWidget {
  final MovimientoEntity? movimiento;

  const GestionInventarioPage({
    super.key,
    this.movimiento,
  });

  @override
  State<GestionInventarioPage> createState() => _GestionInventarioPageState();
}

class _GestionInventarioPageState extends State<GestionInventarioPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final vm = context.read<UbicacionesMapaViewModel>();

      await vm.cargarMapa();

      if (widget.movimiento != null) {
        await vm.iniciarMovimiento(widget.movimiento!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UbicacionesMapaViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mapa de Ubicaciones',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              vm.cargarMapa();
            },
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(
          0xFF2C522A,
        ),
      ),
      body: vm.state.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : vm.state.mapa == null
              ? Center(
                  child: Text(
                    vm.state.error ?? 'Error al cargar mapa',
                  ),
                )
              : _MapaHorizontalView(
                  vm: vm,
                ),
    );
  }
}

class _MapaHorizontalView extends StatelessWidget {
  final UbicacionesMapaViewModel vm;

  const _MapaHorizontalView({
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final data = vm.state.mapa!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*
        =========================================
        BARRA SUPERIOR MOVIMIENTO
        =========================================
        */

        if (vm.state.tipoMovimiento != TipoMovimiento.ninguno)
          _buildBarraReacomodo(context),

        /*
        =========================================
        LEYENDA
        =========================================
        */

        Container(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: Row(
            children: [
              _statusLabel(
                Colors.blue,
                "3 Niveles Libres",
              ),
              const SizedBox(width: 10),
              _statusLabel(
                Colors.green,
                "2 Niveles Libres",
              ),
              const SizedBox(width: 10),
              _statusLabel(
                Colors.yellow,
                "1 Nivel Libre",
              ),
              const SizedBox(width: 10),
              _statusLabel(
                Colors.red,
                "Lleno",
              ),
            ],
          ),
        ),

        /*
        =========================================
        MAPA
        =========================================
        */

        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: data.areas.length,
            itemBuilder: (context, index) {
              final area = data.areas[index];

              return _buildAreaColumn(
                context,
                area,
                data,
              );
            },
          ),
        ),
      ],
    );
  }

  /*
  =========================================================
  BARRA MOVIMIENTO
  =========================================================
  */

  Widget _buildBarraReacomodo(
    BuildContext context,
  ) {
    final state = vm.state;

    Color colorBarra = Colors.blueGrey;

    String titulo = '';
    String mensaje = '';

    /*
  =========================================
  PISO -> CAMIÓN
  =========================================
  */

    if (state.tipoMovimiento == TipoMovimiento.pisoCamion) {
      colorBarra = const Color(0xFF1565C0);

      final objetivo = state.contenedorObjetivo;

      titulo = 'PISO → CAMIÓN';

      mensaje = 'Mover: ${state.ordenActiva?.serieObjetivo ?? ''}\n'
          'Ubicación: '
          'Area ${objetivo?.area ?? ''} '
          'Espacio ${objetivo?.espacio ?? ''} '
          'Nivel ${objetivo?.nivel ?? ''} ';
    }
    /*
  =========================================
  CAMIÓN -> PISO
  =========================================
  */

    else if (state.tipoMovimiento == TipoMovimiento.camionPiso) {
      colorBarra = Colors.teal;

      titulo = 'CAMIÓN → PISO';

      mensaje = 'Seleccione destino para:\n'
          '${state.ordenActiva?.serieObjetivo ?? ''}';
    } else if (state.tipoMovimiento == TipoMovimiento.reacomodoManual) {
      colorBarra = Colors.orange;

      titulo = 'REACOMODO MANUAL';

      if (state.paso == PasoMovimiento.seleccionarOrigenManual) {
        mensaje = '1. Seleccione el contenedor que desea mover';
      } else if (state.paso == PasoMovimiento.seleccionarDestinoManual) {
        mensaje = vm.origenManual != null
            ? '2. Seleccione un espacio disponible para:\n'
                '${vm.origenManual?.serie ?? ''}'
            : 'Seleccione un contenedor origen';
      } else {
        mensaje = 'Proceso completado';
      }
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: colorBarra,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*
        =========================================
        INDICADOR PASO
        =========================================
        */

            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  state.paso == PasoMovimiento.seleccionarOrigenManual
                      ? Icons.upload
                      : state.paso == PasoMovimiento.seleccionarDestinoManual
                          ? Icons.download
                          : Icons.upload,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),

            /*
        =========================================
        INFO MOVIMIENTO
        =========================================
        */

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*
              =========================================
              TITULO
              =========================================
              */

                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /*
              =========================================
              MENSAJE
              =========================================
              */

                  Text(
                    mensaje,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.4,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  /*
              =========================================
              ORIGEN SELECCIONADO
              =========================================
              */

                  const SizedBox(height: 10),
                  if (state.tipoMovimiento == TipoMovimiento.reacomodoManual &&
                      vm.origenManual != null)
                    GestureDetector(
                      onTap: () {
                        vm.cancelarOrigenManual();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restart_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Cambiar de contenedor',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            /*
        =========================================
        CANCELAR
        =========================================
        */

            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                vm.reset();

                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
  =========================================================
  ÁREA
  =========================================================
  */

  Widget _buildAreaColumn(
    BuildContext context,
    AreaEntity area,
    UbicacionesMapEntity data,
  ) {
    /*
  =========================================
  ESPACIOS DEL ÁREA
  =========================================
  */

    final espacios =
        data.espacios.map((e) => e.espacioContenedor).toSet().toList();

    espacios.sort();

    return Container(
      width: 340,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          /*
        =========================================
        HEADER ÁREA
        =========================================
        */

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF263238),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Text(
              "ÁREA ${area.areaContenedor}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ),

          /*
        =========================================
        GRID ESPACIOS
        =========================================
        */

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: espacios.length,
              itemBuilder: (context, idx) {
                final espacio = espacios[idx];

                /*
              =========================================
              NIVELES
              =========================================
              */

                final niveles = _obtenerNivelesEspacio(
                  data,
                  area.areaContenedor,
                  espacio,
                );

                /*
              =========================================
              ESTADÍSTICAS
              =========================================
              */

                final libres = niveles.where((n) => n.estaLibre).length;

                //final ocupados = niveles.where((n) => n.estaOcupado).length;

                /*
              =========================================
              COLOR BASE INDUSTRIAL
              =========================================
              */

                Color baseColor;

                if (libres == 3) {
                  // TOTALMENTE LIBRE
                  baseColor = Color.fromARGB(255, 53, 150, 206);
                } else if (libres == 2) {
                  // BUENA DISPONIBILIDAD
                  baseColor = Color.fromARGB(255, 62, 187, 83);
                } else if (libres == 1) {
                  // CASI LLENO
                  baseColor = Color.fromARGB(255, 255, 188, 2);
                } else {
                  // LLENO
                  baseColor = Color.fromARGB(255, 255, 44, 44);
                }

                /*
              =========================================
              MOVIMIENTO ACTUAL
              =========================================
              */

                final state = vm.state;

                final esOrigenMovimiento = state.tipoMovimiento ==
                        TipoMovimiento.pisoCamion &&
                    state.paso != PasoMovimiento.seleccionarDestinoReacomodo &&
                    state.contenedorObjetivo != null &&
                    state.contenedorObjetivo!.area == area.areaContenedor &&
                    state.contenedorObjetivo!.espacio == espacio;

                final esDestinoSeleccionado = state.destino != null &&
                    state.destino!.area == area.areaContenedor &&
                    state.destino!.espacio == espacio;

                final esBloqueador = state.bloqueador != null &&
                    state.bloqueador!.area == area.areaContenedor &&
                    state.bloqueador!.espacio == espacio;

                /*
              =========================================
              BORDE DINÁMICO
              =========================================
              */

                Border border = Border.all(
                  color: Colors.transparent,
                  width: 2,
                );

                if (esOrigenMovimiento) {
                  border = Border.all(
                    color: Color.fromARGB(255, 0, 193, 64),
                    width: 4,
                  );
                }

                if (esDestinoSeleccionado) {
                  border = Border.all(
                    color: const Color(0xFF43A047),
                    width: 4,
                  );
                }

                if (esBloqueador) {
                  border = Border.all(
                    color: const Color(0xFFFB8C00),
                    width: 4,
                  );
                }

                /*
              =========================================
              BADGE SUPERIOR
              =========================================
              */

                String? badge;

                if (esOrigenMovimiento) {
                  badge = "MOVER";
                }

                if (esBloqueador) {
                  badge = "BLOQUEADO";
                }

                if (esDestinoSeleccionado) {
                  badge = "DESTINO";
                }

                /*
              =========================================
              CLICK ESPACIO
              =========================================
              */

                return GestureDetector(
                  onTap: () {
                    _gestionarClicEspacio(
                      context,
                      area.areaContenedor,
                      espacio,
                      niveles,
                      vm,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    transform: esOrigenMovimiento
                        ? Matrix4.identity().scaled(1.02)
                        : Matrix4.identity(),
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(14),
                      border: border,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*
                        =========================================
                        BADGE
                        =========================================
                        */

                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                  0.18,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),

                          /*
                        =========================================
                        HEADER ESPACIO
                        =========================================
                        */

                          Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "${area.areaContenedor}-${espacio.toString().padLeft(1, '0')}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                    ),
                                  ),
                                ),
                              ),
                              if (esOrigenMovimiento)
                                const Icon(
                                  Icons.local_shipping,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              if (esBloqueador)
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                            ],
                          ),
                          const Spacer(),

                          /*
                        =========================================
                        ESTADO
                        =========================================
                        */

                          Text(
                            libres == 0
                                ? "ESPACIO LLENO"
                                : "DISPONIBLES: $libres",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          /*
                        =========================================
                        NIVELES
                        =========================================
                        */

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: niveles.map((nivel) {
                              final esNivelObjetivo =
                                  state.contenedorObjetivo != null &&
                                      state.contenedorObjetivo!.area ==
                                          nivel.area &&
                                      state.contenedorObjetivo!.espacio ==
                                          nivel.espacio &&
                                      state.contenedorObjetivo!.nivel ==
                                          nivel.nivel;

                              Color colorNivel;

                              if (nivel.estaLibre) {
                                colorNivel = Colors.white70;
                              } else {
                                colorNivel = Colors.black26;
                              }

                              return AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 200,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: esNivelObjetivo ? 30 : 26,
                                height: esNivelObjetivo ? 12 : 10,
                                decoration: BoxDecoration(
                                  color: colorNivel,
                                  borderRadius: BorderRadius.circular(
                                    4,
                                  ),
                                  border: Border.all(
                                    color: esNivelObjetivo
                                        ? const Color(
                                            0xFF00ACC1,
                                          )
                                        : Colors.black12,
                                    width: esNivelObjetivo ? 2 : 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /*
  =========================================================
  OBTENER NIVELES DE UN ESPACIO
  =========================================================
  */

  List<UbicacionEntity> _obtenerNivelesEspacio(
    UbicacionesMapEntity data,
    String area,
    int espacio,
  ) {
    final List<UbicacionEntity> niveles = [];

    /*
  =========================================
  CREAR TODOS LOS NIVELES
  =========================================
  */

    for (final nivelEntity in data.niveles) {
      final nivelNumero = nivelEntity.nivelContenedor;

      final ubicacion = data.ubicaciones.firstWhere(
        (u) => u.area == area && u.espacio == espacio && u.nivel == nivelNumero,

        /*
      =========================================
      SI NO EXISTE
      =========================================
      */

        orElse: () => UbicacionModel(
          id: '',
          codigo: '$area-$espacio-$nivelNumero',
          area: area,
          espacio: espacio,
          nivel: nivelNumero,
          estado: 'Free',
          serie: null,
          color: 'green',
        ),
      );

      niveles.add(ubicacion);
    }

    /*
  =========================================
  NIVEL 3 ARRIBA
  =========================================
  */

    niveles.sort(
      (a, b) => b.nivel.compareTo(a.nivel),
    );

    return niveles;
  }
  /*
  =========================================================
  CLICK ESPACIO
  =========================================================
  */

  Future<void> _gestionarClicEspacio(
    BuildContext context,
    String areaNom,
    int espNom,
    List<UbicacionEntity> niveles,
    UbicacionesMapaViewModel vm,
  ) async {
    final state = vm.state;

    /*
   =========================================
   CAMION - PISO 
   ========================================
   */

    if (state.esCamionPiso) {
      final resultado = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SelectorCamionPisoModal(
          area: areaNom,
          espacio: espNom,
          niveles: niveles,
          vm: vm,
        ),
      );

      if (!context.mounted) return;

      await Future.delayed(const Duration(milliseconds: 250));

      if (resultado == true) {
        _mostrarResultadoMovimiento(
          context,
          exito: true,
          titulo: 'Movimiento registrado',
          mensaje: 'El contenedor fue ingresado correctamente.',
        );
      } else if (resultado == false) {
        _mostrarResultadoMovimiento(
          context,
          exito: false,
          titulo: 'Error al registrar el movimiento',
          mensaje: vm.state.error ?? 'Ocurrió un error inesperado.',
        );
      }
    }
    /*
  =========================================
  REACOMODO
  =========================================
  */
    else if (state.esPisoCamion) {
      final resultado = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SelectorNivelesModal(
          area: areaNom,
          espacio: espNom,
          niveles: niveles,
          vm: vm,
        ),
      );

      if (!context.mounted) return;

      // ESPERAR A QUE TERMINE DE CERRARSE EL MODAL
      await Future.delayed(const Duration(milliseconds: 250));

      if (resultado == true) {
        _mostrarResultadoMovimiento(
          context,
          exito: true,
          titulo: 'Movimiento registrado',
          mensaje: 'El contenedor fue retirado correctamente.',
        );
      } else if (resultado == false) {
        _mostrarResultadoMovimiento(
          context,
          exito: false,
          titulo: 'Error al registrar el movimiento',
          mensaje: vm.state.error ?? 'Ocurrió un error inesperado.',
        );
      }
    }

    /*
  =========================================
  REACOMODO MANUAL
  =========================================
  */
    else if (state.esReacomodo) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      final resultado = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SelectorReacomodoManualModal(
          area: areaNom,
          espacio: espNom,
          niveles: niveles,
          vm: vm,
        ),
      );

      if (resultado == true) {
        await vm.cargarMapa();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mostrarResultadoMovimiento(
            rootContext,
            exito: true,
            titulo: 'Movimiento registrado',
            mensaje: 'El contenedor fue retirado correctamente.',
          );
        });
      } else if (resultado == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mostrarResultadoMovimiento(
            rootContext,
            exito: false,
            titulo: 'Error al registrar el movimiento',
            mensaje: vm.state.error ?? 'Ocurrió un error inesperado.',
          );
        });
      }
    } else {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => VisualizarEspacioModal(
          area: areaNom,
          espacio: espNom,
          niveles: niveles,
        ),
      );
    }
  }
  /*
  =========================================================
  STATUS
  =========================================================
  */

  Widget _statusLabel(
    Color color,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _mostrarResultadoMovimiento(
    BuildContext context, {
    required bool exito,
    required String titulo,
    required String mensaje,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 50,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 360,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /*
                  =========================================
                  ICONO
                  =========================================
                  */

                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color:
                            exito ? Colors.green.shade50 : Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        exito
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color:
                            exito ? Colors.green.shade700 : Colors.red.shade700,
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 22),

                    /*
                  =========================================
                  TITULO
                  =========================================
                  */

                    Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 14),

                    /*
                  =========================================
                  MENSAJE
                  =========================================
                  */

                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    /*
                  =========================================
                  BOTON
                  =========================================
                  */

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: exito
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
