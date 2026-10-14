class DetailServiceEntity {
  final int id;
  final String service;
  final String serviceType;

  // Sender
  final String senderBusinessName;
  final String senderName;
  final String senderPhoneNumber;
  final String senderStreet;
  final String senderOutdoorNumber;
  final String senderInteriorNumber;
  final String senderCountry;
  final String senderState;
  final int senderZipCode;

  // Recipient
  final String recipientBusinessName;
  final String recipientName;
  final String recipientPhoneNumber;
  final String recipientStreet;
  final String recipientOutdoorNumber;
  final String recipientInteriorNumber;
  final String recipientCountry;
  final String recipientState;
  final int recipientZipCode;

  // Status support
  final int statusId;
  final String status;
  final String type;

  // Mandatory status
  final int mandatoryStatusId;
  final String mandatoryStatus;
  final int nextMandatoryStatusId;
  final String nextMandatoryStatus;

  // Backend flags
  final bool serviceClosed;

  final bool isEvidence;
  final bool eirSent;
  final int remainingEvidences;
  final Map<String, bool> checklist;

  final bool pendingMoneyChecks;

  // Buttons state
  final UiModel ui;

  const DetailServiceEntity({
    required this.id,
    required this.service,
    required this.serviceType,
    required this.senderBusinessName,
    required this.senderName,
    required this.senderPhoneNumber,
    required this.senderStreet,
    required this.senderOutdoorNumber,
    required this.senderInteriorNumber,
    required this.senderCountry,
    required this.senderState,
    required this.senderZipCode,
    required this.recipientBusinessName,
    required this.recipientName,
    required this.recipientPhoneNumber,
    required this.recipientStreet,
    required this.recipientOutdoorNumber,
    required this.recipientInteriorNumber,
    required this.recipientCountry,
    required this.recipientState,
    required this.recipientZipCode,
    required this.statusId,
    required this.status,
    required this.type,
    required this.mandatoryStatusId,
    required this.mandatoryStatus,
    required this.nextMandatoryStatusId,
    required this.nextMandatoryStatus,
    required this.serviceClosed,
    required this.isEvidence,
    required this.eirSent,
    required this.remainingEvidences,
    required this.checklist,
    required this.ui,
    required this.pendingMoneyChecks,
  });
}

class UiModel {
  final bool enableBtn;
  final bool enableSupport;
  final bool enableCheckList;
  final bool hasMoneyChecks;
  final bool serviceClosed;

  UiModel({
    required this.enableBtn,
    required this.enableSupport,
    required this.enableCheckList,
    required this.hasMoneyChecks,
    required this.serviceClosed,
  });

  factory UiModel.empty() {
    return UiModel(
      enableBtn: false,
      enableSupport: false,
      enableCheckList: false,
      hasMoneyChecks: false,
      serviceClosed: false,
    );
  }

  UiModel copyWith({
    bool? enableBtn,
    bool? enableSupport,
    bool? enableCheckList,
    bool? hasMoneyChecks,
    bool? serviceClosed,
  }) {
    return UiModel(
      enableBtn: enableBtn ?? this.enableBtn,
      enableSupport: enableSupport ?? this.enableSupport,
      enableCheckList: enableCheckList ?? this.enableCheckList,
      hasMoneyChecks: hasMoneyChecks ?? this.hasMoneyChecks,
      serviceClosed: serviceClosed ?? this.serviceClosed,
    );
  }
}
