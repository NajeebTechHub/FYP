import '../core/models/user_role.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime createdAt;
  final bool isEmailVerified;
  final String avatar;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.isEmailVerified = false,
    this.avatar = '',
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      id: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: UserRole.values.firstWhere(
            (role) => role.toString().split('.').last == data['role'],
        orElse: () => UserRole.student,
      ),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      avatar: data['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.toString().split('.').last,
      'createdAt': createdAt,
      'isEmailVerified': isEmailVerified,
      'avatar': avatar,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? avatar,
  }) {
    return AppUser(
      id: uid ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      avatar: avatar ?? this.avatar,
    );
  }
}
