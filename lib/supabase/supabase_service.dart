import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/notification_service.dart';
import '../models/review_item.dart';

class SupabaseService {
  static const String tableName = 'review_items';

  static Future<void> initializeSupabase() async {
    const supabaseUrl =
        String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const supabaseAnonKey =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (supabaseUrl == "" || supabaseAnonKey == "") {
      throw Exception('Supabase URL or Anon Key is not set in .env file');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<List<ReviewItem>> getReviewItems() async {
    final response = await client
        .from(tableName)
        .select()
        .order('created_at', ascending: false);
    final List<dynamic> data = response;
    return data.map((json) => ReviewItem.fromJson(json)).toList();
  }

  static Future<void> addReviewItem(String title) async {
    await client.from(tableName).insert({
      'title': title,
      'created_at': DateTime.now().toIso8601String(),
      'is_completed': false,
    });
  }

  static Future<void> scheduleReminders(
      String title, DateTime createdAt) async {
    // 登録から3日間は、毎日リマインド
    for (int i = 1; i <= 3; i++) {
      final scheduledDate = createdAt.add(Duration(days: i));
      await NotificationService.scheduleNotification(
        title,
        '復習してください',
        scheduledDate,
      );
    }

    // 登録から5日目、7日目、10日目、14日目、21日目、30日目にリマインド
    final reminderDays = [5, 7, 10, 14, 21, 30];
    for (final day in reminderDays) {
      final scheduledDate = createdAt.add(Duration(days: day));
      await NotificationService.scheduleNotification(
        title,
        '復習してください',
        scheduledDate,
      );
    }
  }

  static Future<void> updateReviewItem(String id, bool isCompleted) async {
    await client
        .from(tableName)
        .update({'is_completed': isCompleted}).eq('id', id);
  }
}
