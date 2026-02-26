class CheckListItemModel {
  final String id;
  final String option;
  final int sequence;

  CheckListItemModel({
    required this.id,
    required this.option,
    required this.sequence,
  });

  factory CheckListItemModel.fromJson(Map<String, dynamic> json) {
    return CheckListItemModel(
      id: json['id'] as String,
      option: json['option'] as String,
      sequence: json['sequence'] as int,
    );
  }

  Map<String, dynamic> toEntity() {
    return {
      'id': id,
      'option': option,
      'sequence': sequence,
    };
  }
}
