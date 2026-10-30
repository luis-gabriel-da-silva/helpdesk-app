class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String position;
  final String department;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.position,
    required this.department,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? 'Usuário',
      email: json['email'] ?? '',
      role: json['role'] ?? 'cliente',
      position: json['position'] ?? 'Não especificado',
      department: json['department'] ?? 'Geral',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'position': position,
      'department': department,
      'avatar_url': avatarUrl,
    };
  }
}
