import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence/presentation/pages/capture_evidence_page.dart';
import 'package:segadi/features/evidence/presentation/pages/pdf_preview_page.dart';
import 'package:segadi/features/evidence/presentation/viewmodel/evidence_flow_viewmodel.dart';
import 'package:signature/signature.dart';

class ConfirmEvidencePage extends StatefulWidget {
  const ConfirmEvidencePage({super.key});

  @override
  State<ConfirmEvidencePage> createState() => _ConfirmEvidencePageState();
}

class _ConfirmEvidencePageState extends State<ConfirmEvidencePage> {
  late SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _onSignatureEnd(EvidenceFlowViewModel vm) async {
    if (_signatureController.isEmpty) return;

    final bytes = await _signatureController.toPngBytes();
    if (bytes != null && bytes.isNotEmpty) {
      vm.updateSignature(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceFlowViewModel>();

    final date = DateFormat('yyyy-MM-dd').format(vm.confirmationDate);
    final time = DateFormat('HH:mm').format(vm.confirmationDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmar Evidencias"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C522A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// 🔹 INFO
            Text(
              "Remisión: ${vm.id}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Estás confirmando ${vm.evidences.length} evidencias",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            /// 🔹 EVIDENCIAS (VISUAL)
            if (vm.evidences.isNotEmpty) ...[
              const Text(
                "Evidencias capturadas",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.evidences.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final evidence = vm.evidences[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        evidence.bytes,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            /// 🔹 NOMBRE
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre del receptor',
                border: OutlineInputBorder(),
              ),
              onChanged: vm.updateReceiverName,
            ),

            const SizedBox(height: 16),

            /// 🔹 FECHA / HORA
            Row(
              children: [
                Expanded(child: _readonlyBox(date)),
                const SizedBox(width: 12),
                Expanded(child: _readonlyBox(time)),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 FIRMA
            const Text(
              "Firmar para confirmar:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Listener(
              onPointerUp: (_) => _onSignatureEnd(vm),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Signature(
                  controller: _signatureController,
                  height: 200,
                  backgroundColor: Colors.grey[200]!,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _signatureController.clear();
                  vm.saveSignature(Uint8List(0));
                },
                icon: const Icon(Icons.clear),
                label: const Text("Limpiar firma"),
              ),
            ),

            const SizedBox(height: 24),

            /// 🔹 CONTINUAR
            ElevatedButton.icon(
              onPressed: vm.isConfirmationValid
                  ? () async {
                      final bytes = await _signatureController.toPngBytes();
                      if (bytes == null || bytes.isEmpty) return;

                      vm.updateSignature(bytes);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            //child: const PdfPreviewPage(),
                            child: const CaptureEvidencePage(),
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Continuar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _readonlyBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}
