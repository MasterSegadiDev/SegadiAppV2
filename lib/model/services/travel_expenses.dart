import 'dart:convert';

List<TravelExpenses> travelExpensesFromJson(String str) =>
    List<TravelExpenses>.from(
        json.decode(str).map((x) => TravelExpenses.fromJson(x)));

String travelExpensesToJson(List<TravelExpenses> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TravelExpenses {
  final int id;
  final String datetime;
  final int serviceId;
  final int paymentConceptId;
  final String paymentConcept;
  final String totalUsed;
  String? paymentTotal;
  final String comments;

  TravelExpenses({
    required this.id,
    required this.datetime,
    required this.serviceId,
    required this.paymentConceptId,
    required this.paymentConcept,
    required this.totalUsed,
    this.paymentTotal,
    required this.comments,
  });

  factory TravelExpenses.fromJson(Map<String, dynamic> json) => TravelExpenses(
        id: json["id"],
        datetime: json["datetime"],
        serviceId: json["service_id"],
        paymentConceptId: json["payment_concept_id"],
        paymentConcept: json["payment_concept"],
        totalUsed: json["total_used"],
        paymentTotal: json["payment_total"],
        comments: json["comments"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "datetime": datetime,
        "service_id": serviceId,
        "payment_concept_id": paymentConceptId,
        "payment_concept": paymentConcept,
        "total_used": totalUsed,
        "payment_total": paymentTotal,
        "comments": comments,
      };
}
