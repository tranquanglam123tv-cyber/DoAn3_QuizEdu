class ProfileModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String createdAt;

  ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'],
        email: json['email'],
        fullName: json['fullName'],
        role: json['role'],
        createdAt: json['createdAt'] ?? '',
      );
}
