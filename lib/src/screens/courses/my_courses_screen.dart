import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.status != AuthStatus.authenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Sign in to view your courses'),
        ),
      );
    }
    // Placeholder enrolled list
    final enrolled = [
      {'title': 'ঢাবি তুফান ব্যাচ + CU,RU,GST,JU,JNU', 'progress': 0.42},
      {'title': '2nd Timer B Unit 2025 | All in One', 'progress': 0.15},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enrolled.length,
        itemBuilder: (context, index) {
          final item = enrolled[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] as String, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (item['progress'] as double),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 6),
                  Text('Progress ${(100 * (item['progress'] as double)).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

