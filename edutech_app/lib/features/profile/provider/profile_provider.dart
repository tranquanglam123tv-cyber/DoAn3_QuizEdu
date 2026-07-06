import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../auth/provider/auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSaving = false;
  String? error;
  String? success;
  String? uploadedAvatarUrl;

  void _clear() {
    error = null;
    success = null;
    uploadedAvatarUrl = null;
  }

  Future<bool> uploadAvatar(AuthProvider auth, XFile image) async {
    _clear();
    isSaving = true;
    notifyListeners();
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: image.name),
      });
      final res = await ApiClient.dio.post('/users/avatar', data: formData);
      final url = res.data['data'] as String;
      uploadedAvatarUrl = url;
      auth.updateCurrentUser(avatarUrl: url);
      success = 'Cập nhật ảnh thành công!';
      return true;
    } catch (e) {
      error = _parseError(e);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(
    AuthProvider auth,
    String fullName, {
    String? avatarUrl,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    _clear();
    isSaving = true;
    notifyListeners();
    try {
      final body = <String, dynamic>{'fullName': fullName};
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
      if (gender != null) body['gender'] = gender;
      if (dateOfBirth != null) {
        body['dateOfBirth'] = '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}';
      }
      final res = await ApiClient.dio.put('/users/profile', data: body);
      final updated = res.data['data'];
      if (auth.currentUser != null) {
        auth.updateCurrentUser(
          fullName: updated['fullName'] ?? fullName,
          avatarUrl: updated['avatarUrl'],
          gender: updated['gender'],
          dateOfBirth: updated['dateOfBirth'],
        );
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
