import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/ubications/presentation/screens/mapa_contenedores_screen.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/movimiento_list_viewmodel.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

// Importaciones de tu proyecto
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/views/home/sidebar.dart';

class MovimientoView extends StatefulWidget {
  const MovimientoView({super.key});

  @override
  State<MovimientoView> createState() => _MovimientoViewState();
}

class _MovimientoViewState extends State<MovimientoView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _currentSiteId;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = UserSession();
      await session.loadFromPrefs();

      if (session.siteId == null || session.siteId.isEmpty) {
        if (mounted) {
          setState(() {
            _error =
                "No se encontró un site_id válido. Inicie sesión nuevamente.";
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) setState(() => _currentSiteId = session.siteId);

      final viewModel = context.read<MovimientoListViewModel>();
      await viewModel.loadMovimientos('2');

      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _handleRefresh() async {
    if (_currentSiteId == null) return;
    await context.read<MovimientoListViewModel>().loadMovimientos('2');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MovimientoListViewModel>(context);
    final ubicacionesvM = Provider.of<UbicacionesViewModel>(context);

    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos Activos',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
        elevation: 0, // Quitamos sombra para que se una con el buscador
      ),
      backgroundColor: const Color(
          0xFFF5F7F5), // Un gris muy ligero para que resalten las tarjetas
      drawer: const DrawerScreen(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Column(
            children: [
              // --- PANEL DE HERRAMIENTAS SUPERIOR ---
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color:
                      Color(0xFF2C522A), // Fondo verde para integrar con AppBar
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // BUSCADOR (Flexible para que use el espacio restante)
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: "Buscar contenedor...",
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                              ),
                              onChanged: (value) =>
                                  setState(() => _searchQuery = value),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // BOTÓN REACOMODO (Icono circular)
                        _actionIconBtn(
                          icon: Icons.swap_horiz,
                          color: Colors.teal.shade400,
                          onTap: () {
                            context
                                .read<UbicacionesMapaViewModel>()
                                .prepararMovimiento();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const GestionInventarioPage()));
                          },
                        ),
                        const SizedBox(width: 8),

                        // BOTÓN PESAJE (Icono circular)
                        _actionIconBtn(
                          icon: Icons.scale,
                          color: Colors.orange.shade700,
                          onTap: () {
                            // Tu lógica de pesaje
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const GestionInventarioPage()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- LISTADO ---
              Expanded(
                child: _buildListContent(viewModel, ubicacionesvM),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionIconBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildListContent(
      MovimientoListViewModel viewModel, UbicacionesViewModel ubicacionesvM) {
    if (viewModel.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (viewModel.movimientos.isEmpty) {
      return const Center(
          child: Text("No hay movimientos asignados",
              style: TextStyle(color: Colors.grey)));
    }

    // Lógica de Filtrado
    final query = _searchQuery.toLowerCase();
    final filtrados = viewModel.movimientos.where((m) {
      if (query.isEmpty) return true;
      return (m.contenedorA).toLowerCase().contains(query) ||
          (m.contenedorB).toLowerCase().contains(query) ||
          (m.tipoMovimiento).toLowerCase().contains(query) ||
          (m.folioMovimiento).toLowerCase().contains(query) ||
          (m.servicio).toLowerCase().contains(query);
    }).toList();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final m = filtrados[index];

        // Identificar qué contenedor se va a mover
        String? containerToMoveStr = m.contenedorAMover.toLowerCase();
        String? contenedorMover =
            (containerToMoveStr.contains('a')) ? m.contenedorA : m.contenedorB;

        return GestureDetector(
          onTap: () {
            final vm = context.read<UbicacionesMapaViewModel>();

            vm.prepararMovimiento(m);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GestionInventarioPage(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CABECERA: ID MOVIMIENTO Y NÚMERO DE CONTENEDOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "MOV ${m.folioMovimiento}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C522A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'Numero de contenedor: ${m.contenedorAMover}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // CHIPS DE ESTADO/TIPO
                Wrap(
                  spacing: 8,
                  children: [
                    _chipPremium(m.tipoMovimiento, Colors.green),
                    _chipPremium("Remisión: ${m.servicio}", Colors.blueGrey),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // FILAS DE INFORMACIÓN (TU DISEÑO CON RICH TEXT)
                _buildInfoRow(
                    icon: LucideIcons.user,
                    label: "Operador",
                    value: m.operador),
                _buildInfoRow(
                    icon: LucideIcons.truck, label: "Unidad", value: m.unidad),
                _buildInfoRow(
                    icon: LucideIcons.navigation,
                    label: "Unidad Local",
                    value: m.unidadLocal),
                _buildInfoRow(
                    icon: LucideIcons.container,
                    label: "Estado Cont.",
                    value: m.estatus),
                _buildInfoRow(
                    icon: LucideIcons.hash,
                    label: "Contenedor",
                    value: contenedorMover),
              ],
            ),
          ),
        );
      },
    );
  }

  // MÉTODO PARA CHIPS
  Widget _chipPremium(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  // MÉTODO PARA FILAS (RICH TEXT + ICONOS)
  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
