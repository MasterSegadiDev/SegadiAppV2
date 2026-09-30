enum ParadaAccion {
  recoger('RECOGER'),
  entregar('ENTREGAR');

  final String apiValue;

  const ParadaAccion(this.apiValue);

  static ParadaAccion fromApi(String value) {
    return ParadaAccion.values.firstWhere(
      (accion) => accion.apiValue == value,
      orElse: () => throw ArgumentError(
        'Acción desconocida: $value',
      ),
    );
  }
}
