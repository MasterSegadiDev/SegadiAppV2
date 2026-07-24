import '../../domain/entities/user_profile_entity.dart';

enum UserProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

class UserProfileState {
  final UserProfileStatus status;
  final UserProfileEntity? profile;
  final String? errorMessage;

  const UserProfileState({
    required this.status,
    this.profile,
    this.errorMessage,
  });

  factory UserProfileState.initial() {
    return const UserProfileState(
      status: UserProfileStatus.initial,
    );
  }

  factory UserProfileState.loading() {
    return const UserProfileState(
      status: UserProfileStatus.loading,
    );
  }

  factory UserProfileState.loaded(
    UserProfileEntity profile,
  ) {
    return UserProfileState(
      status: UserProfileStatus.loaded,
      profile: profile,
    );
  }

  factory UserProfileState.error({
    required String errorMessage,
  }) {
    return UserProfileState(
      status: UserProfileStatus.error,
      errorMessage: errorMessage,
    );
  }

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfileEntity? profile,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
