abstract class NivelSeleccionState {}

class NivelErrorState extends NivelSeleccionState {
  final String mensaje;
  NivelErrorState(this.mensaje);
}

class NivelOrigenSeleccionadoState extends NivelSeleccionState {
  final String mensajeUsuario;
  NivelOrigenSeleccionadoState(this.mensajeUsuario);
}

class NivelDestinoListoState extends NivelSeleccionState {
  final String mensajeConfirmacion;
  NivelDestinoListoState(this.mensajeConfirmacion);
}
