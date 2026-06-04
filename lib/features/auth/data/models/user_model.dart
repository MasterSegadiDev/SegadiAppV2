import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    required super.roles,
    required super.permissions,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(
        json['roles'] ?? [],
      ),
      permissions: List<String>.from(
        json['permissions'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'roles': roles,
      'permissions': permissions,
    };
  }
}
