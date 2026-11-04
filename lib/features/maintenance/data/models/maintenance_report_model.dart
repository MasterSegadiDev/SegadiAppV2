import '../../domain/entities/maintenance_report.dart';

class MaintenanceReportModel extends MaintenanceReport {
  const MaintenanceReportModel({
    required super.idCode,
    super.date,
    super.idType,
    super.idItem,
    super.isUrgent,
    super.description,
    super.observation,
    super.dateSolution,
    super.typeDescription,
    super.itemDescription,
    super.idStatus,
    super.statusDescription,
    super.statusNotes,
    super.statusColor,
    super.accountsName,
    super.accountsEmail,
    super.workOrderFolio,
    super.dateIncident,
    super.parentDescription,
    super.requestedBy,
    super.type1Description,
    super.type2Description,
    super.identifier,
    super.priorityDescription,
    super.codeItem,
    super.costCenterDescription,
    super.annotations,
    super.visibleToAll,
    super.codeCreator,
  });

  factory MaintenanceReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    bool parseBool(dynamic value) {
      return value == true ||
          value.toString().toLowerCase() == 'true' ||
          value.toString() == '1';
    }

    return MaintenanceReportModel(
      idCode: parseInt(json['id_code']) ?? 0,
      date: parseString(json['date']),
      idType: parseInt(json['id_type']),
      idItem: parseInt(json['id_item']),
      isUrgent: parseBool(json['is_urgent']),
      description: parseString(json['description']),
      observation: parseString(json['observation']),
      dateSolution: parseString(json['date_solution']),
      typeDescription: parseString(json['types_description']),
      itemDescription: parseString(json['items_description']),
      idStatus: parseInt(json['id_status']),
      statusDescription: parseString(
        json['requests_x_status_description'],
      ),
      statusNotes: parseString(
        json['requests_x_status_notes'],
      ),
      statusColor: parseString(json['status_path_image']),
      accountsName: parseString(json['accounts_name']),
      accountsEmail: parseString(json['accounts_email']),
      workOrderFolio: parseInt(json['wo_folio']),
      dateIncident: parseString(json['date_incident']),
      parentDescription: parseString(json['parent_description']),
      requestedBy: parseString(json['requested_by']),
      type1Description: parseString(json['types_1_description']),
      type2Description: parseString(json['types_2_description']),
      identifier: parseString(json['identifier']),
      priorityDescription: parseString(
        json['priorities_description'],
      ),
      codeItem: parseString(json['code_item']),
      costCenterDescription: parseString(
        json['costs_center_description'],
      ),
      annotations: parseString(json['annotations']),
      visibleToAll: parseBool(json['visible_to_all']),
      codeCreator: parseString(json['code_creator']),
    );
  }
}
