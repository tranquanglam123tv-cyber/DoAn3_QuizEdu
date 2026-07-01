import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../auth/provider/auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSaving = false;
  String? error;
  String? success;

  void _clear() {
    error = null;
    success = null;
  }

  Future<bool> updateProfile(AuthProvider auth, String fullName) async {
    _clear();
    isSaving = true;
    notifyListeners();
    try {
      final res = await ApiClient.dio.put('/users/profile', data: {'fullName': fullName});
      final updated = res.data['data'];
      if (auth.currentUser != null) {
        auth.updateCurrentUser(fullName: updated['fullName'] ?? fullName);
      }
      success = 'Cập nhật thành công!';
      return true;
    } catch (e) {
      error = _parseError(e);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _clear();
    isSaving = true;
    notifyListeners();
    try {
      await ApiClient.dio.put('/users/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      success = 'Đổi mật khẩu thành công!';
      return true;
    } catch (e) {
      error = _parseError(e);
      return false;
    } finally {
      isSaving = false;
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
