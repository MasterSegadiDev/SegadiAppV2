import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/views/container_movements/containers_map.dart';
import 'package:segadi/views/home/sidebar.dart';

class MovimientoView extends StatefulWidget {
  const MovimientoView({super.key});

  @override
  State<MovimientoView> createState() => _MovimientoViewState();
}

class _MovimientoViewState extends State<MovimientoView> {
  String? _currentSiteId;
  String? _error;
  bool _isLoading = true;
  late TextEditingController _numeroSerieController;
  bool _expanded = false;
  final Set<int> expandedIndex = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ Cargar sesión antes de todo
      final session = UserSession();
      await session.loadFromPrefs();

      if (session.siteId == null || session.siteId!.isEmpty) {
        setState(() {
          _error =
              "No se encontró un site_id válido. Inicie sesión nuevamente.";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _currentSiteId = session.siteId;
      });

      // ✅ Cargar movimientos del site actual
      final viewModel =
          Provider.of<ContainerMovementListViewModel>(context, listen: false);
      await viewModel.loadMovimientos(siteId: _currentSiteId!);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    });

    _numeroSerieController = TextEditingController(text: '');
  }

  /// 🔹 Función para refrescar datos manualmente
  Future<void> _handleRefresh() async {
    if (_currentSiteId == null || _currentSiteId!.isEmpty) return;

    final viewModel =
        Provider.of<ContainerMovementListViewModel>(context, listen: false);

    await viewModel.loadMovimientos(
      siteId: _currentSiteId!,
      forceReload: true,
    );

    // 🔹 Aseguramos que la UI se reconstruya después del refresh
    if (mounted) {
      setState(() {});
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ContainerMovementListViewModel>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movimiento de contenedores',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: viewModel.isLoading
              // ✅ Carga inicial
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 200),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : viewModel.error != null
                  // ✅ Mostrar error
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 200),
                        Center(
                          child: Text(
                            viewModel.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  : viewModel.movimientos.isEmpty
                      // ✅ Lista vacía
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                "No hay movimientos asignados por el momento",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ],
                        )
                      // ✅ Lista de movimientos
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: viewModel.movimientos.length,
                          itemBuilder: (context, index) {
                            final m = viewModel.movimientos[index];

                            // Determinar contenedor a mover
                            String? containerToMove =
                                m.containerToMove?.toLowerCase();
                            String? contenedorMover;
                            if (containerToMove != null) {
                              if (containerToMove.contains('a')) {
                                contenedorMover = m.containerNumberA;
                              } else if (containerToMove.contains('b')) {
                                contenedorMover = m.containerNumberB;
                              }
                            }

                            // Lista de filas de información
                            final infoRows = [
                              _buildInfoRow(
                                icon: LucideIcons.frame,
                                label: "Movimiento de grúa",
                                value: m.craneMovement ?? 'S/N',
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.type,
                                label: "Tipo de movimiento",
                                value: m.movementType ?? 'N/A',
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.fileText,
                                label: "Remisión",
                                value: m.service ?? 'N/A',
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.user,
                                label: "Operador",
                                value: m.craneOperator ?? 'Sin operador',
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.truck,
                                label: "Unidad",
                                value: m.unit ?? 'No hay unidad',
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.truck,
                                label: "Unidad Mov. Local",
                                value: m.localUnit ??
                                    'No hay unidad local asignada',
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.container,
                                label: "Número de contenedor",
                                value: contenedorMover ?? 'S/N',
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.container,
                                label: "Estado del contenedor",
                                value: m.containerStatus ?? 'S/E',
                              ),
                            ];

                            // Datos principales para vista resumida
                            final resumenRows = infoRows.take(3).toList();

                            final isExpanded = expandedIndex.contains(index);

                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContainersMapScreen(
                                      status: m.status,
                                      movementId: m.id,
                                      initialArea: m.area,
                                      initialEspacio: m.space,
                                      initialNivel: m.level,
                                      movementType: m.movementType!,
                                      containerNumber: contenedorMover,
                                      siteId: _currentSiteId!,
                                    ),
                                  ),
                                );

                                if (result == 'recargar') {
                                  await _handleRefresh();
                                }
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedCrossFade(
                                        firstChild:
                                            Column(children: resumenRows),
                                        secondChild: Column(children: infoRows),
                                        crossFadeState: isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration:
                                            const Duration(milliseconds: 250),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              if (isExpanded) {
                                                expandedIndex.remove(index);
                                              } else {
                                                expandedIndex.add(index);
                                              }
                                            });
                                          },
                                          icon: Icon(
                                            isExpanded
                                                ? LucideIcons.chevronUp
                                                : LucideIcons.chevronDown,
                                            size: 18,
                                            color: Colors.green,
                                          ),
                                          label: Text(
                                            isExpanded
                                                ? "Ver menos"
                                                : "Ver más",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
      floatingActionButton: _buildFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 🔹 Botones flotantes
  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'reacomodo',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ContainersMapScreen(
                  status: '',
                  movementId: 0,
                  initialArea: '',
                  initialEspacio: '',
                  initialNivel: '',
                  movementType: 'Reacomodo',
                  siteId: _currentSiteId!,
                ),
              ),
            );
          },
          icon: const Icon(Icons.swap_horiz, color: Colors.white),
          label: const Text('Reacomodo', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'pesaje',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ContainersMapScreen(
                  status: '',
                  movementId: 0,
                  initialArea: '',
                  initialEspacio: '',
                  initialNivel: '',
                  movementType: 'Pesaje',
                  containerNumber: '',
                  siteId: _currentSiteId!,
                ),
              ),
            );
          },
          icon: const Icon(Icons.scale, color: Colors.white),
          label: const Text('Pesaje', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepOrange,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey.shade700),
          const SizedBox(width: 8),
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      fontSize: 13.5,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade900,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Widget para mostrar info de cada movimiento
  // Widget _buildInfoRow({
  //   required IconData icon,
  //   required String label,
  //   required String value,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       children: [
  //         Icon(icon, size: 20, color: Colors.grey.shade700),
  //         const SizedBox(width: 10),
  //         Text(
  //           "$label: ",
  //           style: const TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         Expanded(
  //           child: Text(
  //             value,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
