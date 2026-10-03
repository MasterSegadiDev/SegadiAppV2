import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:segadi/features/evidence/presentation/providers/confirmation_provider.dart';
import 'package:segadi/features/evidence/presentation/viewmodels/delivery_confirmation_view_model.dart';
import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';
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

  final TextEditingController _receiverController = TextEditingController();

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

    final formattedDateTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(now);

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(
      deliveryConfirmationViewModelProvider,
    );

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Confirmación de entrega',
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
                icon: Icons.person_outline,
                title: 'Datos del receptor',
              ),
              const SizedBox(height: 10),
              _buildReceiverCard(vm),
              const SizedBox(height: 26),
              _buildSectionTitle(
                icon: Icons.draw_outlined,
                title: 'Firma de conformidad',
              ),
              const SizedBox(height: 10),
              _buildSignatureCard(),
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
                    Icons.assignment_turned_in_outlined,
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
  // RECEIVER CARD
  // ============================================================

  Widget _buildReceiverCard(
    DeliveryConfirmationViewModel vm,
  ) {
    final date = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());

    final time = DateFormat(
      'HH:mm',
    ).format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nombre de quien recibe',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: _receiverController,
            onChanged: vm.updateReceiverName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Ingresa el nombre completo',
              hintStyle: const TextStyle(
                color: _textMuted,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.person_outline,
                color: _primaryGreen,
                size: 20,
              ),
              filled: true,
              fillColor: _background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoBox(
                  'Fecha',
                  date,
                  Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoBox(
                  'Hora',
                  time,
                  Icons.access_time_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================

  Widget _infoBox(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _primaryGreenSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 15,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIGNATURE
  // ============================================================

  Widget _buildSignatureCard() {
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
                    Icons.gesture_outlined,
                    size: 17,
                    color: _primaryGreen,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Firma dentro del recuadro',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Signature(
              controller: _signatureController,
              height: 190,
              backgroundColor: Colors.white,
            ),
            const Divider(
              height: 1,
              color: _border,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Firma de conformidad',
                      style: TextStyle(
                        fontSize: 11,
                        color: _textMuted,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _sending ? null : _clearSignature,
                    style: TextButton.styleFrom(
                      foregroundColor: _errorRed,
                    ),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 17,
                    ),
                    label: const Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
  // SUBMIT
  // ============================================================

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
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _border,
          disabledForegroundColor: _textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _sending
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
                        ? Icons.arrow_forward_rounded
                        : Icons.edit_outlined,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canSubmit ? 'Continuar' : 'Completa el nombre y la firma',
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
  // ACTIONS
  // ============================================================

  void _clearSignature() {
    _signatureController.clear();

    final vm = ref.read(
      deliveryConfirmationViewModelProvider,
    );

    vm.updateSignature(null);
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
          deliveryConfirmationViewModelProvider,
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
