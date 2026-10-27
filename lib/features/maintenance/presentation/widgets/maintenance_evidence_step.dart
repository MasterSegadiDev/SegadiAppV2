import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MaintenanceEvidenceStep extends StatelessWidget {
  const MaintenanceEvidenceStep({
    super.key,
    required this.vehicleNumber,
    required this.description,
    required this.priority,
    required this.evidence,
    required this.onEvidenceChanged,
  });

  final String vehicleNumber;
  final String description;
  final String priority;
  final XFile? evidence;
  final ValueChanged<XFile?> onEvidenceChanged;

  static const green = Color(0xFF1E7A3C);
  static const dark = Color(0xFF101812);
  static const secondary = Color(0xFF6B6B66);

  Future<void> _pickImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (image != null) {
        onEvidenceChanged(image);
      }
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible seleccionar la imagen: $error',
          ),
        ),
      );
    }
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: green,
                  ),
                  title: const Text('Tomar fotografía'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: green,
                  ),
                  title: const Text('Elegir de galería'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E0DA),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evidencia fotográfica',
                style: TextStyle(
                  color: dark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega una fotografía donde '
                'se pueda identificar la falla.',
                style: TextStyle(
                  color: secondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              if (evidence != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(evidence!.path),
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _showImageOptions(context),
                  icon: Icon(
                    evidence == null
                        ? Icons.add_a_photo_outlined
                        : Icons.refresh,
                  ),
                  label: Text(
                    evidence == null
                        ? 'Agregar fotografía'
                        : 'Cambiar fotografía',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: green,
                    side: const BorderSide(color: green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (evidence != null)
                TextButton.icon(
                  onPressed: () => onEvidenceChanged(null),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar fotografía'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E0DA),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen del reporte',
                style: TextStyle(
                  color: dark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _row('Unidad', vehicleNumber),
              const SizedBox(height: 12),
              _row('Prioridad', priority),
              const SizedBox(height: 12),
              _row('Descripción', description),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: secondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? 'No especificado' : value,
          style: const TextStyle(
            color: dark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
