import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/travel_expenses/presentation/viewmodels/travel_expenses_view_model.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  final int serviceId;
  const AddExpenseBottomSheet({super.key, required this.serviceId});

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  int? _selectedConceptId;
  bool _triedSubmit = false;

  // --- LÓGICA DE SEGURIDAD PARA ELEMENTOS ---

  bool _isEvidenceRequired(TravelExpensesViewModel vm) {
    // Si la lista está vacía o no hay selección, devolvemos false por defecto.
    if (_selectedConceptId == null || vm.availableConcepts.isEmpty)
      return false;

    // Buscamos de forma segura usando cast a dynamic o un find manual
    // para evitar el crash de .first en listas vacías.
    final selected = vm.availableConcepts.cast<dynamic>().firstWhere(
          (c) => c.id == _selectedConceptId,
          orElse: () => null,
        );

    return selected?.paymentRequireEvidence == "Si";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();

    // Limpieza silenciosa al cerrar
    Future.microtask(() {
      if (mounted) {
        // Asumiendo que estos métodos existen en tu VM
        // Si no existen, comenta estas líneas.
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TravelExpensesViewModel>();

    // 1. ESTADO DE CARGA: Si el VM no tiene datos, no renderizamos el form para evitar errores.
    if (vm.availableConcepts.isEmpty &&
        vm.status == TravelExpensesStatus.loading) {
      return const SizedBox(
        height: 300,
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFF2C522A))),
      );
    }

    final bool isRequired = _isEvidenceRequired(vm);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Registrar Gasto',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C522A))),
              const SizedBox(height: 20),

              if (vm.errorMessage != null) _buildErrorBanner(vm.errorMessage!),

              // 1. Dropdown de Conceptos (Seguro)
              DropdownButtonFormField<int>(
                isExpanded: true,
                value:
                    vm.availableConcepts.any((c) => c.id == _selectedConceptId)
                        ? _selectedConceptId
                        : null,
                decoration: _inputDecoration(
                    'Concepto de Gasto *', Icons.category_outlined),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down_circle_outlined,
                    color: Colors.blueGrey),
                items: vm.availableConcepts.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            c.concept,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        _buildAmountBadge(c.paymentTotal),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  _selectedConceptId = val;
                  _triedSubmit = false; // Limpiamos el error al cambiar
                }),
                validator: (val) =>
                    val == null ? 'Selecciona un concepto' : null,
              ),
              const SizedBox(height: 15),

              // 2. Importe (Validación Robusta)
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(
                    'Importe *', Icons.monetization_on_outlined),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingresa el monto';
                  final inputAmount = double.tryParse(val);
                  if (inputAmount == null) return 'Monto inválido';
                  if (inputAmount <= 0) return 'El monto debe ser mayor a 0';

                  if (_selectedConceptId != null &&
                      vm.availableConcepts.isNotEmpty) {
                    final selectedConcept = vm.availableConcepts.firstWhere(
                      (c) => c.id == _selectedConceptId,
                      orElse: () => vm.availableConcepts.first,
                    );

                    if (inputAmount > selectedConcept.paymentTotal) {
                      return 'Máximo permitido: \$${selectedConcept.paymentTotal.toStringAsFixed(2)}';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 3. Comentario
              TextFormField(
                controller: _commentController,
                decoration:
                    _inputDecoration('Comentario (Opcional)', Icons.notes),
              ),
              const SizedBox(height: 20),

              // 4. Sección de Cámara (Detección de Error)
              _buildCameraSection(vm, isRequired),

              const SizedBox(height: 25),

              // 5. Botón de Envío
              _buildSubmitButton(vm, isRequired),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGETS PARA LIMPIEZA VISUAL ---

  Widget _buildAmountBadge(double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        '\$${amount.toStringAsFixed(2)}',
        style: const TextStyle(
            color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildCameraSection(TravelExpensesViewModel vm, bool isRequired) {
    final bool hasImage = vm.selectedImage != null;
    final bool showError = _triedSubmit && isRequired && !hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Evidencia',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: showError ? Colors.red : Colors.black87)),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => vm.pickImage(),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: showError ? Colors.red[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: showError
                    ? Colors.red
                    : (hasImage ? const Color(0xFF84A756) : Colors.grey[400]!),
                width: showError ? 2 : 1,
              ),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(vm.selectedImage!, fit: BoxFit.cover))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 40,
                          color: showError ? Colors.red : Colors.grey),
                      Text(isRequired ? 'Foto Obligatoria' : 'Tomar Foto',
                          style: TextStyle(
                              color: showError ? Colors.red : Colors.grey)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(TravelExpensesViewModel vm, bool isRequired) {
    final bool isLoading = vm.status == TravelExpensesStatus.loading;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C522A),
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      onPressed: isLoading
          ? null
          : () async {
              setState(() => _triedSubmit = true);

              if (!_formKey.currentState!.validate()) return;
              if (isRequired && vm.selectedImage == null) return;

              final success = await vm.saveExpense(
                serviceId: widget.serviceId,
                conceptId: _selectedConceptId!,
                amount: double.parse(_amountController.text),
                comments: _commentController.text,
              );

              if (success && mounted) Navigator.pop(context);
            },
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : const Text('Enviar Comprobación',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF84A756)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF2C522A), width: 2),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.red, fontSize: 13))),
        ],
      ),
    );
  }
}
