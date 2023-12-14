// To parse this JSON data, do
//
//     final checkList = checkListFromJson(jsonString);

import 'dart:convert';

List<CheckList> checkListFromJson(String str) =>
    List<CheckList>.from(json.decode(str).map((x) => CheckList.fromJson(x)));

String checkListToJson(List<CheckList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CheckList {
  int id;
  String option;
  int sequence;

  CheckList({
    required this.id,
    required this.option,
    required this.sequence,
  });

  factory CheckList.fromJson(Map<String, dynamic> json) => CheckList(
        id: json["id"],
        option: json["option"],
        sequence: json["sequence"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "option": option,
        "sequence": sequence,
      };
}
