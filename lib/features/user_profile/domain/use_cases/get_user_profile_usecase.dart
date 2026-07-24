import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfileUseCase {
  final UserProfileRepository repository;

  GetUserProfileUseCase(
    this.repository,
  );

  Future<UserProfileEntity> call({
    required String userId,
  }) {
    return repository.getUserProfile(
      userId: userId,
    );
  }
}