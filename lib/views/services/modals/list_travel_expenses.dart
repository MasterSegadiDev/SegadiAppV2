import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/travel_expenses.dart';
import 'dart:io';

class ListTravelExpensesView extends StatelessWidget {
  const ListTravelExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelExpensesViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(viewModel),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Agrega un comentario',
                controller: viewModel.textController1,
                onChanged: (v) => viewModel.comentary = v,
                minLines: 4,
                maxLines: 250,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Agrega un importe a registrar',
                controller: viewModel.textController,
                onChanged: (v) => viewModel.import = v,
                inputType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Nombre de la evidencia',
                controller: viewModel.evidenceNameController,
                onChanged: (v) => viewModel.name = v,
              ),
              const SizedBox(height: 10),
              _buildImageSection(viewModel),
              const SizedBox(height: 20),
              _buildSubmitButton(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown(TravelExpensesViewModel viewModel) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Selecciona un concepto',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: const Text('Selecciona un concepto'),
      items: viewModel.items.map((e) {
        return DropdownMenuItem(
          value: e.id,
          child: Text('${e.paymentConcept}  \$${e.paymentTotal}'),
        );
      }).toList(),
      onChanged: (value) => viewModel.concetId = value!,
      isDense: true,
      isExpanded: true,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    void Function(String)? onChanged,
    TextInputType? inputType,
    int? minLines,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: inputType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildImageSection(TravelExpensesViewModel viewModel) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: viewModel.pickImageFromCamera,
          icon: const Icon(Icons.camera_alt),
          label: Text(
            viewModel.selectedImage == null ? 'Tomar foto' : 'Cambiar foto',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        const SizedBox(width: 10),
        viewModel.selectedImage != null
            ? GestureDetector(
                onTap: viewModel.pickImageFromCamera,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(viewModel.selectedImage!.path),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : const Text("No hay imagen"),
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, TravelExpensesViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () async {
          await viewModel.insertImport();

          if (viewModel.errorMessage != null) {
            showDialog(
              context: context,
              builder: (_) =>
                  AlertDialog(content: Text(viewModel.errorMessage!)),
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C522A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text('Agregar', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
