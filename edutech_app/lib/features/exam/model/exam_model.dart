class AnswerResultModel {
  final int questionId;
  final String questionContent;
  final String selectedChoice;
  final String correctChoice;
  final String explanation;
  final bool correct;

  AnswerResultModel({
    required this.questionId,
    required this.questionContent,
    required this.selectedChoice,
    required this.correctChoice,
    required this.explanation,
    required this.correct,
  });

  factory AnswerResultModel.fromJson(Map<String, dynamic> json) =>
      AnswerResultModel(
        questionId: json['questionId'] ?? 0,
        questionContent: json['questionContent'] ?? '',
        selectedChoice: json['selectedChoice'] ?? '',
        correctChoice: json['correctChoice'] ?? '',
        explanation: json['explanation'] ?? '',
        correct: json['correct'] ?? false,
      );
}

class ExamModel {
  final int id;
  final int quizId;
  final String quizName;
  final String difficulty;
  final String status;
  final int totalQuestions;
  final int correctCount;
  final double score;
  final String startedAt;
  final String? submittedAt;
  final List<AnswerResultModel>? answers;

  ExamModel({
    required this.id,
    required this.quizId,
    required this.quizName,
    required this.difficulty,
    required this.status,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
    required this.startedAt,
    this.submittedAt,
    this.answers,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) => ExamModel(
        id: json['id'],
        quizId: json['quizId'],
        quizName: json['quizName'] ?? '',
        difficulty: json['difficulty'] ?? 'MEDIUM',
        status: json['status'],
        totalQuestions: json['totalQuestions'],
        correctCount: json['correctCount'],
        score: (json['score'] as num).toDouble(),
        startedAt: json['startedAt'],
        submittedAt: json['submittedAt'],
        answers: json['answers'] != null
            ? (json['answers'] as List)
                .map((e) => AnswerResultModel.fromJson(e))
                .toList()
            : null,
      );

  bool get isPassed => score >= 5.0;
  String get difficultyLabel {
    switch (difficulty) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return difficulty;
    }
  }
}
