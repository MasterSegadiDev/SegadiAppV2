class UserEntity {
  final String id;
  final String username;
  final String name;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  const UserEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.roles,
    required this.permissions,
  });

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
