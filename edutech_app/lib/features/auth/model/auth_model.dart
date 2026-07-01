class AuthModel {
  final String accessToken;
  final String fullName;
  final String email;
  final String role;

  AuthModel({
    required this.accessToken,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    accessToken: json['accessToken'],
    fullName: json['fullName'],
    email: json['email'],
    role: json['role'],
  );
}
