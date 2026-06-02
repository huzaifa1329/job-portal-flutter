import 'package:supabase_flutter/supabase_flutter.dart';
import '../modules/notification_model.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<NotificationModel>> getNotifications(
      String userId, String userType) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('user_type', userType)
          .order('created_at', ascending: false);

      return response.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      print('Get notifications error: $e');
      return [];
    }
  }

  Future<bool> createNotification({
    required String userId,
    required String userType,
    required String title,
    required String message,
    String? type,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'user_type': userType,
        'title': title,
        'message': message,
        'type': type ?? 'info',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
      return true;
    } catch (e) {
      print('Create notification error: $e');
      return false;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead(String userId, String userType) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('user_type', userType);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getUnreadCount(String userId, String userType) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('user_type', userType)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      return 0;
    }
  }
}
