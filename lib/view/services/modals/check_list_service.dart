import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/view_model/services_operator/detail_service.dart';

class CheckListView extends StatefulWidget {
  const CheckListView({super.key});

  @override
  State<CheckListView> createState() => _CheckListView();
}

class _CheckListView extends State<CheckListView> {
  @override
  Widget build(BuildContext context) {
    Provider.of<DetailViewModel>(context, listen: false).fetchItems();
    final checkVieModel = Provider.of<DetailViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Puntos de revisión'),
      ),
      body: Consumer<DetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.items.isEmpty) {
            return Center(
              child: Text('No items in the checklist.'),
            );
          } else {
            return ListView.builder(
              itemCount: viewModel.items.length,
              itemBuilder: (context, index) {
                final item = viewModel.items[index];
                return CheckboxListTile(
                  title: Text(item.option.toString()),
                  value: item.isChecked,
                  onChanged: (value) {
                    viewModel.toggleItem(index, item.id!.toInt());
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: FloatingActionButton.small(
        backgroundColor: const Color(0xFF2C522A),
        child: Text(
          'Guardar',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          await checkVieModel.save();

          if (checkVieModel.errorMessage != null) {
            return showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  //title: ,
                  insetPadding: const EdgeInsets.all(20),
                  content: Text('${checkVieModel.errorMessage}'),
                );
              },
            );
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
