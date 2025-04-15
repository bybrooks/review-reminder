import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewItem {
  final String id;
  final String title;
  final DateTime createdAt;
  bool isCompleted;

  ReviewItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.isCompleted,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      isCompleted: json['is_completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}
