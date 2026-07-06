import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../model/quiz_model.dart';

class QuizProvider extends ChangeNotifier {
  List<QuizModel> quizzes = [];
  QuizModel? currentQuiz;
  bool isLoading = false;
  bool isGenerating = false;
  String? error;

  Future<void> fetchAll() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiClient.dio.get('/quiz');
      quizzes = (res.data['data'] as List)
          .map((e) => QuizModel.fromJson(e))
          .toList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<QuizModel?> generate(int documentId, int questionCount, String difficulty) async {
    isGenerating = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.post(
        '/quiz/generate',
        data: {
          'documentId': documentId,
          'questionCount': questionCount,
          'difficulty': difficulty,
        },
        options: Options(receiveTimeout: const Duration(minutes: 3)),
      );
      final quiz = QuizModel.fromJson(res.data['data']);
      quizzes.insert(0, quiz);
      currentQuiz = quiz;
      notifyListeners();
      return quiz;
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          final msg = data['message'].toString().toLowerCase();
          if (msg.contains('token') || msg.contains('quota') || msg.contains('limit') || msg.contains('gemini') || msg.contains('ai')) {
            error = 'Dịch vụ AI tạm thời không khả dụng. Vui lòng thử lại sau.';
          } else {
            error = data['message'].toString();
          }
        } else if (e.response?.statusCode == 500) {
          error = 'Lỗi máy chủ. Vui lòng thử lại sau.';
        } else {
          error = e.message ?? 'Không thể tạo đề. Vui lòng thử lại.';
        }
      } else {
        error = 'Không thể tạo đề. Vui lòng thử lại.';
      }
      notifyListeners();
      return null;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}
