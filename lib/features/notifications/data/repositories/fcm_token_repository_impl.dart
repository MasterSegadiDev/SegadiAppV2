import '../../domain/repositories/fcm_token_repository.dart';
import '../datasources/fcm_token_remote_datasource.dart';

class FcmTokenRepositoryImpl implements FcmTokenRepository {
  final FcmTokenRemoteDatasource remoteDatasource;

  FcmTokenRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<void> registerToken(String token) {
    return remoteDatasource.registerToken(token);
  }
}
