class SummaryModel {
  final String overview;
  final List<String> keyPoints;

  SummaryModel({required this.overview, required this.keyPoints});

  factory SummaryModel.fromJson(Map<String, dynamic> json) => SummaryModel(
        overview: json['overview'] ?? '',
        keyPoints: List<String>.from(json['keyPoints'] as List? ?? []),
      );
}

class FlashcardItem {
  final String question;
  final String answer;

  FlashcardItem({required this.question, required this.answer});

  factory FlashcardItem.fromJson(Map<String, dynamic> json) => FlashcardItem(
        question: json['question'] ?? '',
        answer: json['answer'] ?? '',
      );
}

class FlashcardModel {
  final List<FlashcardItem> flashcards;

  FlashcardModel({required this.flashcards});

  factory FlashcardModel.fromJson(Map<String, dynamic> json) => FlashcardModel(
        flashcards: (json['flashcards'] as List? ?? [])
            .map((e) => FlashcardItem.fromJson(e))
            .toList(),
      );
}
