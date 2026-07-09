class AuthModel {
  final String accessToken;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? gender;
  final String? dateOfBirth;

  AuthModel({
    required this.accessToken,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        accessToken: json['accessToken'] ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'STUDENT',
        avatarUrl: json['avatarUrl'],
        gender: json['gender'],
        dateOfBirth: json['dateOfBirth']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'fullName': fullName,
        'email': email,
        'role': role,
        'avatarUrl': avatarUrl,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
      };
}
