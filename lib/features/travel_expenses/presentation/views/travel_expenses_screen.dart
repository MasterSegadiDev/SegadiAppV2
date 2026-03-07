import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/travel_expenses/presentation/viewmodels/travel_expenses_view_model.dart';
import 'package:segadi/features/travel_expenses/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:segadi/features/travel_expenses/presentation/widgets/expense_card.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Viáticos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
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
        onPressed: () => _showAddExpenseSheet(context, vm),
        label: const Text('Nuevo Gasto'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF84A756),
      ),
    );
  }

  Widget _buildHeader(TravelExpensesViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C522A).withOpacity(0.1),
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const Text('Total Comprobado',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
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
    if (vm.registeredExpenses.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No hay gastos registrados aún.')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              ExpenseCard(expense: vm.registeredExpenses[index]),
          childCount: vm.registeredExpenses.length,
        ),
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context, TravelExpensesViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Permite ver el redondeado del widget hijo
      builder: (context) => AddExpenseBottomSheet(serviceId: widget.serviceId),
    );
  }
}
