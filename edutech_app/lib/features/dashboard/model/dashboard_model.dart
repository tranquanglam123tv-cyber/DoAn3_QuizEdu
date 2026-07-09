class DashboardModel {
  final int totalSubjects;
  final int totalDocuments;
  final int totalQuizzes;
  final int totalExams;
  final double averageScore;
  final int totalCorrectAnswers;
  final int totalAnswers;
  final List<SubjectStats> subjectStats;
  final List<DocumentStats> documentStats;

  DashboardModel({
    required this.totalSubjects,
    required this.totalDocuments,
    required this.totalQuizzes,
    required this.totalExams,
    required this.averageScore,
    required this.totalCorrectAnswers,
    required this.totalAnswers,
    this.subjectStats = const [],
    this.documentStats = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        totalSubjects: json['totalSubjects'],
        totalDocuments: json['totalDocuments'],
        totalQuizzes: json['totalQuizzes'],
        totalExams: json['totalExams'],
        averageScore: (json['averageScore'] as num).toDouble(),
        totalCorrectAnswers: json['totalCorrectAnswers'],
        totalAnswers: json['totalAnswers'],
        subjectStats: json['subjectStats'] != null
            ? (json['subjectStats'] as List).map((e) => SubjectStats.fromJson(e)).toList()
            : [],
        documentStats: json['documentStats'] != null
            ? (json['documentStats'] as List).map((e) => DocumentStats.fromJson(e)).toList()
            : [],
      );
}

class SubjectStats {
  final int subjectId;
  final String subjectName;
  final int totalExams;
  final int totalCorrect;
  final int totalQuestions;
  final double averageScore;

  SubjectStats({
    required this.subjectId,
    required this.subjectName,
    required this.totalExams,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.averageScore,
  });

  factory SubjectStats.fromJson(Map<String, dynamic> json) => SubjectStats(
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        totalExams: json['totalExams'],
        totalCorrect: json['totalCorrect'],
        totalQuestions: json['totalQuestions'],
        averageScore: (json['averageScore'] as num).toDouble(),
      );
}

class DocumentStats {
  final int documentId;
  final String documentName;
  final int subjectId;
  final String subjectName;
  final int totalExams;
  final int totalCorrect;
  final int totalQuestions;
  final double averageScore;

  DocumentStats({
    required this.documentId,
    required this.documentName,
    required this.subjectId,
    required this.subjectName,
    required this.totalExams,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.averageScore,
  });

  factory DocumentStats.fromJson(Map<String, dynamic> json) => DocumentStats(
        documentId: json['documentId'],
        documentName: json['documentName'],
        subjectId: json['subjectId'] ?? 0,
        subjectName: json['subjectName'] ?? '',
        totalExams: json['totalExams'],
        totalCorrect: json['totalCorrect'],
        totalQuestions: json['totalQuestions'],
        averageScore: (json['averageScore'] as num).toDouble(),
      );
}
