import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
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
    // Carga inicial de datos
    Future.microtask(() =>
        context.read<TravelExpensesViewModel>().loadAllData(widget.serviceId));
  }

  // Helper para mostrar SnackBar de error sin interrumpir el Build
  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.read<TravelExpensesViewModel>().clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TravelExpensesViewModel>();

    // Escuchador de errores
    if (vm.status == TravelExpensesStatus.error && vm.errorMessage.isNotEmpty) {
      _showError(vm.errorMessage);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Gestión de Viáticos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C522A),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: vm.status == TravelExpensesStatus.loading &&
              vm.registeredExpenses.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C522A)))
          : RefreshIndicator(
              color: const Color(0xFF2C522A),
              onRefresh: () => vm.loadAllData(widget.serviceId),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildHeader(vm),
                  if (vm.registeredExpenses.isEmpty)
                    _buildEmptyState()
                  else
                    _buildExpensesList(vm),
                  // Espaciado inferior para que el FAB no tape el último item
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
      floatingActionButton: _buildFAB(context, vm),
    );
  }

  Widget _buildHeader(TravelExpensesViewModel vm) {
    return SliverToBoxAdapter(
      child: FadeInDown(
        duration: const Duration(milliseconds: 400),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C522A), Color(0xFF45823F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C522A).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            children: [
              const Text('Total Comprobado',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14, letterSpacing: 1)),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  '\$${vm.totalImport.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesList(TravelExpensesViewModel vm) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final expense = vm.registeredExpenses[index];
            return FadeInUp(
              duration: Duration(milliseconds: 300 + (index * 50)),
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () => _showImageDialog(context, expense.id, vm),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2C522A).withOpacity(0.1),
                    child: const Icon(Icons.receipt_long,
                        color: Color(0xFF2C522A)),
                  ),
                  title: Text(expense.concept,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text(
                    "\$${expense.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: Color(0xFF2C522A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  trailing: const Icon(Icons.image_search,
                      color: Colors.grey, size: 22),
                ),
              ),
            );
          },
          childCount: vm.registeredExpenses.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("No hay gastos registrados",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, TravelExpensesViewModel vm) {
    final bool canAdd = vm.availableConcepts.isNotEmpty &&
        vm.status != TravelExpensesStatus.loading;

    return FloatingActionButton.extended(
      elevation: canAdd ? 4 : 0,
      backgroundColor: canAdd ? const Color(0xFF2C522A) : Colors.grey.shade400,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      onPressed: canAdd ? () => _showAddExpenseSheet(context, vm) : null,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        canAdd ? 'Comprobar Viáticos' : 'Sin pendientes',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- MODALES ---

  void _showAddExpenseSheet(BuildContext context, TravelExpensesViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseBottomSheet(serviceId: widget.serviceId),
    ).whenComplete(() => vm.clearSelectedImage());
  }

  void _showImageDialog(
      BuildContext context, int id, TravelExpensesViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<Uint8List?>(
        future: vm.viewEvidence(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          final hasImage = snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty;

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(hasImage ? "Evidencia" : "Sin Archivo",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(dialogContext)),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            Image.memory(snapshot.data!, fit: BoxFit.contain),
                      )
                    else
                      _buildNoImagePlaceholder(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("CERRAR",
                    style: TextStyle(
                        color: Color(0xFF2C522A), fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.image_not_supported_outlined,
            size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 10),
        const Text("No se encontró evidencia física.",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
