enum TramoStatus {
  asignado('ASIGNADO'),
  enTransito('EN_TRANSITO'),
  llegadaPatio('LLEGADA_PATIO'),
  esperandoGrua('ESPERANDO_GRUA'),
  cargaConfirmada('CARGA_CONFIRMADA'),
  finalizado('FINALIZADO');

  final String apiValue;

  const TramoStatus(this.apiValue);

  static TramoStatus fromApi(String value) {
    return TramoStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => throw ArgumentError(
        'Estado de tramo desconocido: $value',
      ),
    );
  }
}
