class CreateMaintenanceRequestModel {
  const CreateMaintenanceRequestModel({
    required this.assetCode,
    required this.description,
    required this.observation,
    required this.dateIncident,
    required this.requestedBy,
    required this.userCode,
    required this.isUrgent,
    required this.typesDescription,
    required this.types1Description,
    required this.types2Description,
    required this.identifier,
    this.userType = 'HUMAN_RESOURCES',
    this.thirdPartyCode,
    this.contactName,
  });

  final String assetCode;
  final String description;
  final String observation;
  final DateTime dateIncident;
  final String requestedBy;
  final String userCode;
  final bool isUrgent;
  final String typesDescription;
  final String types1Description;
  final String types2Description;
  final String identifier;
  final String userType;
  final String? thirdPartyCode;
  final String? contactName;

  Map<String, dynamic> toJson() {
    if (description.trim().isEmpty ||
        requestedBy.trim().isEmpty ||
        userCode.trim().isEmpty ||
        identifier.trim().isEmpty) {
      throw ArgumentError(
        'Faltan datos obligatorios del reporte.',
      );
    }

    if (userType == 'THIRD_PARTIES' &&
        ((thirdPartyCode?.trim().isEmpty ?? true) ||
            (contactName?.trim().isEmpty ?? true))) {
      throw ArgumentError(
        'El tercero requiere código y contacto.',
      );
    }

    final date = dateIncident.toLocal();
    final offset = date.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = (offset.inMinutes.abs() ~/ 60).toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    final dateString = '${date.toIso8601String().split('.').first}'
        '$sign$hours:$minutes';

    return {
      if (assetCode.trim().isNotEmpty) 'code': assetCode.trim(),
      'description': description.trim(),
      'observation': observation.trim(),
      'date_incident': dateString,
      'requested_by': requestedBy.trim(),
      'user_code': userCode.trim(),
      'identifier': identifier,
      'is_urgent': isUrgent.toString(),
      'types_description': typesDescription,
      'types_1_description': types1Description,
      'types_2_description': types2Description,
      'user_type': userType,
      if (userType == 'THIRD_PARTIES') ...{
        'third_party_code': thirdPartyCode!.trim(),
        'contact_name': contactName!.trim(),
      },
    };
  }
}
