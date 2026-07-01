import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../model/document_model.dart';

class DocumentProvider extends ChangeNotifier {
  List<DocumentModel> documents = [];
  bool isLoading = false;
  bool isUploading = false;
  String? error;

  Future<void> fetchAll(int subjectId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.get('/subjects/$subjectId/documents');
      documents = (res.data['data'] as List)
          .map((e) => DocumentModel.fromJson(e))
          .toList();
    } catch (e) {
      error = _parseError(e, fallback: 'Không thể tải tài liệu');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upload(
    int subjectId, {
    required String fileName,
    String? filePath,
    Uint8List? bytes,
  }) async {
    isUploading = true;
    error = null;
    notifyListeners();

    try {
      // Debug info
      debugPrint('Uploading file: $fileName');
      debugPrint('Has bytes: ${bytes != null}, Has path: ${filePath != null}');
      
      final multipartFile = await _buildMultipartFile(
        fileName: fileName,
        filePath: filePath,
        bytes: bytes,
      );
      if (multipartFile == null) {
        error = 'Không đọc được file đã chọn. Thử chọn lại file.';
        return false;
      }

      debugPrint('MultipartFile created: ${multipartFile.filename}');

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      debugPrint('Sending upload request to /subjects/$subjectId/documents');

      final res = await ApiClient.dio.post(
        '/subjects/$subjectId/documents',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = (sent / total * 100).toStringAsFixed(0);
            debugPrint('Upload progress: $progress%');
          }
        },
      );

      debugPrint('Upload response: ${res.data}');

      if (res.data['success'] == true && res.data['data'] != null) {
        documents = [
          DocumentModel.fromJson(res.data['data']),
          ...documents,
        ];
        await fetchAll(subjectId);
        return true;
      } else {
        error = res.data['message'] ?? 'Tải tài liệu thất bại';
        return false;
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      
      // Try to parse error from response
      final responseData = e.response?.data;
      if (responseData is Map) {
        if (responseData['message'] != null) {
          error = responseData['message'].toString();
        } else if (responseData['error'] != null) {
          error = responseData['error'].toString();
        } else {
          error = _parseError(e, fallback: 'Tải tài liệu thất bại. Vui lòng thử lại.');
        }
      } else {
        error = _parseError(e, fallback: 'Tải tài liệu thất bại. Vui lòng thử lại.');
      }
      return false;
    } catch (e) {
      debugPrint('Upload error: $e');
      error = 'Đã xảy ra lỗi không mong muốn: $e';
      return false;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> delete(int subjectId, int id) async {
    try {
      await ApiClient.dio.delete('/subjects/$subjectId/documents/$id');
      documents.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = _parseError(e, fallback: 'Không thể xoá tài liệu');
      return false;
    }
  }

  Future<MultipartFile?> _buildMultipartFile({
    required String fileName,
    String? filePath,
    Uint8List? bytes,
  }) async {
    final contentType = _contentTypeFor(fileName);
    
    if (bytes != null && bytes.isNotEmpty) {
      debugPrint('Creating MultipartFile from bytes, size: ${bytes.length}');
      return MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: contentType,
      );
    }
    
    if (filePath != null && filePath.isNotEmpty) {
      debugPrint('Creating MultipartFile from path: $filePath');
      try {
        return MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: contentType,
        );
      } catch (e) {
        debugPrint('Error creating MultipartFile from path: $e');
      }
    }
    
    debugPrint('No bytes or path available for file upload');
    return null;
  }

  DioMediaType _contentTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return DioMediaType('application', 'pdf');
    if (lower.endsWith('.docx')) {
      return DioMediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    return DioMediaType('application', 'octet-stream');
  }

  String _parseError(dynamic e, {required String fallback}) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      // Check for Spring validation errors
      if (data is Map && data['errors'] != null) {
        return data['errors'].toString();
      }
      return e.message ?? fallback;
    }
    return fallback;
  }
}
