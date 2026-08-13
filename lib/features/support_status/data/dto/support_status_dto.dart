import '../../domain/entities/support_status_entity.dart';

class SupportStatusDto extends SupportStatusEntity {
  const SupportStatusDto({
    required super.id,
    required super.enabled,
    required super.sequence,
    required super.category,
    required super.monitoringStatus,
    required super.statusType,
  });

  factory SupportStatusDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupportStatusDto(
      id: json['_id']?.toString() ?? '',
      enabled: json['blnStatus'] == true,
      sequence: json['intSequence'] is int
          ? json['intSequence'] as int
          : int.tryParse(
                json['intSequence']?.toString() ?? '',
              ) ??
              0,
      category: json['strCategory']?.toString() ?? '',
      monitoringStatus: json['strMonitoringStatus']?.toString() ?? '',
      statusType: json['strStatusType']?.toString() ?? '',
    );
  }
}
