import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/check_list/presentation/viewmodels/checklist_viewmodel.dart';

class CheckListView extends StatefulWidget {
  const CheckListView({super.key});

  @override
  State<CheckListView> createState() => _CheckListViewState();
}

class _CheckListViewState extends State<CheckListView> {
  final Color primaryGreen = const Color(0xFF2C522A);
  @override
  void initState() {
    super.initState();
    // Ya no necesitas llamar a load() aquí si lo pusiste en el constructor del ViewModel,
    // pero dejarlo con microtask no hace daño para asegurar el refresco.
    Future.microtask(() => context.read<ChecklistViewModel>().load());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChecklistViewModel>();

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ÁREA DE CONTENIDO
            Expanded(
              child: _buildBody(vm),
            ),

            // BOTÓN GUARDAR (Dinámico)
            if (vm.errorMessage == null && !vm.loading && vm.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: CupertinoButton(
                  // 1. Vinculamos la habilitación al getter isValid
                  onPressed: vm.isValid
                      ? () async {
                          // 2. Ejecutamos el guardado
                          final ok = await vm.save();
                          // 3. Si el repo devuelve true, cerramos la modal
                          if (ok && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        }
                      : null, // Si no es válido, el botón se ve gris/desactivado
                  color: primaryGreen,
                  disabledColor: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(30),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                  child: vm.loading
                      ? const CupertinoActivityIndicator() // Feedback visual si está guardando
                      : const Text(
                          'Enviar',
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ChecklistViewModel vm) {
    if (vm.loading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centramos el error
            children: [
              const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                borderRadius: BorderRadius.circular(30), // Esto lo hace redondo
                onPressed: () => vm.load(),
                child: const Text(
                  "Reintentar",
                  style: TextStyle(
                    color: Colors.white, // Texto blanco
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.items.isEmpty) {
      return const Center(child: Text("No hay elementos disponibles"));
    }

    return ListView.builder(
      itemCount: vm.items.length,
      itemBuilder: (_, index) {
        final item = vm.items[index];
        return CheckboxListTile(
          title: Text(item.option),
          // subtitle: Text(
          //     "Secuencia: ${item.sequence}"), // Opcional: mostrar la secuencia
          value: item.checked,
          onChanged: (_) => vm.toggle(item.id),
          activeColor: const Color(0xFF52634F),
        );
      },
    );
  }
}
