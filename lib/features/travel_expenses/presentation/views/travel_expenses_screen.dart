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
          'Registrar Viatico',
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
      builder: (context) {
        return FutureBuilder<Uint8List?>(
          future: vm.viewEvidence(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data != null) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(8),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.memory(snapshot.data!, fit: BoxFit.contain),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CERRAR"),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: const Text("Sin Evidencia"),
              content: const Text(
                  "Por el momento no tienes una imagen de evidencia para este gasto, necesitas subir una imagen para poder visualizarla aquí."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cerrar")),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddExpenseSheet(BuildContext context, TravelExpensesViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseBottomSheet(serviceId: widget.serviceId),
    );
  }
}
