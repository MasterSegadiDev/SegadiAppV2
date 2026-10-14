import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/travel_expense_concept.dart';
import '../providers/travel_expenses_provider.dart';
import 'dart:io';

class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  final String requestId;
  final TravelExpenseConcept concept;
  const AddExpenseBottomSheet(
      {super.key, required this.requestId, required this.concept});

  @override
  ConsumerState<AddExpenseBottomSheet> createState() =>
      _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _comments = TextEditingController();
  XFile? _image;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _comments.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _image = image;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() => _error = 'No se pudo seleccionar la imagen: $e');
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
      _amount.text.trim().replaceAll(',', '.'),
    );

    if (amount == null || !amount.isFinite || amount <= 0) {
      setState(() {
        _error = 'Ingresa un importe válido mayor a cero.';
      });
      return;
    }

    if (amount > widget.concept.amount) {
      setState(() {
        _error = 'El importe utilizado no puede superar '
            'el importe autorizado de '
            '\$${widget.concept.amount.toStringAsFixed(2)}.';
      });
      return;
    }

    // El POST requiere una imagen obligatoriamente.
    if (_image == null) {
      setState(() {
        _error = 'Adjunta una fotografía del comprobante.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(registerTravelExpenseUseCaseProvider).call(
            referralId: widget.requestId,
            travelExpenseId: widget.concept.id,
            amount: amount,
            authorizedAmount: widget.concept.amount,
            evidencePath: _image!.path,
          );

      ref.invalidate(
        travelExpenseConceptsProvider(widget.requestId),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
            top: false,
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                            child: Container(
                                width: 42,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE0E0DA),
                                    borderRadius: BorderRadius.circular(4)))),
                        const SizedBox(height: 18),
                        Text('Registrar ${widget.concept.concept}',
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF101812))),
                        const SizedBox(height: 6),
                        Text(
                            'Importe máximo: \$${widget.concept.amount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFF6B6B66))),
                        const SizedBox(height: 18),
                        TextFormField(
                            controller: _amount,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                                labelText: 'Importe',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder()),
                            validator: (value) {
                              final n = double.tryParse(
                                  (value ?? '').replaceAll(',', '.'));
                              if (n == null || !n.isFinite || n <= 0)
                                return 'Ingresa un importe válido';
                              if (n > widget.concept.amount)
                                return 'Máximo: \$${widget.concept.amount.toStringAsFixed(2)}';
                              return null;
                            }),
                        const SizedBox(height: 12),
                        TextFormField(
                            controller: _comments,
                            maxLines: 2,
                            decoration: const InputDecoration(
                                labelText: 'Observaciones (opcional)',
                                border: OutlineInputBorder())),
                        const SizedBox(height: 16),
                        Text(
                            widget.concept.evidenceRequired
                                ? 'Comprobante obligatorio'
                                : 'Comprobante opcional',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        if (_image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_image!.path),
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        Row(children: [
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text('Cámara'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _pickImage(ImageSource.gallery),
                                  icon:
                                      const Icon(Icons.photo_library_outlined),
                                  label: const Text('Galería'))),
                        ]),
                        if (_error != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(_error!,
                                  style: const TextStyle(
                                      color: Color(0xFFB23A3A)))),
                        const SizedBox(height: 16),
                        SizedBox(
                            height: 50,
                            child: ElevatedButton(
                                onPressed: _saving ? null : _save,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E7A3C),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: _saving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : const Text('Guardar comprobación'))),
                      ])),
            ))),
      );
}
