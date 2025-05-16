import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/messages.dart';
import 'package:segadi/views/services/modals/list_travel_expenses.dart';
import 'package:segadi/viewmodels/services_operator/travel_expenses.dart';

class TravelExpensesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final travelExpensesViewModel =
        Provider.of<TravelExpensesViewModel>(context);

    // Inicializar totalImport
    double totalImport = 0;

    // Sumar los importes de cada elemento de la lista
    for (var e in travelExpensesViewModel.tableItems) {
      totalImport += double.tryParse(e.totalUsed.toString()) ?? 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viáticos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C522A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            await travelExpensesViewModel.fetchItemsTravelExpenses(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Agregar conceptos',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C522A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                await travelExpensesViewModel.fetchItemsTravelExpenses();
                travelExpensesViewModel.bandera
                    ? _showBottomSheet(context)
                    : scaffoldMessengerError(context,
                        'Por el momento no tienes viáticos asignados.');
              },
            ),
            const Divider(height: 32, thickness: 1),
            Center(
              child: Text(
                'Importe Total: ${totalImport.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ...travelExpensesViewModel.tableItems.map((e) {
              double result = double.tryParse(e.totalUsed.toString()) ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF84A756), width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    e.paymentConcept ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text('Importe registrado: \$${e.totalUsed.toString()}'),
                  trailing: e.image == 1
                      ? IconButton(
                          icon: const Icon(Icons.image, color: Colors.green),
                          onPressed: () =>
                              showImageModal(context, e.id.toString()),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image_not_supported, color: Colors.red),
                            Text('Sin imagen', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.phone, color: Colors.white),
        onPressed: () {
          FlutterPhoneDirectCaller.callNumber('+523311364928');
        },
      ),
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (ctx) => ListTravelExpensesView(),
  );
}

void showImageModal(BuildContext context, String conceptId) async {
  final travelExpensesViewModel =
      Provider.of<TravelExpensesViewModel>(context, listen: false);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  Uint8List? imageBytes =
      await travelExpensesViewModel.fetchEvidenceImage(conceptId);
  Navigator.pop(context);

  showDialog(
    context: context,
    builder: (context) {
      if (imageBytes != null) {
        return AlertDialog(
          title: const Text('Evidencia'),
          content: Image.memory(imageBytes),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      } else {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('No se pudo cargar la imagen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      }
    },
  );
}
