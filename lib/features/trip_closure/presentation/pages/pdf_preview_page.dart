import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/trip_closure/presentation/viewmodels/trip_closure_viewmodel.dart';

class PdfPreviewPage extends StatelessWidget {
  const PdfPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TripClosureViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'PDF generado (${vm.images.length} imágenes)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              // onPressed: vm.isSending
              //     ? null
              //     : () async {
              //         final ok = await vm.send();
              //         if (ok && context.mounted) {
              //           vm.clear();
              //           Navigator.popUntil(
              //             context,
              //             (r) => r.isFirst,
              //           );
              //         }
              //       },
              onPressed: null,
              child: const Text('Enviar cierre de viaje'),
            ),
          ),
        ],
      ),
    );
  }
}
