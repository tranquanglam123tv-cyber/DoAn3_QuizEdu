import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../model/subject_model.dart';

class SubjectProvider extends ChangeNotifier {
  List<SubjectModel> subjects = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchAll() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await ApiClient.dio.get('/subjects');
      subjects = (res.data['data'] as List)
          .map((e) => SubjectModel.fromJson(e))
          .toList();
    } catch (e) {
      error = 'Không thể tải môn học';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String name, String description) async {
    try {
      final res = await ApiClient.dio.post('/subjects', data: {
        'name': name,
        'description': description,
      });
      subjects.add(SubjectModel.fromJson(res.data['data']));
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> update(int id, String name, String description) async {
    try {
      final res = await ApiClient.dio.put('/subjects/$id', data: {
        'name': name,
        'description': description,
      });
      final updated = SubjectModel.fromJson(res.data['data']);
      final idx = subjects.indexWhere((s) => s.id == id);
      if (idx != -1) {
        subjects[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await ApiClient.dio.delete('/subjects/$id');
      subjects.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
