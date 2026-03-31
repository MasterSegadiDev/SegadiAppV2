import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/travel_expenses/presentation/widgets/add_expense_bottom_sheet.dart';
import '../viewmodels/travel_expenses_view_model.dart';

class TravelExpensesScreen extends StatefulWidget {
  final int serviceId;
  const TravelExpensesScreen({super.key, required this.serviceId});

  @override
  State<TravelExpensesScreen> createState() => _TravelExpensesScreenState();
}

class _TravelExpensesScreenState extends State<TravelExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TravelExpensesViewModel>().loadAllData(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TravelExpensesViewModel>();

    // Listener de errores (Ej. No hay viáticos)
    if (vm.status == TravelExpensesStatus.error && vm.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm
                .errorMessage!), // Mostrará: "El servicio no tiene viaticos depositados"
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        vm.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Viáticos',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C522A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: vm.status == TravelExpensesStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => vm.loadAllData(widget.serviceId),
              child: CustomScrollView(
                slivers: [
                  _buildHeader(vm),
                  _buildExpensesList(vm),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () => _showAddExpenseSheet(context, vm),
        label: const Text(
          'Comprobar Viaticos',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
    );
  }

  Widget _buildHeader(TravelExpensesViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C522A).withOpacity(0.1),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const Text('Total Comprobado',
                style: TextStyle(color: Colors.grey)),
            Text(
              '\$${vm.totalImport.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C522A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList(TravelExpensesViewModel vm) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final expense = vm.registeredExpenses[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // Al tocar cualquier parte de la fila, se dispara el diálogo
              onTap: () {
                print("Pantalla: Clic detectado en gasto ID ${expense.id}");
                _showImageDialog(context, expense.id, vm);
              },
              title: Text(expense.concept),
              subtitle: Text("\$${expense.amount.toStringAsFixed(2)}"),
              trailing:
                  const Icon(Icons.image_search, color: Color(0xFF2C522A)),
            ),
          );
        },
        childCount: vm.registeredExpenses.length,
      ),
    );
  }

  void _showImageDialog(
      BuildContext context, int id, TravelExpensesViewModel vm) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return FutureBuilder<Uint8List?>(
          // Convertimos el id a String si tu UseCase lo requiere así
          future: vm.viewEvidence(id),
          builder: (context, snapshot) {
            // 1. ESTADO: CARGANDO
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            // 2. VALIDACIÓN DE BYTES REALES
            // Verificamos que no sea nulo Y que no tenga 0 bytes (evita el error de codec)
            final bool tieneImagenValida = snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                tieneImagenValida ? "Comprobante Fiscal" : "Sin Evidencia",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Ajuste dinámico al contenido
                children: [
                  if (tieneImagenValida)
                    // ✅ CASO: IMAGEN RECUPERADA CON ÉXITO
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.contain,
                        // Manejo de error por si los bytes vienen corruptos de todos modos
                        errorBuilder: (context, error, stackTrace) =>
                            _buildNoImagePlaceholder(),
                      ),
                    )
                  else
                    // ❌ CASO: NO HAY IMAGEN O VIENE VACÍA (0 bytes)
                    _buildNoImagePlaceholder(),

                  const SizedBox(height: 25),

                  // Botón de acción principal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cerrar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Widget auxiliar para no repetir código del placeholder
  Widget _buildNoImagePlaceholder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Image.asset(
          'assets/images/no_ticket.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
          // Seguro por si el asset no está bien configurado en pubspec
          errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image_outlined,
              size: 100,
              color: Colors.grey),
        ),
        const SizedBox(height: 20),
        const Text(
          "No se registro una evidencia para este concepto.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }

  void _showAddExpenseSheet(BuildContext context, TravelExpensesViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Para bordes redondeados limpios
      builder: (context) => AddExpenseBottomSheet(serviceId: widget.serviceId),
    ).whenComplete(() {
      // ESTO ES LO PROFESIONAL:
      // Se ejecuta SIEMPRE que la modal desaparece, sin importar el motivo.
      context.read<TravelExpensesViewModel>().clearSelectedImage();
    });
  }
}
