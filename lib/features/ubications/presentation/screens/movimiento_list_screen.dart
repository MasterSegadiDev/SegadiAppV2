import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/ubications/enums/etapa_movimiento.dart';
import 'package:segadi/features/ubications/presentation/screens/mapa_contenedores_screen.dart';
import 'package:segadi/features/ubications/presentation/screens/pesaje_screen.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/movimiento_list_viewmodel.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

// Importaciones de tu proyecto

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
      // final session = UserSession();
      final session = '1234445566';
      // await session.loadFromPrefs();

      // Debug: Verificar site_id

      if (session == '' || session == null) {
        if (mounted) {
          setState(() {
            _error =
                "No se encontró un site_id válido. Inicie sesión nuevamente.";
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) setState(() => _currentSiteId = session);

      final viewModel = context.read<MovimientoListViewModel>();
      await viewModel.loadMovimientos(session);

      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _handleRefresh() async {
    if (_currentSiteId == null) return;
    await context
        .read<MovimientoListViewModel>()
        .loadMovimientos(_currentSiteId!);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MovimientoListViewModel>(context);

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
      // drawer: const DrawerScreen(),
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
                      ],
                    ),
                  ],
                ),
              ),

              // --- LISTADO ---
              Expanded(
                child: _buildListContent(viewModel),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildFloatingButtons() {
    final vm = context.read<UbicacionesMapaViewModel>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 🔵 BOTÓN REACOMODO MANUAL
        FloatingActionButton.extended(
          heroTag: 'reacomodo',
          onPressed: () {
            vm.iniciarReacomodoManual();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GestionInventarioPage(),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PesajeFormScreen(
                  origen: PesajeOrigen.manual,
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

  Widget _buildListContent(
    MovimientoListViewModel viewModel,
  ) {
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
      return (m.serieObjetivo).toLowerCase().contains(query) ||
          (m.contenedorB ?? '').toLowerCase().contains(query) ||
          (m.tipo.name).toLowerCase().contains(query) ||
          (m.folio).toLowerCase().contains(query) ||
          (m.servicio).toLowerCase().contains(query);
    }).toList();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final m = filtrados[index];

        return GestureDetector(
          onTap: () {
            switch (m.tipo.name) {
              case 'pesaje':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PesajeFormScreen(
                      movimiento: m,
                    ),
                  ),
                );
                break;

              default:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GestionInventarioPage(
                      movimiento: m,
                    ),
                  ),
                );
            }
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
                      "MOV ${m.folio}",
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
                        'Numero de contenedor: ${m.serieObjetivo}',
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
                    _chipPremium(
                        obtenerNombreFormateado(m.tipo.name), Colors.green),
                    _chipPremium("Remisión: ${m.servicio}", Colors.blueGrey),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // FILAS DE INFORMACIÓN (TU DISEÑO CON RICH TEXT)
                _buildInfoRow(
                    icon: LucideIcons.user, label: "Operador", value: m.folio),
                _buildInfoRow(
                    icon: LucideIcons.truck, label: "Unidad", value: m.unidad),
                _buildInfoRow(
                  icon: LucideIcons.navigation,
                  label: "Unidad Local",
                  value: m.localUnidad,
                ),
                _buildInfoRow(
                    icon: LucideIcons.container,
                    label: "Estado Cont.",
                    value: m.estadoContenedor),
                _buildInfoRow(
                  icon: LucideIcons.hash,
                  label: "Contenedor",
                  value: m.serieObjetivo,
                ),
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

  String obtenerNombreFormateado(String tipo) {
    switch (tipo) {
      case 'pisoCamion':
        return 'Piso - Camion';
      case 'camionPiso':
        return 'Camion - Piso';
      default:
        return tipo; // Por si llega un valor que no esperabas
    }
  }
}
