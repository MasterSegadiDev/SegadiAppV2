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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetailViewModel>(context, listen: false).fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<DetailViewModel>(
        builder: (context, viewModel, _) => _buildChecklist(viewModel),
      ),
      bottomNavigationBar: Consumer<DetailViewModel>(
        builder: (context, viewModel, _) => _buildSaveButton(viewModel),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Puntos de revisión'),
      backgroundColor: const Color(0xFF2C522A),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildChecklist(DetailViewModel viewModel) {
    if (viewModel.items.isEmpty) {
      return const Center(child: Text('No hay puntos de revisión.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = viewModel.items[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: CheckboxListTile(
            title:
                Text(item.option ?? '', style: const TextStyle(fontSize: 16)),
            value: item.isChecked,
            controlAffinity: ListTileControlAffinity.trailing,
            activeColor: const Color(0xFF2C522A),
            onChanged: (_) => viewModel.toggleItem(index, item.id!.toInt()),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(DetailViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Guardar Check List',
            style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C522A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: viewModel.isSaving
            ? null
            : () async {
                await viewModel.save();

                if (viewModel.errorMessage != null) {
                  if (context.mounted) {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: Text(viewModel.errorMessage!),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checklist registrado con éxito'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              },
      ),
    );
  }
}
