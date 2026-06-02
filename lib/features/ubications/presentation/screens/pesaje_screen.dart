import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_entity.dart';
import 'package:segadi/features/ubications/enums/etapa_movimiento.dart';
import 'package:segadi/features/ubications/helpers/input_formatter.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/pesaje_viewmodel.dart';

class PesajeFormScreen extends StatefulWidget {
  final MovimientoEntity? movimiento;
  final PesajeOrigen origen;

  const PesajeFormScreen({
    super.key,
    this.movimiento,
    this.origen = PesajeOrigen.listado,
  });

  @override
  State<PesajeFormScreen> createState() => _PesajeFormScreenState();
}

class _PesajeFormScreenState extends State<PesajeFormScreen> {
  @override
  void initState() {
    super.initState();

    print('TIPO DE MOVIMIENTO : ${widget.origen}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<PesajeViewModel>(
        context,
        listen: false,
      );
      vm.setInputSerie(
        widget.origen == PesajeOrigen.manual,
      );
      vm.numeroSerieController.text = widget.movimiento?.serieObjetivo ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PesajeViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _appBar(),
      body: vm.isSaving ? _loading() : _body(vm),
    );
  }

  // =========================================================
  // APP BAR PRO
  // =========================================================
  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'PESAJE DE CONTENEDOR',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
      backgroundColor: const Color(0xFF2C522A),
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 2,
    );
  }

  // =========================================================
  // LOADING
  // =========================================================
  Widget _loading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text("Registrando pesaje..."),
        ],
      ),
    );
  }

  // =========================================================
  // BODY
  // =========================================================
  Widget _body(PesajeViewModel vm) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _card(vm),
        ),
      ),
    );
  }

  // =========================================================
  // CARD PRINCIPAL
  // =========================================================
  Widget _card(PesajeViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title(),
          const SizedBox(height: 20),
          _field(
            controller: vm.numeroSerieController,
            label: "Número de contenedor",
            icon: Icons.qr_code_rounded,
            enabled: vm.inputSerie,
          ),
          const SizedBox(height: 14),
          _field(
            controller: vm.pesoBrutoController,
            label: "Peso (Toneladas)",
            icon: Icons.scale_rounded,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalInputFormatter(),
            ],
          ),
          const SizedBox(height: 14),
          _field(
            controller: vm.nombreImagenPesoController,
            label: "Nombre de evidencia",
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 18),
          _cameraButton(vm),
          const SizedBox(height: 18),
          if (vm.selectedImage != null) _imagePreview(vm),
          const SizedBox(height: 24),
          _buttons(vm),
        ],
      ),
    );
  }

  // =========================================================
  // TITLE
  // =========================================================
  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registro de Pesaje',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Captura el peso del contenedor y evidencia',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // INPUT MODERNO
  // =========================================================
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2C522A)),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // =========================================================
  // CAMERA BUTTON
  // =========================================================
  Widget _cameraButton(PesajeViewModel vm) {
    return ElevatedButton.icon(
      onPressed: vm.pickImageFromCamera,
      icon: const Icon(Icons.camera_alt_rounded),
      label: const Text("Capturar evidencia"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C522A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // =========================================================
  // IMAGE PREVIEW
  // =========================================================
  Widget _imagePreview(PesajeViewModel vm) {
    return Column(
      children: [
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.file(
              vm.selectedImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: vm.pickImageFromCamera,
              icon: const Icon(Icons.refresh),
              label: const Text("Cambiar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: vm.clearSelectedImage,
              icon: const Icon(Icons.delete),
              label: const Text("Eliminar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // BOTONES PRO
  // =========================================================
  Widget _buttons(PesajeViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: const Text("Cancelar"),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _submit(vm),
          icon: const Icon(Icons.scale),
          label: const Text("Registrar Pesaje"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C522A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SUBMIT
  // =========================================================
  Future<void> _submit(PesajeViewModel vm) async {
    /*
  =====================================
  VALIDAR IMAGEN
  =====================================
  */

    if (vm.selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes capturar una imagen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    /*
  =====================================
  REGISTRAR
  =====================================
  */

    final ok = await vm.registrarPesaje(
      movementId: widget.movimiento?.id.toString() ?? '',
      serie: vm.numeroSerieController.text.trim(),
      peso: vm.pesoBrutoController.text.trim(),
      nameImage: vm.nombreImagenPesoController.text.trim(),

      // 🔥 AQUI MANDAS LA RUTA REAL
      image: vm.selectedImage!.path,

      // 🔥 YA NO QUEMES SITE
    );

    if (!mounted) return;

    /*
  =====================================
  SNACKBAR
  =====================================
  */

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? "Pesaje registrado correctamente"
              : vm.mensaje ?? "Error al registrar pesaje",
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    /*
  =====================================
  LIMPIAR CACHE IMAGEN
  =====================================
  */

    if (ok) {
      await vm.clearSelectedImage();

      Navigator.pop(context);
    }
  }
}
