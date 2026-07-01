class DocumentModel {
  final int id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final int subjectId;
  final String createdAt;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.subjectId,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json['id'],
        fileName: json['fileName'],
        fileType: json['fileType'],
        fileSize: json['fileSize'],
        subjectId: json['subjectId'],
        createdAt: json['createdAt'],
      );

  String get fileSizeText {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
