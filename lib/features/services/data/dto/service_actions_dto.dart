// import '../../domain/entities/service_actions_entity.dart';

// class ServiceActionsModel extends ServiceActionsEntity {
//   const ServiceActionsModel({
//     required super.checklist,
//     required super.support,
//     required super.route,
//     required super.closeEvidence,
//     required super.travelExpenses,
//     required super.downloadCcp,
//   });

//   factory ServiceActionsModel.fromJson(
//     Map<String, dynamic> json,
//   ) {
//     return ServiceActionsModel(
//       checklist: _isEnabled(
//         json['check_list'],
//       ),
//       support: _isEnabled(
//         json['support'],
//       ),
//       route: _isEnabled(
//         json['route'],
//       ),
//       closeEvidence: _isEnabled(
//         json['close_evidence'],
//       ),
//       travelExpenses: _isEnabled(
//         json['travel_expenses'],
//       ),
//       downloadCcp: _isEnabled(
//         json['download_ccp'],
//       ),
//     );
//   }

//   static bool _isEnabled(
//     dynamic value,
//   ) {
//     if (value is! Map) {
//       return false;
//     }

//     return value['enabled'] == true;
//   }

//   factory ServiceActionsModel.empty() {
//     return const ServiceActionsModel(
//       checklist: false,
//       support: false,
//       route: false,
//       closeEvidence: false,
//       travelExpenses: false,
//       downloadCcp: false,
//     );
//   }
// }
