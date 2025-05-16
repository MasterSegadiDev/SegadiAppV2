import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';

class StatusSupport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final detail = Provider.of<DetailViewModel>(context);

    final statusId = detail.item!.statusId;
    final type = detail.item!.type;

    Color getCardColor(int id) =>
        (statusId == id && type == 'begin') ? Colors.white : Colors.grey[200]!;
    Color getIconColor(int id) {
      if (type == '') {
        switch (id) {
          case 24:
            return Colors.blue;
          case 22:
            return Colors.orange;
          case 38:
            return Colors.black;
          case 39:
            return Colors.green;
          default:
            return Colors.white;
        }
      }
      if (statusId == id && type == 'begin') {
        switch (id) {
          case 24:
            return Colors.blue;
          case 22:
            return Colors.orange;
          case 38:
            return Colors.black;
          case 39:
            return Colors.green;
        }
      }
      return Colors.white;
    }

    Widget buildCard({
      required String label,
      required String assetPath,
      required int statusCode,
      required bool isEnabled,
    }) {
      return GestureDetector(
        onTap: isEnabled
            ? () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                await detail.changeStatusSupport(
                    statusCode, detail.item!.statusSupportModal!);

                Navigator.pop(context); // Cierra el loading
                Navigator.pop(context); // Cierra la modal
              }
            : null,
        child: Card(
          elevation: 4,
          color: getCardColor(statusCode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 50,
                height: 50,
                color: getIconColor(statusCode),
              ),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selecciona un tipo de apoyo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
            children: [
              buildCard(
                label: 'Baño',
                assetPath: "assets/images/toilet.png",
                statusCode: 24,
                isEnabled: detail.item!.isButtonEnabledBano!,
              ),
              buildCard(
                label: 'Comer',
                assetPath: "assets/images/restaurant.png",
                statusCode: 22,
                isEnabled: detail.item!.isButtonEnabledComer!,
              ),
              buildCard(
                label: 'Dormir',
                assetPath: "assets/images/sleeping.png",
                statusCode: 38,
                isEnabled: detail.item!.isButtonEnabledDormir!,
              ),
              buildCard(
                label: 'Gasolina',
                assetPath: "assets/images/gas.png",
                statusCode: 39,
                isEnabled: detail.item!.isButtonEnabledGas!,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
