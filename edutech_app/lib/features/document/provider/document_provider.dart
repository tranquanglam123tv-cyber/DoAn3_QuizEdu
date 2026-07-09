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

  // Track selected documents for batch delete
  final Set<int> _selectedIds = {};
  Set<int> get selectedIds => Set.unmodifiable(_selectedIds);
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectionCount => _selectedIds.length;

  bool isSelected(int id) => _selectedIds.contains(id);

  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.addAll(documents.map((d) => d.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  List<DocumentModel> getSelectedDocuments() {
    return documents.where((d) => _selectedIds.contains(d.id)).toList();
  }

  Future<void> fetchAll(int subjectId) async {
    isLoading = true;
    error = null;
    clearSelection();
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

  // Check if file with same name already exists
  DocumentModel? findDuplicate(String fileName) {
    final lowerName = fileName.toLowerCase();
    try {
      return documents.firstWhere(
        (d) => d.fileName.toLowerCase() == lowerName,
      );
    } catch (_) {
      return null;
    }
  }

  // Get list of duplicate files
  List<DocumentModel> findDuplicates(List<String> fileNames) {
    final duplicates = <DocumentModel>[];
    for (final name in fileNames) {
      final dup = findDuplicate(name);
      if (dup != null) {
        duplicates.add(dup);
      }
    }
    return duplicates;
  }

  Future<bool> upload(
    int subjectId, {
    required String fileName,
    String? filePath,
    Uint8List? bytes,
    bool force = false,
  }) async {
    isUploading = true;
    error = null;
    notifyListeners();

    try {
      final multipartFile = await _buildMultipartFile(
        fileName: fileName,
        filePath: filePath,
        bytes: bytes,
      );
      if (multipartFile == null) {
        error = 'Không đọc được file đã chọn. Thử chọn lại file.';
        return false;
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
        if (force) 'force': true, // Override duplicate
      });

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

      if (res.data['success'] == true) {
        await fetchAll(subjectId);
        return true;
      } else {
        error = res.data['message'] ?? 'Tải tài liệu thất bại';
        return false;
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        if (responseData['message'] != null) {
          error = responseData['message'].toString();
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
      _selectedIds.remove(id);
      notifyListeners();
      return true;
    } catch (e) {
      error = _parseError(e, fallback: 'Không thể xoá tài liệu');
      return false;
    }
  }

  // Batch delete multiple documents
  Future<int> deleteBatch(int subjectId, List<int> ids) async {
    int deletedCount = 0;
    final errors = <String>[];

    for (final id in ids) {
      try {
        await ApiClient.dio.delete('/subjects/$subjectId/documents/$id');
        documents.removeWhere((d) => d.id == id);
        _selectedIds.remove(id);
        deletedCount++;
      } catch (e) {
        errors.add('ID $id: ${_parseError(e, fallback: "Lỗi")}');
      }
    }

    if (errors.isNotEmpty) {
      error = 'Xoá thành công $deletedCount/${ids.length}. ${errors.length} thất bại.';
    }

    notifyListeners();
    return deletedCount;
  }

  Future<MultipartFile?> _buildMultipartFile({
    required String fileName,
    String? filePath,
    Uint8List? bytes,
  }) async {
    final contentType = _contentTypeFor(fileName);
    
    if (bytes != null && bytes.isNotEmpty) {
      return MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: contentType,
      );
    }
    
    if (filePath != null && filePath.isNotEmpty) {
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
      if (data is Map && data['errors'] != null) {
        return data['errors'].toString();
      }
      return e.message ?? fallback;
    }
    return fallback;
  }
}
