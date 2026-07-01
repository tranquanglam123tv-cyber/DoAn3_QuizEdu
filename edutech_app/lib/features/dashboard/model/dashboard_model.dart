class DashboardModel {
  final int totalSubjects;
  final int totalDocuments;
  final int totalQuizzes;
  final int totalExams;
  final double averageScore;
  final int totalCorrectAnswers;
  final int totalAnswers;

  DashboardModel({
    required this.totalSubjects,
    required this.totalDocuments,
    required this.totalQuizzes,
    required this.totalExams,
    required this.averageScore,
    required this.totalCorrectAnswers,
    required this.totalAnswers,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        totalSubjects: json['totalSubjects'],
        totalDocuments: json['totalDocuments'],
        totalQuizzes: json['totalQuizzes'],
        totalExams: json['totalExams'],
        averageScore: (json['averageScore'] as num).toDouble(),
        totalCorrectAnswers: json['totalCorrectAnswers'],
        totalAnswers: json['totalAnswers'],
      );
}
