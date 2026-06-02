class ServicesFinished {
  final int id;
  final String service;
  final String client;
  final String origin;
  final String destination;
  final String loadDate;
  final String unloadDate;
  final String documenter;
  final String status;

  ServicesFinished({
    required this.id,
    required this.service,
    required this.client,
    required this.origin,
    required this.destination,
    required this.loadDate,
    required this.unloadDate,
    required this.documenter,
    required this.status,
  });

  factory ServicesFinished.fromJson(Map<String, dynamic> json) =>
      ServicesFinished(
        id: json["id"] ?? 0,
        service: json["service"] ?? '',
        client: json["client"] ?? '',
        origin: json["origin"] ?? '',
        destination: json["destination"] ?? '',
        loadDate: json["load_date"] ?? '',
        unloadDate: json["unload_date"] ?? '',
        documenter: json["documenter"] ?? '',
        status: json["lq_estatus"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service": service,
        "client": client,
        "origin": origin,
        "destination": destination,
        "load_date": loadDate,
        "unload_date": unloadDate,
        "documenter": documenter,
        "lq_estatus": status,
      };
}
