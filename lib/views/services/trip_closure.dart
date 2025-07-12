import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/trip_closure.dart';
import 'package:segadi/views/services/pdfPreviewScreen.dart';

class TripClosureScreen extends StatelessWidget {
  final int id;
  final String serviceId;

  const TripClosureScreen({
    Key? key,
    required this.id,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = TripClosureViewModel();
        viewModel.initialize(id, serviceId);
        viewModel.loadInitialData();
        return viewModel;
      },
      child: const _TripClosureContent(),
    );
  }
}

class _TripClosureContent extends StatefulWidget {
  const _TripClosureContent({Key? key}) : super(key: key);

  @override
  State<_TripClosureContent> createState() => _TripClosureContentState();
}

class _TripClosureContentState extends State<_TripClosureContent> {
  TripClosureViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Solo inicializa una vez
    _viewModel ??= Provider.of<TripClosureViewModel>(context);
  }

  @override
  void dispose() {
    // Usa la referencia local en lugar de llamar Provider.of(...)
    _viewModel?.deleteCapturedImage(notify: false);
    super.dispose();
  }

  Future<void> _handleSaveImage(BuildContext context) async {
    final viewModel = Provider.of<TripClosureViewModel>(context, listen: false);
    if (viewModel.images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay imágenes para guardar.')),
      );
      return;
    }
    await _previewAndConfirmPdf(context, viewModel);
  }

  Future<void> _previewAndConfirmPdf(
      BuildContext context, TripClosureViewModel viewModel) async {
    final pdfData = await viewModel.generatePdf();

    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(pdfData: pdfData),
      ),
    );

    // if (confirmed == true) {
    //   final closed = await viewModel.saveImagesAndCloseTrip();
    //   if (closed && mounted) {
    //     await showDialog(
    //       context: context,
    //       builder: (_) => AlertDialog(
    //         title: const Text('Viaje cerrado'),
    //         content: const Text('Tu viaje ha sido cerrado correctamente.'),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.of(context).pop(),
    //             child: const Text('Aceptar'),
    //           ),
    //         ],
    //       ),
    //     );
    //     if (mounted) Navigator.of(context).pop(true);
    //   }
    // }

    if (confirmed == true) {
      final pdfData = await _viewModel!.generatePdf();

      final success =
          await _viewModel!.sendPdfToServer(Uint8List.fromList(pdfData));

      if (success) {
        final closed = await _viewModel!.saveImagesAndCloseTrip();
        if (closed && mounted) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Viaje cerrado'),
              content: const Text('PDF enviado y viaje cerrado correctamente.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
          if (mounted) Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error al enviar el PDF al servidor.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TripClosureViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cierre del viaje',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              if (viewModel.images.isNotEmpty)
                _buildImagesPreview(viewModel)
              else
                _buildImageLimitNotice(viewModel),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: viewModel.showCaptureButton
                    ? _AnimatedIconButton(
                        key: const ValueKey('capture'),
                        icon: Icons.camera_alt,
                        color: Colors.blueAccent,
                        tooltip: 'Capturar Imagen',
                        onPressed: viewModel.captureImage,
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: viewModel.showSaveButton
                    ? _AnimatedIconButton(
                        key: const ValueKey('save'),
                        icon: Icons.save,
                        color: Colors.green,
                        tooltip: 'Guardar capturas',
                        onPressed: () => _handleSaveImage(context),
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: viewModel.images.isNotEmpty
                    ? _AnimatedIconButton(
                        key: const ValueKey('delete'),
                        icon: Icons.delete,
                        color: Colors.redAccent,
                        tooltip: 'Eliminar última imagen',
                        onPressed: viewModel.deleteLastCapturedImage,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesPreview(TripClosureViewModel viewModel) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: viewModel.images.map((img) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            img,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageLimitNotice(TripClosureViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Puedes capturar máximo ${viewModel.numberTotalEvidentias} evidencias para cerrar el viaje.',
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Botón animado
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _AnimatedIconButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkResponse(
        onTap: widget.onPressed,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        borderRadius: BorderRadius.circular(50),
        splashColor: widget.color.withOpacity(0.3),
        child: Tooltip(
          message: widget.tooltip,
          child: Icon(widget.icon, color: widget.color, size: 30),
        ),
      ),
    );
  }
}
