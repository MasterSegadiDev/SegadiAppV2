import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

// --- FORMATOS DE TEXTO PERSONALIZADOS ---
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.contains('.') &&
        text.substring(text.indexOf('.') + 1).length > decimalRange) {
      return oldValue;
    }
    return newValue;
  }
}

class PesajeFormScreen extends StatefulWidget {
  const PesajeFormScreen({super.key});

  @override
  State<PesajeFormScreen> createState() => _PesajeFormScreenState();
}

class _PesajeFormScreenState extends State<PesajeFormScreen> {
  String? error;
  bool isLoading = true;
  String? currentSiteId;

  @override
  void initState() {
    super.initState();
    // Limpiamos el formulario cada vez que entramos
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UbicacionesViewModel>(context, listen: false).clearForm();

      final session = UserSession();
      await session.loadFromPrefs();

      if (session.siteId == null || session.siteId!.isEmpty) {
        print('NUMERO DE SITE ID: ${session.siteId}');
        setState(() {
          error = "No se encontró un site_id válido. Inicie sesión nuevamente.";
          isLoading = false;
        });
        return;
      }

      // ✅ Guardamos el siteId en el estado de la pantalla
      setState(() {
        currentSiteId = session.siteId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UbicacionesViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Pesaje de Contenedores',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
        elevation: 3,
        centerTitle: true,
      ),
      body: vm.isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Registrando pesaje...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Card(
                      elevation: 10,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // --- TÍTULO DEL FORMULARIO ---
                            Text(
                              'Formulario de Pesaje',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C522A),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- NÚMERO DE SERIE ---
                            _buildInputField(
                              controller: vm.numeroSerieController,
                              label: 'Número de Serie',
                              icon: Icons.confirmation_number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                                UpperCaseTextFormatter(),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // --- PESO BRUTO ---
                            _buildInputField(
                              controller: vm.pesoBrutoController,
                              label: 'Peso Bruto (Toneladas)',
                              icon: Icons.monitor_weight,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                DecimalTextInputFormatter(decimalRange: 2),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // --- NOMBRE DE LA IMAGEN ---
                            _buildInputField(
                              controller: vm.nombreImagenPesoController,
                              label: 'Nombre de la Evidencia (Imagen)',
                              icon: Icons.image,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                                UpperCaseTextFormatter(),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // --- BOTÓN CAPTURAR IMAGEN ---
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C522A),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => vm.pickImageFromCamera(),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text(
                                'Capturar Imagen',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // --- IMAGEN CAPTURADA ---
                            if (vm.selectedImage != null)
                              Column(
                                children: [
                                  const Text(
                                    'Imagen Capturada:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      vm.selectedImage!,
                                      width: 220,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            vm.clearSelectedImage(),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Eliminar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            vm.pickImageFromCamera(),
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Cambiar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2C522A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            const SizedBox(height: 32),

                            // --- BOTONES DE ACCIÓN ---
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final peso =
                                          vm.pesoBrutoController.text.trim();
                                      final serie =
                                          vm.numeroSerieController.text.trim();
                                      final name = vm
                                          .nombreImagenPesoController.text
                                          .trim();
                                      final imagen = vm.selectedImage;

                                      if (peso.isEmpty ||
                                          serie.isEmpty ||
                                          name.isEmpty ||
                                          imagen == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Por favor completa todos los campos y captura una imagen.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      await vm.registrarPesaje(
                                        serie: serie,
                                        peso: peso,
                                        nameImage: name,
                                        image: imagen,
                                        siteId: currentSiteId!,
                                      );

                                      if (vm.registroMensaje != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(vm.registroMensaje!),
                                            backgroundColor: vm.registroMensaje!
                                                    .contains('✅')
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.save),
                                    label: const Text('Guardar Pesaje'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2C522A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF2C522A),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // --- WIDGET PERSONALIZADO PARA INPUTS ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C522A), width: 2),
        ),
      ),
    );
  }
}
