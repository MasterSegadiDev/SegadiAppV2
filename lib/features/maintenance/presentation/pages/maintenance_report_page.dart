import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/features/maintenance/presentation/widgets/maintenance_classification_step.dart';
import 'package:segadi/features/maintenance/presentation/widgets/maintenance_evidence_step.dart';
import 'package:segadi/features/maintenance/presentation/widgets/maintenance_general_info_step.dart';

class MaintenanceReportPage extends StatefulWidget {
  const MaintenanceReportPage({
    super.key,
    required this.unitId,
    required this.vehicleNumber,
  });

  final String unitId;
  final String vehicleNumber;

  @override
  State<MaintenanceReportPage> createState() => _MaintenanceReportPageState();
}

class _MaintenanceReportPageState extends State<MaintenanceReportPage> {
  static const green = Color(0xFF1E7A3C);
  static const dark = Color(0xFF101812);
  static const background = Color(0xFFF7F8F6);
  static const secondary = Color(0xFF6B6B66);

  final _generalFormKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _observationController = TextEditingController();

  int _currentStep = 0;
  DateTime _incidentDate = DateTime.now();
  bool _isUrgent = false;

  String? _priority;
  String? _classification1;
  String? _classification2;

  XFile? _evidence;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 0) {
      if (!_generalFormKey.currentState!.validate()) return;
    }

    if (_currentStep == 1) {
      if (_priority == null ||
          _classification1 == null ||
          _classification2 == null) {
        _showMessage('Es necesario seleccionar todas las clasificaciones');
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_evidence == null) {
      _showMessage('Agrega una fotografía de evidencia.');
      return;
    }

    setState(() => _submitting = true);

    try {
      // Próximo paso:
      // await getIt<CreateMaintenanceReportUseCase>().call(
      //   unitId: widget.unitId,
      //   vehicleNumber: widget.vehicleNumber,
      //   description: _descriptionController.text.trim(),
      //   observation: _observationController.text.trim(),
      //   incidentDate: _incidentDate,
      //   isUrgent: _isUrgent,
      //   priority: _priority!,
      //   classification1: _classification1!,
      //   classification2: _classification2!,
      //   evidencePath: _evidence!.path,
      // );

      // No simulamos un envío exitoso hasta conectar el API.
      _showMessage(
        'Formulario validado. Pendiente conectar Fracttal.',
      );
    } catch (error) {
      _showMessage('No se pudo registrar el reporte: $error');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Información general',
      'Clasificación',
      'Evidencia',
    ];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        title: const Text(
          'Nuevo Reporte',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paso ${_currentStep + 1} de 2',
                    style: const TextStyle(
                      color: green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    titles[_currentStep],
                    style: const TextStyle(
                      color: dark,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(2, (index) {
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(
                            right: index == 2 ? 0 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? green
                                : const Color(0xFFE0E0DA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  20,
                ),
                child: switch (_currentStep) {
                  0 => MaintenanceGeneralInfoStep(
                      formKey: _generalFormKey,
                      vehicleNumber: widget.vehicleNumber,
                      descriptionController: _descriptionController,
                      observationController: _observationController,
                      incidentDate: _incidentDate,
                      isUrgent: _isUrgent,
                      onIncidentDateChanged: (value) {
                        setState(() => _incidentDate = value);
                      },
                      onUrgentChanged: (value) {
                        setState(() => _isUrgent = value);
                      },
                    ),
                  1 => MaintenanceClassificationStep(
                      priority: _priority,
                      classification1: _classification1,
                      classification2: _classification2,
                      onPriorityChanged: (value) {
                        setState(() => _priority = value);
                      },
                      onClassification1Changed: (value) {
                        setState(
                          () => _classification1 = value,
                        );
                      },
                      onClassification2Changed: (value) {
                        setState(
                          () => _classification2 = value,
                        );
                      },
                    ),
                  _ => null
                  // MaintenanceEvidenceStep(
                  //     vehicleNumber: widget.vehicleNumber,
                  //     description: _descriptionController.text.trim(),
                  //     priority: _priority ?? '',
                  //     evidence: _evidence,
                  //     onEvidenceChanged: (value) {
                  //       setState(() => _evidence = value);
                  //     },
                  //   ),
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE0E0DA),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    OutlinedButton(
                      onPressed: _submitting ? null : _back,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: dark,
                        minimumSize: const Size(105, 48),
                      ),
                      child: const Text('Atrás'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentStep == 1
                                  ? 'Enviar reporte'
                                  : 'Continuar',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
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
    );
  }
}
