import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/views/container_movements/containers_map.dart';
import 'package:segadi/views/home/sidebar.dart';

class MovimientoViewFake extends StatefulWidget {
  const MovimientoViewFake({super.key});

  @override
  State<MovimientoViewFake> createState() => _MovimientoViewState();
}

class _MovimientoViewState extends State<MovimientoViewFake> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _currentSiteId;
  String? _error;
  bool _isLoading = true; // Control local para la carga de la sesión inicial

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Cargar sesión (UserSession sigue siendo un Singleton, está bien así)
      final session = UserSession();
      await session.loadFromPrefs();

      if (session.siteId == null || session.siteId!.isEmpty) {
        if (mounted) {
          setState(() {
            _error =
                "No se encontró un site_id válido. Inicie sesión nuevamente.";
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _currentSiteId = session.siteId;
        });
      }

      // 2. Disparar la carga inicial a través del ViewModel ya inyectado
      // Usamos read porque es una acción puntual dentro de initState
      final viewModel = context.read<ContainerMovementListViewModel>();
      await viewModel.loadMovimientos(siteId: _currentSiteId!);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  /// 🔹 Función para refrescar datos manualmente
  Future<void> _handleRefresh() async {
    if (_currentSiteId == null) return;

    // Usamos read para disparar el método del ViewModel
    await context.read<ContainerMovementListViewModel>().loadMovimientos(
          siteId: _currentSiteId!,
          forceReload: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ContainerMovementListViewModel>(context);
    final ubicacionesvM = Provider.of<UbicacionesViewModel>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
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
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 200),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : viewModel.error != null
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

                      // ================================
                      // LISTA + BUSCADOR
                      // ================================
                      : Column(
                          children: [
                            // 🔍 BUSCADOR
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText:
                                      "Buscar por serie, tipo o número de movimiento...",
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),

                            // LISTA FILTRADA
                            Expanded(
                              child: Builder(
                                builder: (_) {
                                  final query = _searchQuery.toLowerCase();

                                  final movimientosFiltrados =
                                      viewModel.movimientos.where((m) {
                                    if (query.isEmpty) return true;

                                    final serieA = (m.containerNumberA ?? "")
                                        .toLowerCase();
                                    final serieB = (m.containerNumberB ?? "")
                                        .toLowerCase();
                                    final tipo =
                                        (m.movementType ?? "").toLowerCase();
                                    final mov =
                                        (m.craneMovement ?? "").toLowerCase();

                                    return serieA.contains(query) ||
                                        serieB.contains(query) ||
                                        tipo.contains(query) ||
                                        mov.contains(query);
                                  }).toList();

                                  return ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(12),
                                    itemCount: movimientosFiltrados.length,
                                    itemBuilder: (context, index) {
                                      final m = movimientosFiltrados[index];

                                      // Determinar contenedor a mover
                                      String? containerToMove =
                                          m.containerToMove?.toLowerCase();
                                      String? contenedorMover;
                                      if (containerToMove != null) {
                                        if (containerToMove.contains('a')) {
                                          contenedorMover = m.containerNumberA;
                                        } else if (containerToMove
                                            .contains('b')) {
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
                                          value:
                                              m.craneOperator ?? 'Sin operador',
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

                                      return GestureDetector(
                                        onTap: () async {
                                          viewModel.setSelectedMovement(
                                              m,
                                              _currentSiteId!,
                                              contenedorMover,
                                              ubicacionesvM);

                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ContainersMapScreen(),
                                            ),
                                          );

                                          if (result == 'recargar') {
                                            await _handleRefresh();
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // ENCABEZADO
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "MOV ${m.craneMovement ?? 'S/N'}",
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0.2,
                                                        height: 1.2,
                                                        color:
                                                            Color(0xFF1A1A1A),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Número de contenedor: ${contenedorMover}",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.3,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 12),

                                              // CHIPS
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 6,
                                                children: [
                                                  _chipPremium(
                                                    m.movementType ??
                                                        "Tipo no definido",
                                                    Colors.green,
                                                  ),
                                                  _chipPremium(
                                                    "Remisión ${m.service ?? 'N/A'}",
                                                    Colors.green,
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 16),
                                              Divider(
                                                  color: Colors.grey.shade300),
                                              const SizedBox(height: 16),

                                              // DETALLES
                                              _detallePremium(
                                                  "Operador",
                                                  m.craneOperator ??
                                                      "Sin operador"),
                                              _detallePremium("Unidad",
                                                  m.unit ?? "No hay unidad"),
                                              _detallePremium(
                                                  "Unidad Local",
                                                  m.localUnit ??
                                                      "No hay unidad local"),
                                              _detallePremium(
                                                  "Estado del contenedor",
                                                  m.containerStatus ?? "S/E"),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
        ),
      ),
      floatingActionButton: _buildFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _chipPremium(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _detallePremium(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.25,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Botones flotantes
  Widget _buildFloatingButtons() {
    final movementVm =
        Provider.of<ContainerMovementListViewModel>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 🔵 BOTÓN REACOMODO MANUAL
        FloatingActionButton.extended(
          heroTag: 'reacomodo',
          onPressed: () {
            movementVm.setManualMovement(
              type: "Reacomodo",
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ContainersMapScreen(),
              ),
            );
          },
          icon: const Icon(Icons.swap_horiz, color: Colors.white),
          label: const Text('Reacomodo', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
        ),

        const SizedBox(height: 12),

        // 🟠 BOTÓN PESAJE MANUAL
        FloatingActionButton.extended(
          heroTag: 'pesaje',
          onPressed: () {
            movementVm.setManualMovement(
              type: "Pesaje",
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ContainersMapScreen(),
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
                      color: Colors.black,
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
}
