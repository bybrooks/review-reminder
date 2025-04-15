import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase/supabase_service.dart';
import 'models/review_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.initializeSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Review Riminder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Review Riminder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isReminderToday(DateTime createdAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 登録から3日間は、毎日リマインド
    for (int i = 0; i <= 3; i++) {
      final scheduledDate = createdAt.add(Duration(days: i));
      final reminderDate =
          DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
      if (reminderDate == today) {
        return true;
      }
    }

    // 登録から5日目、7日目、10日目、14日目、21日目、30日目にリマインド
    final reminderDays = [5, 7, 10, 14, 21, 30];
    for (final day in reminderDays) {
      final scheduledDate = createdAt.add(Duration(days: day));
      final reminderDate =
          DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
      if (reminderDate == today) {
        return true;
      }
    }

    return false;
  }

  late Future<List<ReviewItem>> _reviewItemsFuture;

  @override
  void initState() {
    super.initState();
    _reviewItemsFuture = SupabaseService.getReviewItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String title = '';
              return AlertDialog(
                title: const Text('新しい復習項目'),
                content: TextField(
                  onChanged: (value) {
                    title = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('キャンセル'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      SupabaseService.addReviewItem(title);
                      setState(() {
                        _reviewItemsFuture = SupabaseService.getReviewItems();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('追加'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ReviewItem>>(
        future: _reviewItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final reviewItems = snapshot.data!
                .where((item) => isReminderToday(item.createdAt))
                .toList();
            return ListView.builder(
              itemCount: reviewItems.length,
              itemBuilder: (context, index) {
                final item = reviewItems[index];
                return CheckboxListTile(
                  title: Text(item.title),
                  subtitle: Text(item.createdAt.toString()),
                  value: item.isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      item.isCompleted = value!;
                      SupabaseService.updateReviewItem(
                          item.id, item.isCompleted);
                    });
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
