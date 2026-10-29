class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'cliente' ou 'tecnico'
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
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      position: json['position'] as String? ?? 'Não informado',
      department: json['department'] as String? ?? 'Geral',
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
