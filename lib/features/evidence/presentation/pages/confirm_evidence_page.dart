import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence/presentation/pages/capture_evidence_page.dart';
import 'package:segadi/features/evidence/presentation/viewmodel/evidence_flow_viewmodel.dart';
import 'package:signature/signature.dart';

class ConfirmEvidencePage extends StatefulWidget {
  const ConfirmEvidencePage({super.key});

  @override
  State<ConfirmEvidencePage> createState() => _ConfirmEvidencePageState();
}

class _ConfirmEvidencePageState extends State<ConfirmEvidencePage> {
  late SignatureController _signatureController;
  final Color primaryGreen = const Color(0xFF2C522A);
  late EvidenceFlowViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Obtenemos la referencia al VM
    _viewModel = context.read<EvidenceFlowViewModel>();

    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    // Listener optimizado para activar/desactivar el botón sin procesar bytes
    _signatureController.addListener(_onSignatureChanged);
  }

  void _onSignatureChanged() {
    final currentlyEmpty = _signatureController.isEmpty;
    // Solo actualizamos el VM si el estado de "vacío" cambia para evitar builds innecesarios
    if (currentlyEmpty == _viewModel.hasSignature) {
      // Usamos un byte vacío dummy para indicar presencia de firma en el VM
      _viewModel.updateSignature(currentlyEmpty ? null : Uint8List(0));
    }
  }

  @override
  void dispose() {
    _signatureController.removeListener(_onSignatureChanged);
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos cambios para redibujar el botón y campos dinámicos
    final vm = context.watch<EvidenceFlowViewModel>();
    final date = DateFormat('dd/MM/yyyy').format(vm.confirmationDate);
    final time = DateFormat('HH:mm').format(vm.confirmationDate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Confirmación de entrega',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildTopHeader(vm),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Datos del Receptor"),
                        _buildReceiverForm(vm, date, time),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        _buildSectionTitle("Firma de Conformidad"),
                        _buildSignaturePad(vm),
                        const SizedBox(height: 30),
                        _buildSubmitButton(vm),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(EvidenceFlowViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.08),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryGreen,
            radius: 18,
            child: const Icon(Icons.assignment_turned_in_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PROCESO DE CIERRE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                      letterSpacing: 1.1)),
              Text('Remisión #${vm.id}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.1)),
    );
  }

  Widget _buildReceiverForm(
      EvidenceFlowViewModel vm, String date, String time) {
    return Column(
      children: [
        TextField(
          onChanged: vm.updateReceiverName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nombre de quien recibe',
            prefixIcon: Icon(Icons.person_outline, color: primaryGreen),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
            isDense: true,
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _infoBox("Fecha", date, Icons.calendar_today)),
            const SizedBox(width: 12),
            Expanded(child: _infoBox("Hora", time, Icons.access_time)),
          ],
        ),
      ],
    );
  }

  Widget _infoBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 9, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePad(EvidenceFlowViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Signature(
              controller: _signatureController,
              height: 180, // Un poco más alto para facilitar la firma
              backgroundColor: Colors.transparent,
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text("Firma aquí",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
              TextButton.icon(
                onPressed: () {
                  _signatureController.clear();
                  vm.updateSignature(null);
                },
                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                label: const Text("Limpiar"),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(EvidenceFlowViewModel vm) {
    // Validación Senior: Nombre real y que el controller tenga trazos
    final bool canSubmit =
        vm.receiverName.trim().length >= 3 && !_signatureController.isEmpty;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _processSubmission(vm) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 0,
        ),
        child: Text(
          canSubmit ? "Continuar" : "Falta el campo nombre o la firma",
          style:
              const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Future<void> _processSubmission(EvidenceFlowViewModel vm) async {
    final Uint8List? signatureBytes = await _signatureController.toPngBytes();

    if (signatureBytes == null || signatureBytes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("⚠️ Por favor, realice la firma correctamente")),
        );
      }
      return;
    }

    vm.updateSignature(signatureBytes);
    vm.initCaptureFlow();

    if (mounted) {
      // NAVEGACIÓN NIVEL SENIOR:
      // Inyectamos la instancia existente usando .value para que la nueva ruta la encuentre
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: vm, // Pasamos el VM que ya tenemos
            child: const CaptureEvidencePage(),
          ),
        ),
      );
    }
  }
}
