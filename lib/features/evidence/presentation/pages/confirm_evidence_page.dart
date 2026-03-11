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

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    // Escuchamos los trazos en la firma.
    // Usamos un listener que solo notifica al VM que "hay algo",
    // sin procesar bytes pesados en cada movimiento para no saturar el rendimiento.
    _signatureController.addListener(() {
      final vm = Provider.of<EvidenceFlowViewModel>(context, listen: false);
      if (_signatureController.isNotEmpty && !vm.hasSignature) {
        // Marcamos en el VM que ya hay una firma (puedes usar un dummy byte o un bool)
        // para que el botón se active.
        vm.updateSignature(Uint8List(1));
      } else if (_signatureController.isEmpty && vm.hasSignature) {
        vm.updateSignature(null);
      }
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del ViewModel para redibujar el botón
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
            const SizedBox(height: 40),
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
          decoration: InputDecoration(
            labelText: 'Nombre del Receptor',
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
              height: 150,
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
              TextButton(
                onPressed: () {
                  _signatureController.clear();
                  vm.updateSignature(null);
                },
                child: const Text("Limpiar",
                    style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(EvidenceFlowViewModel vm) {
    // Validamos nombre y que el controlador de firma tenga algo
    bool canSubmit =
        vm.receiverName.trim().isNotEmpty && _signatureController.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 50,
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
        child: Text(canSubmit
            ? "Confirmar y capturar evidencias"
            : "Completa los datos"),
      ),
    );
  }

  Future<void> _processSubmission(EvidenceFlowViewModel vm) async {
    // 1. Extraemos los bytes reales solo al presionar el botón
    final bytes = await _signatureController.toPngBytes();

    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, firme para continuar")));
      return;
    }

    // 2. Guardamos la firma final en el ViewModel
    vm.updateSignature(bytes);
    vm.initCaptureFlow();
    // 3. NAVEGACIÓN a la siguiente pantalla (Escáner)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: vm,
            child: const CaptureEvidencePage(),
          ),
        ),
      );
    }
  }
}
