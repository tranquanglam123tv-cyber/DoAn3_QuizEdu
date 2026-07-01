class AdminUserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool locked;
  final String? createdAt;

  AdminUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.locked,
    this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
        id: json['id'],
        email: json['email'] ?? '',
        fullName: json['fullName'] ?? '',
        role: json['role'] ?? 'USER',
        locked: json['locked'] ?? false,
        createdAt: json['createdAt'],
      );

  AdminUserModel copyWith({bool? locked}) => AdminUserModel(
        id: id,
        email: email,
        fullName: fullName,
        role: role,
        locked: locked ?? this.locked,
        createdAt: createdAt,
      );
}

class AdminDocumentModel {
  final int id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final int subjectId;

  AdminDocumentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.subjectId,
  });

  factory AdminDocumentModel.fromJson(Map<String, dynamic> json) =>
      AdminDocumentModel(
        id: json['id'],
        fileName: json['fileName'] ?? '',
        fileType: json['fileType'] ?? '',
        fileSize: json['fileSize'] ?? 0,
        subjectId: json['subjectId'] ?? 0,
      );

  String get fileSizeText {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class AdminDashboardModel {
  final int totalUsers;
  final int totalSubjects;
  final int totalDocuments;
  final int totalQuizzes;
  final int totalExams;

  AdminDashboardModel({
    required this.totalUsers,
    required this.totalSubjects,
    required this.totalDocuments,
    required this.totalQuizzes,
    required this.totalExams,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) => AdminDashboardModel(
        totalUsers: (json['totalUsers'] ?? 0) as int,
        totalSubjects: (json['totalSubjects'] ?? 0) as int,
        totalDocuments: (json['totalDocuments'] ?? 0) as int,
        totalQuizzes: (json['totalQuizzes'] ?? 0) as int,
        totalExams: (json['totalExams'] ?? 0) as int,
      );
}
