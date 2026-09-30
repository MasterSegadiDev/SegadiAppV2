enum ParadaTipo {
  puerto('PUERTO'),
  patio('PATIO'),
  cliente('CLIENTE');

  final String apiValue;

  const ParadaTipo(this.apiValue);

  static ParadaTipo fromApi(String value) {
    return ParadaTipo.values.firstWhere(
      (tipo) => tipo.apiValue == value,
      orElse: () => throw ArgumentError(
        'Tipo de parada desconocido: $value',
      ),
    );
  }
}
