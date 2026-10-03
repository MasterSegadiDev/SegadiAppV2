import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/features/evidence/presentation/providers/evidence_provider.dart';
import 'package:segadi/features/evidence/presentation/viewmodels/delivery_evidence_view_model.dart';
import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';

class CaptureEvidencePage extends ConsumerStatefulWidget {
  final ServiceDetailArguments arguments;

  const CaptureEvidencePage({
    super.key,
    required this.arguments,
  });

  @override
  ConsumerState<CaptureEvidencePage> createState() =>
      _CaptureEvidencePageState();
}

class _CaptureEvidencePageState extends ConsumerState<CaptureEvidencePage> {
  final TextEditingController _notesController = TextEditingController();

  bool _initialized = false;
  bool _sending = false;

  // ============================================================
  // COLORES
  // ============================================================

  static const _background = Color(0xFFF7F8F6);
  static const _surfaceDark = Color(0xFF101812);

  static const _primaryGreen = Color(0xFF1E7A3C);
  static const _primaryGreenSoft = Color(0xFFE1F0E3);

  static const _textPrimary = Color(0xFF101812);
  static const _textSecondary = Color(0xFF6B6B66);
  static const _textMuted = Color(0xFF9A9A94);

  static const _border = Color(0xFFE0E0DA);
  static const _errorRed = Color(0xFFB23A3A);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _initialize();
    });
  }

  void _initialize() {
    if (_initialized) {
      return;
    }

    _initialized = true;

    final vm = ref.read(
      deliveryEvidenceViewModelProvider,
    );

    vm.initialize(
      serviceRequestId: widget.arguments.idSolicitud,
      referralId: widget.arguments.idRemision,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(
      deliveryEvidenceViewModelProvider,
    );

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Evidencias de entrega',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 26),
              _buildSectionTitle(
                icon: Icons.document_scanner_outlined,
                title: 'Documentos de evidencia',
              ),
              const SizedBox(height: 10),
              _buildEvidenceCard(vm),
              const SizedBox(height: 26),
              _buildSectionTitle(
                icon: Icons.notes_outlined,
                title: 'Observaciones',
              ),
              const SizedBox(height: 10),
              _buildNotesCard(vm),
              const SizedBox(height: 24),
              _buildSubmitButton(vm),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              color: _primaryGreenSoft,
              child: const Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: _primaryGreen,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'PROCESO DE ENTREGA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                      color: _surfaceDark,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _primaryGreenSoft,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: _primaryGreen,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remisión',
                          style: TextStyle(
                            fontSize: 11,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.arguments.serviceNumber,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _primaryGreenSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: _primaryGreen,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EVIDENCE CARD
  // ============================================================

  Widget _buildEvidenceCard(
    DeliveryEvidenceViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evidencias agregadas',
                      style: TextStyle(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Documentos de entrega',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _primaryGreenSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${vm.evidenceCount}/'
                  '${DeliveryEvidenceViewModel.maxEvidences}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScanButton(vm),
          const SizedBox(height: 16),
          if (vm.hasEvidences)
            _buildEvidenceList(vm)
          else
            _buildEmptyEvidence(),
        ],
      ),
    );
  }

  // ============================================================
  // SCAN BUTTON
  // ============================================================

  Widget _buildScanButton(
    DeliveryEvidenceViewModel vm,
  ) {
    final enabled =
        vm.canScanMore && !vm.isScanning && !vm.isSending && !_sending;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: enabled ? _scanEvidence : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryGreen,
          disabledForegroundColor: _textMuted,
          side: BorderSide(
            color: enabled ? _primaryGreen : _border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: vm.isScanning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primaryGreen,
                ),
              )
            : const Icon(
                Icons.document_scanner_outlined,
                size: 19,
              ),
        label: Text(
          vm.isScanning
              ? 'Abriendo escáner...'
              : vm.canScanMore
                  ? 'Escanear evidencia'
                  : 'Máximo de evidencias alcanzado',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY EVIDENCE
  // ============================================================

  Widget _buildEmptyEvidence() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _primaryGreenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 24,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no hay evidencias',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Escanea al menos un documento para continuar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EVIDENCE LIST
  // ============================================================

  Widget _buildEvidenceList(
    DeliveryEvidenceViewModel vm,
  ) {
    return Column(
      children: List.generate(
        vm.evidences.length,
        (index) {
          return _buildEvidenceItem(
            vm,
            index,
            vm.evidences[index],
          );
        },
      ),
    );
  }

  // ============================================================
  // EVIDENCE ITEM
  // ============================================================

  Widget _buildEvidenceItem(
    DeliveryEvidenceViewModel vm,
    int index,
    List<String> pages,
  ) {
    final firstPage = pages.isNotEmpty ? pages.first : null;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _primaryGreenSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: firstPage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(firstPage),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.description_outlined,
                          color: _primaryGreen,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.description_outlined,
                    color: _primaryGreen,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evidencia ${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pages.length == 1 ? '1 página' : '${pages.length} páginas',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Eliminar evidencia',
            onPressed: vm.isSending || vm.isScanning || _sending
                ? null
                : () => _removeEvidence(index),
            style: IconButton.styleFrom(
              backgroundColor: _errorRed.withOpacity(.07),
            ),
            icon: const Icon(
              Icons.delete_outline,
              size: 19,
              color: _errorRed,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

  Widget _buildNotesCard(
    DeliveryEvidenceViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notas adicionales',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            enabled: !vm.isSending && !_sending,
            maxLines: 4,
            onChanged: vm.updateNotes,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Agrega alguna observación sobre la entrega...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: _textMuted,
              ),
              filled: true,
              fillColor: _background,
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: _border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: _primaryGreen,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Widget _buildSubmitButton(
    DeliveryEvidenceViewModel vm,
  ) {
    final canSubmit =
        vm.hasEvidences && !_sending && !vm.isScanning && !vm.isSending;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canSubmit ? _processSubmission : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _border,
          disabledForegroundColor: _textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _sending || vm.isSending
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canSubmit
                        ? Icons.check_circle_outline
                        : Icons.document_scanner_outlined,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canSubmit
                        ? 'Finalizar evidencias'
                        : 'Agrega al menos una evidencia',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // SCAN
  // ============================================================

  Future<void> _scanEvidence() async {
    if (!mounted) {
      return;
    }

    final vm = ref.read(
      deliveryEvidenceViewModelProvider,
    );

    await vm.scanEvidence();

    if (!mounted) {
      return;
    }

    if (vm.errorMessage != null) {
      _showError(
        vm.errorMessage!,
      );
    }
  }

  // ============================================================
  // REMOVE
  // ============================================================

  Future<void> _removeEvidence(
    int index,
  ) async {
    final vm = ref.read(
      deliveryEvidenceViewModelProvider,
    );

    await vm.removeEvidence(index);
  }

  // ============================================================
  // SEND
  // ============================================================

  Future<void> _processSubmission() async {
    if (_sending) {
      return;
    }

    final vm = ref.read(
      deliveryEvidenceViewModelProvider,
    );

    if (!vm.hasEvidences) {
      _showError(
        'Debes escanear al menos una evidencia.',
      );
      return;
    }

    setState(() {
      _sending = true;
    });

    final success = await vm.sendEvidences();

    if (!mounted) {
      return;
    }

    if (!success) {
      setState(() {
        _sending = false;
      });

      _showError(
        vm.errorMessage ?? 'No se pudieron enviar las evidencias.',
      );

      return;
    }

    context.pop(true);
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );

    ref
        .read(
          deliveryEvidenceViewModelProvider,
        )
        .clearError();
  }

  // ============================================================
  // DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: _surfaceDark.withOpacity(.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
