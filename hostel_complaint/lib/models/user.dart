enum UserRole {
  student,
  warden,
  admin,
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? roomNumber; // Only for students
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.roomNumber,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['full_name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: _parseRole(json['role'] as String?),
      roomNumber: json['room_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'role': role.name,
      'room_number': roomNumber,
      'avatar_url': avatarUrl,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'warden': return UserRole.warden;
      case 'admin': return UserRole.admin;
      default: return UserRole.student;
    }
  }
}
