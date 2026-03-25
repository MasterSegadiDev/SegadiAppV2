// class RegistrarMovimientoUseCase {
//   final MovimientoRepository repository;
//   RegistrarMovimientoUseCase(this.repository);

//   Future<String> execute({
//     required UbicacionEntity origen,
//     required UbicacionEntity destino,
//     // required String userId,
//     //required String siteId,
//     //required String token,
//   }) async {
//     final user = UserSession();
//     final siteId = user.siteId;
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     // Validaciones de negocio antes de mandar al API
//     if (origen.id == destino.id)
//       throw Exception("El destino no puede ser igual al origen");

//     final movimiento = Movimientos(
//         crane_movement_id: null,
//         movement_type: 'Reacomodo',
//         crane_operator_id: user.id.toString(),
//         container_location_id: int.parse(origen.id),
//         new_container_location_id: destino.id,
//         container_number: origen.serie,
//         token: token,
//         site_id: siteId,
//         status: null,
//         weight: '',
//         document_name: '',
//         document: '');

//     // return await repository.registrarMovimiento(movimiento);

//     return 'exito';
//   }
// }

import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';
import 'package:segadi/features/ubications/domain/repositories/registro_movimiento_repository.dart';

class RegistrarMovimientoUseCase {
  final RegistroMovimientoRepository repository;

  RegistrarMovimientoUseCase(this.repository);

  Future<Map<String, dynamic>> execute(MovimientoRegistro movimiento) async {
    return await repository.registrar(movimiento);
  }
}
