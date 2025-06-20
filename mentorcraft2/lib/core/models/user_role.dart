enum UserRole {
  student,
  teacher,
  admin,
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.metadata,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.student,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role.toString().split('.').last,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
  bool get isAdmin => role == UserRole.admin;
}