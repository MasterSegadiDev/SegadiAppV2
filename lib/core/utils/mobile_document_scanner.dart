import 'dart:io';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:segadi/features/trip_closure/domain/services/document_scanner.dart';

class MobileDocumentScanner implements DocumentScanner {
  @override
  Future<Uint8List?> scan() async {
    try {
      // 1. Llamada al plugin real.
      // Retorna una lista de Strings (rutas de fotos capturadas)
      List<String>? pictures = await CunningDocumentScanner.getPictures();

      // Si el usuario canceló o no tomó fotos
      if (pictures == null || pictures.isEmpty) return null;

      // Tomamos la primera imagen (puedes ajustar si quieres procesar varias)
      final String path = pictures.first;
      final File file = File(path);

      if (await file.exists()) {
        // 2. Convertimos a bytes para almacenarlo en la RAM del ViewModel
        final Uint8List bytes = await file.readAsBytes();

        // 3. ¡LIMPIEZA SENIOR!
        // Como ya tenemos los bytes en memoria, borramos el archivo físico
        // para no dejar basura en la caché del teléfono.
        await file.delete();

        // Opcional: Borrar el resto de fotos si el scanner capturó varias por error
        for (var i = 1; i < pictures.length; i++) {
          File(pictures[i]).delete().catchError((_) {});
        }

        print("✅ Escaneo completado y archivo físico eliminado.");
        return bytes;
      }
    } catch (e) {
      print("❌ Error en MobileDocumentScanner: $e");
    }
    return null;
  }
}
