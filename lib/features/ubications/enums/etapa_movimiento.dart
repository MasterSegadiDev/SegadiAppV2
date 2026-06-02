enum EtapaMovimiento {
  idle,
  validandoOrden,
  seleccionandoOrigen,
  seleccionandoDestino,
  reacomodando,
  confirmando,
  completado,
  error,
}

enum PesajeOrigen {
  movimiento,
  manual,
  listado,
}
