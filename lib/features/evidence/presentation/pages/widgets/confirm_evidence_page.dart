import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:segadi/features/evidence/presentation/providers/confirmation_provider.dart';
import 'package:segadi/features/evidence/presentation/viewmodels/delivery_confirmation_view_model.dart';
import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';
import 'package:signature/signature.dart';

class ConfirmEvidencePage extends ConsumerStatefulWidget {
  final ServiceDetailArguments arguments;

  const ConfirmEvidencePage({
    super.key,
    required this.arguments,
  });

  @override
  ConsumerState<ConfirmEvidencePage> createState() =>
      _ConfirmEvidencePageState();
}

class _ConfirmEvidencePageState extends ConsumerState<ConfirmEvidencePage> {
  late final SignatureController _signatureController;

  final Color primaryGreen = const Color(0xFF2C522A);

  final TextEditingController _receiverController = TextEditingController();

  bool _initialized = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();

    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    _signatureController.addListener(_onSignatureChanged);

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
      deliveryConfirmationViewModelProvider,
    );

    final now = DateTime.now();

    final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    vm.initialize(
      serviceRequestId: widget.arguments.idSolicitud,
    );

    vm.updateDateTime(formattedDateTime);
  }

  void _onSignatureChanged() {
    if (!mounted) {
      return;
    }

    final vm = ref.read(
      deliveryConfirmationViewModelProvider,
    );

    if (_signatureController.isEmpty) {
      if (vm.hasSignature) {
        vm.updateSignature(null);
      }
    } else {
      if (!vm.hasSignature) {
        vm.updateSignature(
          Uint8List.fromList([1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _signatureController.removeListener(
      _onSignatureChanged,
    );

    _signatureController.dispose();
    _receiverController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(
      deliveryConfirmationViewModelProvider,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Confirmación de entrega',
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
    DeliveryConfirmationViewModel vm,
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
                  'Datos del receptor',
                ),
                _buildReceiverForm(vm),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                  ),
                ),
                _buildSectionTitle(
                  'Firma de conformidad',
                ),
                _buildSignaturePad(),
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
              Icons.assignment_turned_in_outlined,
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

  Widget _buildReceiverForm(
    DeliveryConfirmationViewModel vm,
  ) {
    final date = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());

    final time = DateFormat(
      'HH:mm',
    ).format(DateTime.now());

    return Column(
      children: [
        TextField(
          controller: _receiverController,
          onChanged: vm.updateReceiverName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nombre de quien recibe',
            prefixIcon: Icon(
              Icons.person_outline,
              color: primaryGreen,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            isDense: true,
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _infoBox(
                'Fecha',
                date,
                Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _infoBox(
                'Hora',
                time,
                Icons.access_time,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoBox(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Signature(
              controller: _signatureController,
              height: 180,
              backgroundColor: Colors.transparent,
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey[200],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  'Firma aquí',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _sending ? null : _clearSignature,
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  size: 18,
                ),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearSignature() {
    _signatureController.clear();

    final vm = ref.read(
      deliveryConfirmationViewModelProvider,
    );

    vm.updateSignature(null);
  }

  Widget _buildSubmitButton(
    DeliveryConfirmationViewModel vm,
  ) {
    final canSubmit = vm.receiverName.trim().length >= 3 &&
        !_signatureController.isEmpty &&
        !_sending;

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
        child: _sending
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                canSubmit ? 'Continuar' : 'Falta el nombre o la firma',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _processSubmission() async {
    if (_sending) {
      return;
    }

    final Uint8List? signatureBytes = await _signatureController.toPngBytes();

    if (!mounted) {
      return;
    }

    if (signatureBytes == null || signatureBytes.isEmpty) {
      _showError(
        'Por favor, realiza la firma correctamente.',
      );
      return;
    }

    final vm = ref.read(
      deliveryConfirmationViewModelProvider,
    );

    vm.updateSignature(signatureBytes);

    setState(() {
      _sending = true;
    });

    final success = await vm.sendConfirmation();

    if (!mounted) {
      return;
    }

    if (!success) {
      setState(() {
        _sending = false;
      });

      _showError(
        vm.errorMessage ?? 'No se pudo enviar la confirmación.',
      );

      return;
    }

    /*
     * Regresamos al ServiceDetailPage.
     *
     * El detalle será responsable de refrescar el servicio
     * y decidir si debe abrir CaptureEvidencePage.
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
          deliveryConfirmationViewModelProvider,
        )
        .clearError();
  }
}
