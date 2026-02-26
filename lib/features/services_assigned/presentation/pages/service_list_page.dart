import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/service_state.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/services_viewmodel.dart';
import 'package:segadi/features/services_assigned/presentation/widgets/service_card.dart';
import 'package:segadi/views/home/sidebar.dart';

class ServicesAssignedPage extends StatefulWidget {
  const ServicesAssignedPage({super.key});

  @override
  State<ServicesAssignedPage> createState() => _ServiceListViewState();
}

class _ServiceListViewState extends State<ServicesAssignedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServicesViewModel>();

    return Scaffold(
      // DISEÑO ORIGINAL: Fondo gris claro para que resalten las cards blancas
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(),
      drawer: DrawerScreen(),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: _buildBody(vm),
      ),
      floatingActionButton: _buildCallButton(),
    );
  }

  Widget _buildBody(ServicesViewModel vm) {
    final state = vm.state;

    if (state is ServicesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ServicesError) {
      return _buildErrorState(state.message, vm);
    }

    if (state is ServicesEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Espaciado dinámico basado en la pantalla
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono moderno con un fondo circular suave
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons
                        .assignment_turned_in_outlined, // Icono de "tareas completadas" o "nada pendiente"
                    size: 80,
                    color: Colors.blueGrey[300],
                  ),
                ),
                const SizedBox(height: 24),

                // Texto de Título
                const Text(
                  'Todo al día',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C522A), // Tu verde institucional
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Mensaje del Backend con tipografía profesional
                Text(
                  state.message, // "Por el momento no se te han asignado..."
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey[600],
                    height: 1.5, // Altura de línea para mejor lectura
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 30),

                // Botón de refrescar opcional para darle interacción
                TextButton.icon(
                  onPressed: vm.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Verificar de nuevo'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2C522A),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state is ServicesLoaded) {
      final query = _searchQuery.toLowerCase().trim();
      final filteredItems = state.items.where((item) {
        if (query.isEmpty) return true;
        return (item.service ?? '').toLowerCase().contains(query) ||
            (item.client ?? '').toLowerCase().contains(query) ||
            (item.origin ?? '').toLowerCase().contains(query) ||
            (item.destination ?? '').toLowerCase().contains(query);
      }).toList();

      return Column(
        children: [
          // BUSCADOR CON DISEÑO ORIGINAL (Blanco con sombra o bordes redondeados)
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar remisión, cliente...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // EL LISTADO CON EL FONDO GRIS DETRÁS DE LAS CARDS
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('Sin coincidencias'))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      // Tu ServiceCard ya debe traer su propio margin/padding blanco
                      return ServiceCard(item: filteredItems[index]);
                    },
                  ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ============== MANTENIENDO TUS COMPONENTES DE DISEÑO ==============

  Widget _buildErrorState(String message, ServicesViewModel vm) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 150),
        //Icon(Icons.warning_amber_rounded, size: 70, color: Colors.red[300]),
        const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent)),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: vm.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C522A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child:
                const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Servicios Asignados',
          style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF2C522A),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  FloatingActionButton _buildCallButton() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: () => FlutterPhoneDirectCaller.callNumber('523311364928'),
      child: const Icon(Icons.phone, color: Colors.white),
    );
  }
}
