class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      phone: json['phone'],
      role: json['role'] ?? 'user',
    );
  }
}
