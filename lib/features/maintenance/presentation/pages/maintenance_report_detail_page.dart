// import 'package:flutter/material.dart';
// import 'maintenance_reports_page.dart';

// class MaintenanceReportDetailPage extends StatelessWidget {
//   const MaintenanceReportDetailPage({super.key, required this.report});
//   final MaintenanceReportItem report;

//   String dateText(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8F6),
//       appBar: AppBar(
//         title: const Text('Detalle del reporte'),
//         backgroundColor: const Color(0xFF101812),
//         foregroundColor: Colors.white,
//       ),
//       body: ListView(padding: const EdgeInsets.all(16), children: [
//         _Panel(
//             title: report.code,
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               _InfoRow('Estatus', report.status),
//               _InfoRow('Unidad', report.unit),
//               _InfoRow('Fecha del incidente', dateText(report.date)),
//               if (report.requestedBy.isNotEmpty)
//                 _InfoRow('Solicitado por', report.requestedBy),
//             ])),
//         const SizedBox(height: 14),
//         _Panel(
//             title: 'Descripción del problema', child: Text(report.description)),
//         if (report.observation.isNotEmpty) ...[
//           const SizedBox(height: 14),
//           _Panel(title: 'Observaciones', child: Text(report.observation)),
//         ],
//         const SizedBox(height: 14),
//         _Panel(
//             title: 'Clasificación',
//             child: Column(children: [
//               _InfoRow('Prioridad', report.priority),
//               _InfoRow('Clasificación', report.classification1),
//               _InfoRow('Subclasificación', report.classification2),
//             ])),
//         const SizedBox(height: 14),
//         _Panel(
//             title: 'Evidencia fotográfica',
//             child: report.evidenceUrls.isEmpty
//                 ? const Text('Este reporte no tiene fotografías adjuntas.',
//                     style: TextStyle(color: Colors.black54))
//                 : SizedBox(
//                     height: 112,
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: report.evidenceUrls.length,
//                       separatorBuilder: (_, __) => const SizedBox(width: 10),
//                       itemBuilder: (context, i) => ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                           report.evidenceUrls[i],
//                           width: 112,
//                           height: 112,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => const SizedBox(
//                               width: 112,
//                               height: 112,
//                               child: Icon(Icons.broken_image_outlined)),
//                         ),
//                       ),
//                     ))),
//       ]),
//     );
//   }
// }

// class _Panel extends StatelessWidget {
//   const _Panel({required this.title, required this.child});
//   final String title;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) => Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             color: Colors.white, borderRadius: BorderRadius.circular(14)),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(title,
//               style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF17231A))),
//           const SizedBox(height: 12),
//           child,
//         ]),
//       );
// }

// class _InfoRow extends StatelessWidget {
//   const _InfoRow(this.label, this.value);
//   final String label, value;

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           SizedBox(
//               width: 125,
//               child: Text(label,
//                   style: const TextStyle(color: Colors.black54, fontSize: 13))),
//           Expanded(
//               child: Text(value.isEmpty ? 'No especificado' : value,
//                   style: const TextStyle(fontWeight: FontWeight.w600))),
//         ]),
//       );
// }
