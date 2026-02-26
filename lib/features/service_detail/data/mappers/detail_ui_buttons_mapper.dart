import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';

class UiMapper {
  static UiModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return UiModel.empty();

    return UiModel(
      enableBtn: _asBool(json['enableBtn']),
      enableSupport: _asBool(json['enableSupport']),
      enableCheckList: _asBool(json['enableCheckList']),

      // CAMBIO CLAVE: La llave en tu JSON es 'pendingMoneyChecks'
      hasMoneyChecks: _asBool(json['pendingMoneyChecks']),

      serviceClosed: _asBool(json['serviceClosed']),
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}
