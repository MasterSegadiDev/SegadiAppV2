class StatusSupport {
  final String? statusId;
  final String? serviceId;
  final String? type;

  StatusSupport(
      {required this.serviceId, required this.statusId, required this.type});

  factory StatusSupport.fromJson(Map<String, dynamic> json) => StatusSupport(
        serviceId: json["service_id"],
        statusId: json["status_id"],
        type: json["type"],
      );

  Map<String, dynamic> toMap() {
    return {'service_id': serviceId, 'status_id': statusId, 'type': type};
  }
}
