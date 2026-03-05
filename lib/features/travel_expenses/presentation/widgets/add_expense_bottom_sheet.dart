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

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TravelExpensesViewModel>();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Registrar Gasto',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C522A))),
              ),
              const SizedBox(height: 20),

              // --- SECCIÓN DE ERROR DEL SERVIDOR ---
              if (vm.errorMessage != null) _buildErrorBanner(vm.errorMessage!),

              // 1. Concepto
              DropdownButtonFormField<int>(
                // Mantenemos el "Safe Check" para evitar el error anterior
                value: (vm.availableConcepts
                        .any((c) => c.id == _selectedConceptId))
                    ? _selectedConceptId
                    : null,

                // Icono de flecha más moderno
                icon: const Icon(Icons.arrow_drop_down_circle_outlined,
                    color: Color(0xFF84A756)),

                // Estilo del texto seleccionado
                style: const TextStyle(color: Colors.black87, fontSize: 16),

                // Elevación y color del menú desplegable
                dropdownColor: Colors.white,
                elevation: 8,
                borderRadius:
                    BorderRadius.circular(15), // Bordes redondeados en el menú

                decoration: InputDecoration(
                  labelText: 'Concepto de Gasto *',
                  labelStyle: const TextStyle(color: Color(0xFF2C522A)),
                  prefixIcon: const Icon(Icons.category_outlined,
                      color: Color(0xFF84A756)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

                  // Bordes más suaves y profesionales
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFF2C522A), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),

                // Mejorando el diseño de cada item en la lista
                items: vm.availableConcepts.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          c.concept,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                onChanged: (val) {
                  setState(() => _selectedConceptId = val);
                  vm.clearError();
                },
                validator: (value) =>
                    value == null ? 'Selecciona un concepto' : null,
              ),
              const SizedBox(height: 15),

              // 2. Importe
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(
                    'Importe *', Icons.monetization_on_outlined),
                onChanged: (_) {
                  if (vm.errorMessage != null) vm.clearError?.call();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa el monto';
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) return 'Monto inválido';
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

              // 4. Cámara Uniforme
              _buildCameraSection(vm),

              const SizedBox(height: 25),

              // 5. Botón
              _buildSubmitButton(vm),
            ],
          ),
        ),
      ),
    );
  }

  // Banner específico para mostrar errores del Backend
  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade900, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSection(TravelExpensesViewModel vm) {
    final bool hasImage = vm.selectedImage != null;
    final bool showError = _triedSubmit && !hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Evidencia *',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: showError ? Colors.red : Colors.black87)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (vm.errorMessage != null) vm.clearError?.call();
            vm.pickImage();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: showError ? Colors.red[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: showError
                      ? Colors.red
                      : (hasImage
                          ? const Color(0xFF84A756)
                          : Colors.grey[400]!),
                  width: showError ? 2 : 1),
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
                        Text(showError ? 'Foto Requerida' : 'Tomar Foto',
                            style: TextStyle(
                                color: showError ? Colors.red : Colors.grey,
                                fontWeight: showError
                                    ? FontWeight.bold
                                    : FontWeight.normal))
                      ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(TravelExpensesViewModel vm) {
    final bool isLoading = vm.status == TravelExpensesStatus.loading;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C522A),
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: isLoading
          ? null
          : () async {
              setState(() => _triedSubmit = true);
              if (!_formKey.currentState!.validate() ||
                  vm.selectedImage == null) return;

              final success = await vm.saveExpense(
                serviceId: widget.serviceId,
                conceptId: _selectedConceptId!,
                amount: double.parse(_amountController.text),
                comments: _commentController.text,
              );

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Comprobación enviada correctamente'),
                  backgroundColor: Colors.green,
                ));
              }
            },
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : const Text('Enviar Comprobación',
              style: TextStyle(color: Colors.white)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF84A756)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF2C522A), width: 2)),
    );
  }
}
