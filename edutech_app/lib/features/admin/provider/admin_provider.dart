import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../model/admin_model.dart';

class AdminProvider extends ChangeNotifier {
  List<AdminUserModel> users = [];
  List<AdminDocumentModel> documents = [];
  AdminDashboardModel? dashboard;
  bool isLoadingUsers = false;
  bool isLoadingDashboard = false;
  bool isLoadingDocuments = false;
  String? error;

  Future<void> fetchUsers() async {
    isLoadingUsers = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.get('/admin/users');
      final list = res.data['data'] as List;
      users = list.map((e) => AdminUserModel.fromJson(e)).toList();
    } catch (e) {
      error = _parseError(e);
    } finally {
      isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboard() async {
    isLoadingDashboard = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.get('/dashboard/admin');
      dashboard = AdminDashboardModel.fromJson(res.data['data']);
    } catch (e) {
      error = _parseError(e);
    } finally {
      isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<bool> lockUser(int userId) async {
    try {
      await ApiClient.dio.put('/admin/users/$userId/lock');
      final idx = users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        users[idx] = users[idx].copyWith(locked: true);
        notifyListeners();
      }
      return true;
    } catch (e) {
      error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> unlockUser(int userId) async {
    try {
      await ApiClient.dio.put('/admin/users/$userId/unlock');
      final idx = users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        users[idx] = users[idx].copyWith(locked: false);
        notifyListeners();
      }
      return true;
    } catch (e) {
      error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(int documentId) async {
    try {
      await ApiClient.dio.delete('/admin/documents/$documentId');
      documents.removeWhere((d) => d.id == documentId);
      notifyListeners();
      return true;
    } catch (e) {
      error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchDocuments() async {
    isLoadingDocuments = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.get('/admin/documents');
      documents = (res.data['data'] as List)
          .map((e) => AdminDocumentModel.fromJson(e))
          .toList();
    } catch (e) {
      error = _parseError(e);
    } finally {
      isLoadingDocuments = false;
      notifyListeners();
    }
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('"message":"')) {
        try {
          final start = msg.indexOf('"message":"') + 11;
          final end = msg.indexOf('"', start);
          return msg.substring(start, end);
        } catch (_) {}
      }
    }
    return 'Đã có lỗi xảy ra';
  }
}
