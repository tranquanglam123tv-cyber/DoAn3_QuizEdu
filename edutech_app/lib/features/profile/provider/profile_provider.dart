import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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

  Future<bool> updateProfile(
    AuthProvider auth,
    String fullName, {
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    _clear();
    isSaving = true;
    notifyListeners();
    try {
      final body = <String, dynamic>{'fullName': fullName};
      if (gender != null) body['gender'] = gender;
      String? dateStr;
      if (dateOfBirth != null) {
        dateStr =
            '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}';
        body['dateOfBirth'] = dateStr;
      }
      await ApiClient.dio.put('/users/profile', data: body);
      auth.updateCurrentUser(
        fullName: fullName,
        gender: gender,
        dateOfBirth: dateStr,
      );
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

  Future<String?> uploadAvatar(AuthProvider auth, dynamic imageFile) async {
    _clear();
    isLoading = true;
    notifyListeners();
    try {
      FormData formData;

      if (kIsWeb) {
        // For web: use bytes directly
        final bytes = await imageFile.readAsBytes();
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: imageFile.name),
        });
      } else {
        // For mobile: use file path
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          ),
        });
      }

      final res = await ApiClient.dio.post('/users/avatar', data: formData);
      final data = res.data;
      String? avatarUrl;
      if (data is Map) {
        avatarUrl = data['data'] as String?;
      }
      if (avatarUrl != null) {
        auth.updateCurrentUser(avatarUrl: avatarUrl);
      }
      isLoading = false;
      notifyListeners();
      return avatarUrl;
    } catch (e) {
      error = _parseError(e);
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _clear();
    isSaving = true;
    notifyListeners();
    try {
      await ApiClient.dio.put(
        '/users/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
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
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return data['message']?.toString() ?? 'Đã có lỗi xảy ra';
      }
      if (data is String) {
        return data;
      }
    }
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
