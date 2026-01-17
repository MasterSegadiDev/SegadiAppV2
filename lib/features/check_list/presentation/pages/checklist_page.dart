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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ChecklistViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChecklistViewModel>();

    return Material(
      // 🔥 SOLUCIÓN AL ERROR
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // LISTADO
            Expanded(
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: vm.items.length,
                      itemBuilder: (_, index) {
                        final item = vm.items[index];
                        return CheckboxListTile(
                          title: Text(item.option),
                          value: item.checked,
                          onChanged: (_) => vm.toggle(item.id),
                          activeColor: const Color(0xFF52634F),
                        );
                      },
                    ),
            ),

            // BOTÓN GUARDAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoButton.filled(
                onPressed: vm.isValid
                    ? () async {
                        final ok = await vm.save();
                        if (ok && mounted) {
                          Navigator.pop(context, true);
                        }
                      }
                    : null,
                child: const Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
