import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';

class CheckListView extends StatefulWidget {
  const CheckListView({super.key});

  @override
  State<CheckListView> createState() => _CheckListView();
}

class _CheckListView extends State<CheckListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<DetailViewModel>(context, listen: false).fetchItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkViewModel = Provider.of<DetailViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos de revisión'),
        backgroundColor: const Color(0xFF2C522A),
        foregroundColor: Colors.white,
      ),
      body: Consumer<DetailViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.items.isEmpty) {
            return const Center(child: Text('No hay puntos de revisión.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = viewModel.items[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: CheckboxListTile(
                  title: Text(item.option ?? '',
                      style: const TextStyle(fontSize: 16)),
                  value: item.isChecked,
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: const Color(0xFF2C522A),
                  onChanged: (value) {
                    viewModel.toggleItem(index, item.id!.toInt());
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text('Guardar', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C522A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () async {
            await checkViewModel.save();
            if (checkViewModel.errorMessage != null) {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(checkViewModel.errorMessage!),
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
