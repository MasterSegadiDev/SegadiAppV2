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
  final String? movementId;
  final String? serie; // ← ahora sí se almacena

  const PesajeFormScreen({
    super.key,
    this.movementId,
    this.serie,
  });

  @override
  State<PesajeFormScreen> createState() => _PesajeFormScreenState();
}

class _PesajeFormScreenState extends State<PesajeFormScreen> {
  String? error;
  String? currentSiteId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = Provider.of<UbicacionesViewModel>(context, listen: false);
      vm.clearForm();

      final session = UserSession();
      await session.loadFromPrefs();

      if (session.siteId == null || session.siteId!.isEmpty) {
        setState(() => error = "No se encontró un site_id válido.");
        return;
      }

      setState(() => currentSiteId = session.siteId);

      if (widget.serie != null && widget.serie!.isNotEmpty) {
        vm.numeroSerieController.text = widget.serie!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UbicacionesViewModel>(context);

    if (error != null) {
      return _buildErrorScreen(error!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: vm.isSaving ? _buildSavingOverlay() : _buildForm(vm),
    );
  }

  // ---------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Pesaje',
        style: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF2C522A),
    );
  }

  // ---------------------------------------------------------
  // ERROR VIEW
  // ---------------------------------------------------------
  Widget _buildErrorScreen(String text) {
    return Scaffold(
      body: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // PANTALLA DE GUARDANDO
  // ---------------------------------------------------------
  Widget _buildSavingOverlay() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Registrando pesaje...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // FORMULARIO
  // ---------------------------------------------------------
  Widget _buildForm(UbicacionesViewModel vm) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitle(),

                    const SizedBox(height: 28),

                    // Campos
                    _buildInputModern(
                      controller: vm.numeroSerieController,
                      label: "Número de contenedor",
                      icon: Icons.qr_code_2_rounded,
                    ),
                    const SizedBox(height: 20),

                    _buildInputModern(
                      controller: vm.pesoBrutoController,
                      label: "Peso Bruto (Toneladas)",
                      icon: Icons.scale_rounded,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),

                    _buildInputModern(
                      controller: vm.nombreImagenPesoController,
                      label: "Nombre de Evidencia",
                      icon: Icons.photo_library_outlined,
                    ),

                    const SizedBox(height: 28),
                    _buildCaptureButton(vm),

                    const SizedBox(height: 25),
                    if (vm.selectedImage != null) _buildImagePreview(vm),

                    const SizedBox(height: 32),
                    _buildSubmitButtons(vm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputModern({
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
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        floatingLabelStyle: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: Colors.green.shade800, width: 2),
        ),
      ),
    );
  }

  Widget _buildCaptureButton(UbicacionesViewModel vm) {
    return ElevatedButton(
      onPressed: vm.pickImageFromCamera,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.camera_alt_rounded, size: 22, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "Capturar Imagen",
            style: TextStyle(fontSize: 16, color: Colors.white),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // TITULO
  // ---------------------------------------------------------
  Widget _buildTitle() {
    return Text(
      'Formulario de Pesaje',
      textAlign: TextAlign.center,
      style: GoogleFonts.openSans(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildImagePreview(UbicacionesViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Imagen Capturada',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 2,
                color: Colors.black12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              vm.selectedImage!,
              width: 260,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _smallActionButton(
              label: "Eliminar",
              icon: Icons.delete_outline_rounded,
              color: Colors.redAccent,
              onTap: vm.clearSelectedImage,
            ),
            const SizedBox(width: 14),
            _smallActionButton(
              label: "Cambiar",
              icon: Icons.refresh_rounded,
              color: const Color(0xFF2C522A),
              onTap: vm.pickImageFromCamera,
            )
          ],
        )
      ],
    );
  }

  Widget _buildSubmitButtons(UbicacionesViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _onSubmit(vm),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.save_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Guardar Pesaje",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancelar",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.redAccent,
            ),
          ),
        )
      ],
    );
  }

  Widget _smallActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  // ---------------------------------------------------------
  // LÓGICA DE GUARDADO (compacta y clara)
  // ---------------------------------------------------------
  Future<void> _onSubmit(UbicacionesViewModel vm) async {
    final peso = vm.pesoBrutoController.text.trim();
    final serie = vm.numeroSerieController.text.trim();
    final name = vm.nombreImagenPesoController.text.trim();
    final image = vm.selectedImage;

    if (peso.isEmpty || serie.isEmpty || name.isEmpty || image == null) {
      _showSnack("Completa todos los campos y captura una imagen.", false);
      return;
    }

    await vm.registrarPesaje(
      movementId: widget.movementId!,
      serie: serie,
      peso: peso,
      nameImage: name,
      image: image,
      siteId: currentSiteId!,
    );

    if (vm.registroMensaje != null) {
      _showSnack(
        vm.registroMensaje!,
        vm.registroMensaje!.contains("✅"),
      );
    }
  }

  // ---------------------------------------------------------
  // SNACK CENTRALIZADO
  // ---------------------------------------------------------
  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // ---------------------------------------------------------
  // INPUT FIELD GENERAL
  // ---------------------------------------------------------
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C522A), width: 2),
        ),
      ),
    );
  }
}
