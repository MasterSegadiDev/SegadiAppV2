import 'package:segadi/features/service_detail/data/mappers/detail_ui_buttons_mapper.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';

class DetailServiceMapper {
  static DetailServiceEntity fromJson(Map<String, dynamic> json) {
    return DetailServiceEntity(
      //indentity
      id: _asInt(json['id']),
      service: _asString(json['service']),
      serviceType: _asString(json['service_type']).toLowerCase().trim(),

      //status remision
      statusId: _asInt(json['status_id']),
      status: _asString(json['status']),
      mandatoryStatusId: _asInt(json['mandatory_status_id']),
      mandatoryStatus: _asString(json['mandatory_status']),
      nextMandatoryStatusId: _asInt(json['next_mandatory_status_id']),
      nextMandatoryStatus: _asString(json['next_mandatory_status']),

      //sender
      senderBusinessName: _asString(json['sender_business_name']),
      senderName: _asString(json['sender_name']),
      senderPhoneNumber: _asString(json['sender_phone_number']),
      senderStreet: _asString(json['sender_street']),
      senderOutdoorNumber: _asString(json['sender_outdoor_number']),
      senderInteriorNumber: _asString(json['sender_interior_number']),
      senderCountry: _asString(json['sender_country']),
      senderState: _asString(json['sender_state']),
      senderZipCode: _asInt(json['sender_zip_code']),

      //Recipent
      recipientBusinessName: _asString(json['recipient_business_name']),
      recipientName: _asString(json['recipient_name']),
      recipientPhoneNumber: _asString(json['recipient_phone_number']),
      recipientStreet: _asString(json['recipient_street']),
      recipientOutdoorNumber: _asString(json['recipient_outdoor_number']),
      recipientInteriorNumber: _asString(json['recipient_interior_number']),
      recipientCountry: _asString(json['recipient_country']),
      recipientState: _asString(json['recipient_state']),
      recipientZipCode: _asInt(json['recipient_zip_code']),

      //Backend flags
      serviceClosed: _asBool(json['service_closed']),
      pendingMoneyChecks: _asBool(json['pending_money_checks']),
      isEvidence: _asBool(json['evidence']),
      eirSent: _asBool(json['eir_sent']),
      remainingEvidences: _asInt(json['remaining_evidences']),
      checklist: _asChecklist(json['list']),
      type: _asString(json['type']),

      //Buttons state
      ui: UiMapper.fromJson(json['ui']),
    );
  }

  // ---------- Helpers defensivos ----------

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  static Map<String, bool> _asChecklist(dynamic value) {
    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(k.toString(), _asBool(v)),
      );
    }
    return const {};
  }
}
