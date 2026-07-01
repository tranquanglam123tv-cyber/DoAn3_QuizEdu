import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../model/exam_model.dart';

class ExamProvider extends ChangeNotifier {
  ExamModel? currentExam;
  List<ExamModel> history = [];
  bool isLoading = false;
  String? error;
  Map<int, int> selectedAnswers = {}; // questionId -> choiceId

  void selectAnswer(int questionId, int choiceId) {
    selectedAnswers[questionId] = choiceId;
    notifyListeners();
  }

  Future<ExamModel?> start(int quizId) async {
    isLoading = true;
    error = null;
    selectedAnswers = {};
    notifyListeners();
    try {
      final res = await ApiClient.dio.post('/exam/start/$quizId');
      currentExam = ExamModel.fromJson(res.data['data']);
      notifyListeners();
      return currentExam;
    } catch (e) {
      error = 'Không thể bắt đầu bài thi. Vui lòng thử lại.';
      notifyListeners();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ExamModel?> submit() async {
    if (currentExam == null) return null;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final answers = selectedAnswers.entries
          .map((e) => {'questionId': e.key, 'selectedChoiceId': e.value})
          .toList();

      final res = await ApiClient.dio.post('/exam/submit', data: {
        'examId': currentExam!.id,
        'answers': answers,
      });
      currentExam = ExamModel.fromJson(res.data['data']);
      notifyListeners();
      return currentExam;
    } catch (e) {
      error = 'Không thể nộp bài. Vui lòng thử lại.';
      notifyListeners();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.get('/exam/history');
      history = (res.data['data'] as List)
          .map((e) => ExamModel.fromJson(e))
          .toList();
    } catch (e) {
      error = 'Không thể tải lịch sử bài thi.';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
