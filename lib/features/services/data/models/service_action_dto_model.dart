class ActionDto {
  final bool enabled;
  final bool show;

  const ActionDto({
    required this.enabled,
    required this.show,
  });

  factory ActionDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ActionDto(
      enabled: json['enabled'] ?? false,
      show: json['show'] ?? false,
    );
  }
}
