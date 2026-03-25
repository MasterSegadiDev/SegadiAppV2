import 'package:segadi/features/ubications/data/datasources/movimientos_remote_datasource.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';
import 'package:segadi/features/ubications/domain/repositories/registro_movimiento_repository.dart';

class RegistroMovimientoRepositoryImpl implements RegistroMovimientoRepository {
  final RegistroMovimientoRemoteDataSource remoteDataSource;

  RegistroMovimientoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> registrar(MovimientoRegistro movimiento) {
    return remoteDataSource.enviar(movimiento);
  }
}
