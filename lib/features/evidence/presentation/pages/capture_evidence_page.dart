import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence/presentation/pages/pdf_preview_page.dart';
import 'package:segadi/features/evidence/presentation/viewmodel/evidence_flow_viewmodel.dart';

// class CaptureEvidencePage extends StatelessWidget {
//   const CaptureEvidencePage({super.key});
//   final Color primaryGreen = const Color(0xFF2C522A);

class CaptureEvidencePage extends StatefulWidget {
  const CaptureEvidencePage({super.key});

  @override
  State<CaptureEvidencePage> createState() => _CaptureEvidencePageState();
}

class _CaptureEvidencePageState extends State<CaptureEvidencePage> {
  final Color primaryGreen = const Color(0xFF2C522A);

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _cleanupResources() {
    final vm = context.read<EvidenceFlowViewModel>();
    Future.microtask(() => vm.initCaptureFlow());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceFlowViewModel>();

    final width = MediaQuery.of(context).size.width;
    final responsiveFontSize = width * 0.030;

    /// 🔹 Mostrar error si existe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.status == EvidenceFlowStatus.error && vm.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Enviar Evidencias',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              /// 🔹 GRID DE EVIDENCIAS
              Expanded(
                child: vm.evidences.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: vm.evidences.length,
                        itemBuilder: (_, index) {
                          final evidence = vm.evidences[index];

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  evidence.bytes,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => vm.removeEvidence(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              /// 🔹 LOADING
              if (vm.status == EvidenceFlowStatus.scanning)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: CircularProgressIndicator(),
                ),

              /// 🔹 BOTONES
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    /// ESCANEAR
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: vm.canScanMore &&
                                vm.status != EvidenceFlowStatus.scanning
                            ? vm.scanFromCamera
                            : null,
                        icon: Icon(
                          Icons.document_scanner,
                          size: responsiveFontSize + 4,
                        ),
                        label: Text(
                          vm.canScanMore ? "Escanear" : "Límite alcanzado",
                          style: TextStyle(fontSize: responsiveFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// CONTINUAR
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: vm.hasEvidences
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: vm,
                                      child: const PdfPreviewPage(),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: Icon(
                          Icons.arrow_forward,
                          size: responsiveFontSize + 4,
                        ),
                        label: Text(
                          "Continuar",
                          style: TextStyle(fontSize: responsiveFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: vm.hasEvidences
                              ? primaryGreen
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 EMPTY STATE
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.document_scanner_outlined,
          size: 70,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 10),
        const Text(
          "No se han capturado evidencias aún",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        const Text(
          "Escanea documentos para continuar",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
