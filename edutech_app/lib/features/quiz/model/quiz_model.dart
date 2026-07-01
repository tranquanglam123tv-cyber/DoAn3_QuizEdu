class ChoiceModel {
  final int id;
  final String content;
  final bool correct;

  ChoiceModel({required this.id, required this.content, required this.correct});

  factory ChoiceModel.fromJson(Map<String, dynamic> json) => ChoiceModel(
        id: json['id'],
        content: json['content'],
        correct: json['correct'],
      );
}

class QuestionModel {
  final int id;
  final String content;
  final String explanation;
  final List<ChoiceModel> choices;

  QuestionModel({
    required this.id,
    required this.content,
    required this.explanation,
    required this.choices,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'],
        content: json['content'],
        explanation: json['explanation'],
        choices: (json['choices'] as List)
            .map((e) => ChoiceModel.fromJson(e))
            .toList(),
      );
}

class QuizModel {
  final int id;
  final int documentId;
  final int questionCount;
  final String difficulty;
  final String createdAt;
  final List<QuestionModel> questions;

  QuizModel({
    required this.id,
    required this.documentId,
    required this.questionCount,
    required this.difficulty,
    required this.createdAt,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
        id: json['id'],
        documentId: json['documentId'],
        questionCount: json['questionCount'],
        difficulty: json['difficulty'],
        createdAt: json['createdAt'],
        questions: (json['questions'] as List? ?? [])
            .map((e) => QuestionModel.fromJson(e))
            .toList(),
      );
}
