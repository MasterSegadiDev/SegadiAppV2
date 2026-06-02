sealed class UiEvent {}

class MostrarMensajeExito extends UiEvent {
  final String titulo;
  final String mensaje;
  final String? detalle;

  MostrarMensajeExito(
      {required this.titulo, required this.mensaje, this.detalle});
}

class MostrarMensajeError extends UiEvent {
  final String titulo;
  final String mensaje;
  final String? detalle;

  MostrarMensajeError(
      {required this.titulo, required this.mensaje, this.detalle});
}
