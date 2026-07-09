import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class ContactResponse {
  final int id;
  final String userName;
  final String email;
  final String subject;
  final String message;
  final String status;
  final String? adminResponse;
  final String? respondedAt;
  final String createdAt;

  ContactResponse({
    required this.id,
    required this.userName,
    required this.email,
    required this.subject,
    required this.message,
    required this.status,
    this.adminResponse,
    this.respondedAt,
    required this.createdAt,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      id: json['id'],
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'PENDING',
      adminResponse: json['adminResponse'],
      respondedAt: json['respondedAt'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isResponded => status == 'RESPONDED';
  bool get isClosed => status == 'CLOSED';
}

class ContactProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<ContactResponse> contacts = [];

  Future<bool> createContact(String userName, String subject, String message) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await ApiClient.dio.post('/contact', data: {
        'userName': userName,
        'subject': subject,
        'message': message,
      });
      await fetchContacts();
      return true;
    } catch (e) {
      debugPrint('Create contact error: $e');
      error = _parseError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchContacts() async {
    try {
      final res = await ApiClient.dio.get('/contact');
      final List data = res.data['data'];
      contacts = data.map((e) => ContactResponse.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch contacts error: $e');
    }
  }

  String _parseError(dynamic e) {
    try {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          return data['message']?.toString() ?? 'Đã có lỗi xảy ra';
        }
      }
    } catch (_) {}
    return 'Đã có lỗi xảy ra';
  }
}
