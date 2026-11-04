class MaintenanceReport {
  const MaintenanceReport({
    required this.idCode,
    this.date,
    this.idType,
    this.idItem,
    this.isUrgent = false,
    this.description,
    this.observation,
    this.dateSolution,
    this.typeDescription,
    this.itemDescription,
    this.idStatus,
    this.statusDescription,
    this.statusNotes,
    this.statusColor,
    this.accountsName,
    this.accountsEmail,
    this.workOrderFolio,
    this.dateIncident,
    this.parentDescription,
    this.requestedBy,
    this.type1Description,
    this.type2Description,
    this.identifier,
    this.priorityDescription,
    this.codeItem,
    this.costCenterDescription,
    this.annotations,
    this.visibleToAll = false,
    this.codeCreator,
  });

  final int idCode;
  final String? date;
  final int? idType;
  final int? idItem;
  final bool isUrgent;
  final String? description;
  final String? observation;
  final String? dateSolution;
  final String? typeDescription;
  final String? itemDescription;
  final int? idStatus;
  final String? statusDescription;
  final String? statusNotes;
  final String? statusColor;
  final String? accountsName;
  final String? accountsEmail;
  final int? workOrderFolio;
  final String? dateIncident;
  final String? parentDescription;
  final String? requestedBy;
  final String? type1Description;
  final String? type2Description;
  final String? identifier;
  final String? priorityDescription;
  final String? codeItem;
  final String? costCenterDescription;
  final String? annotations;
  final bool visibleToAll;
  final String? codeCreator;
}
