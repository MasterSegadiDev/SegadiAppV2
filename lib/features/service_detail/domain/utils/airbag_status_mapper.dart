const Map<int, String> _airbagStatusMap = {
  2: "active",
  23: "inactive",
};

/// Mapea un ID de estatus a su equivalente en Airbag.
/// Retorna [null] si el estatus no requiere ser reportado a Airbag.
String? mapStatusToAirbag(int statusId) {
  // Verificamos si el ID existe en nuestro mapa de interés
  return _airbagStatusMap[statusId];
}
