import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/features/evidence/presentation/providers/evidence_provider.dart';
import 'package:segadi/features/evidence/presentation/viewmodels/delivery_evidence_view_model.dart';
import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';

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
  final Color primaryGreen = const Color(0xFF2C522A);

  final TextEditingController _notesController = TextEditingController();

  bool _initialized = false;
  bool _sending = false;

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

  // @override
  // void dispose() {
  //   _notesController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(
      deliveryEvidenceViewModelProvider,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Evidencias de entrega',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    DeliveryEvidenceViewModel vm,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  'Documentos de evidencia',
                ),
                _buildScannerSection(vm),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                  ),
                ),
                _buildSectionTitle('Notas'),
                _buildNotesField(vm),
                const SizedBox(height: 30),
                _buildSubmitButton(vm),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryGreen,
            radius: 18,
            child: const Icon(
              Icons.document_scanner_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROCESO DE ENTREGA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  'Remisión - ${widget.arguments.serviceNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildScannerSection(
    DeliveryEvidenceViewModel vm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${vm.evidenceCount}/${DeliveryEvidenceViewModel.maxEvidences} evidencias',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              'Máximo 5',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildScanButton(vm),
        const SizedBox(height: 16),
        if (vm.hasEvidences) _buildEvidenceList(vm) else _buildEmptyEvidence(),
      ],
    );
  }

  Widget _buildScanButton(
    DeliveryEvidenceViewModel vm,
  ) {
    final enabled =
        vm.canScanMore && !vm.isScanning && !vm.isSending && !_sending;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: enabled ? () => _scanEvidence() : null,
        icon: vm.isScanning
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.document_scanner_outlined,
              ),
        label: Text(
          vm.isScanning
              ? 'Abriendo escáner...'
              : vm.canScanMore
                  ? 'Escanear evidencia'
                  : 'Máximo de evidencias alcanzado',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: BorderSide(
            color: primaryGreen,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEvidence() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 42,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 10),
          Text(
            'Aún no hay evidencias',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Escanea al menos un documento para continuar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceList(
    DeliveryEvidenceViewModel vm,
  ) {
    return Column(
      children: List.generate(
        vm.evidences.length,
        (index) {
          final evidence = vm.evidences[index];

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: _buildEvidenceItem(
              vm,
              index,
              evidence,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEvidenceItem(
    DeliveryEvidenceViewModel vm,
    int index,
    List<String> pages,
  ) {
    final firstPage = pages.isNotEmpty ? pages.first : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: firstPage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(firstPage),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.description,
                          color: primaryGreen,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.description,
                    color: primaryGreen,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pages.length == 1 ? '1 página' : '${pages.length} páginas',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: vm.isSending || vm.isScanning || _sending
                ? null
                : () => _removeEvidence(index),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField(
    DeliveryEvidenceViewModel vm,
  ) {
    return TextField(
      controller: _notesController,
      enabled: !vm.isSending && !_sending,
      maxLines: 4,
      onChanged: vm.updateNotes,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Agrega alguna observación...',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 8,
            bottom: 48,
          ),
          child: Icon(
            Icons.notes_outlined,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

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
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: _sending || vm.isSending
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                canSubmit ? 'Continuar' : 'Agrega al menos una evidencia',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

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
      _showError(vm.errorMessage!);
    }
  }

  Future<void> _removeEvidence(
    int index,
  ) async {
    final vm = ref.read(
      deliveryEvidenceViewModelProvider,
    );

    await vm.removeEvidence(index);
  }

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

    /*
     * Regresamos al ServiceDetailPage.
     *
     * El detalle será responsable de refrescar el
     * servicio y comprobar nuevamente los flags.
     */
    context.pop(true);
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );

    ref
        .read(
          deliveryEvidenceViewModelProvider,
        )
        .clearError();
  }
}
