import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';

import '../datasources/user_profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDatasource datasource;

  UserProfileRepositoryImpl(
    this.datasource,
  );

  @override
  Future<UserProfileEntity> getUserProfile({
    required String userId,
  }) async {
    final response = await datasource.getUserProfile(
      userId: userId,
    );

    final result = response['Result'] as Map<String, dynamic>;

    return UserProfileModel.fromJson(result);
  }
}
