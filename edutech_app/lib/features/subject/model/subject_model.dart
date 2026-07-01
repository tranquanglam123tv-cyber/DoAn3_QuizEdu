class SubjectModel {
  final int id;
  final String name;
  final String? description;
  final String createdAt;

  SubjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        createdAt: json['createdAt'],
      );
}
