import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ts_autoparts_app/utils/secure_storage.dart';
import 'package:ts_autoparts_app/constant/const.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      debugPrint('Fetching notifications from: $baseUrl/api/notifications');
      debugPrint('Using token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          debugPrint('No notifications found');
          return [];
        }

        return data.map<Map<String, dynamic>>((notification) {
          try {
            return {
              'id': notification['id'] ?? '',
              'type': _getNotificationType(notification['type'] ?? ''),
              'title': _getNotificationTitle(notification['data'] ?? {}),
              'message': _getNotificationMessage(notification['data'] ?? {}),
              'data': notification['data'] ?? {},
              'read_at': notification['read_at'],
              'created_at': notification['created_at'],
            };
          } catch (e) {
            debugPrint('Error processing notification: $e');
            debugPrint('Problematic notification: $notification');
            return {
              'id': notification['id'] ?? '',
              'type': 'error',
              'title': 'Error',
              'message': 'Could not process notification',
              'data': {},
              'read_at': null,
              'created_at': notification['created_at'] ?? DateTime.now().toIso8601String(),
            };
          }
        }).toList();
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized access: Token might be invalid or expired');
        throw Exception('Unauthorized: Please login again');
      } else {
        debugPrint('Failed to fetch notifications: ${response.statusCode}');
        debugPrint('Error response: ${response.body}');
        throw Exception('Failed to fetch notifications: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getNotifications: $e');
      rethrow;
    }
  }

  String _getNotificationType(String fullType) {
    // Convert Laravel notification type to our simple type
    if (fullType.contains('OrderStatus')) return 'order';
    if (fullType.contains('AppointmentStatus')) return 'appointment';
    return 'general';
  }

  String _getNotificationTitle(Map<String, dynamic> data) {
    if (data.containsKey('order_id')) return 'Order Update';
    if (data.containsKey('appointment_id')) return 'Appointment Update';
    return 'Notification';
  }

  String _getNotificationMessage(Map<String, dynamic> data) {
    return data['message'] ?? 'No message provided';
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }
} 