import 'dart:convert';

List<Option> mainListOptionFromJson(String str) =>
    List<Option>.from(json.decode(str).map((x) => Option.fromJson(x)));

String mainListOptionToJson(List<Option> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Option {
  final String id;
  final String nameOption;
  final String descriptionOption;

  Option({
    required this.id,
    required this.nameOption,
    required this.descriptionOption,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
        id: json["id"],
        nameOption: json["name_option"],
        descriptionOption: json["description_option"]);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name_option": nameOption,
        "description_option": descriptionOption
      };
}
