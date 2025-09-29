import 'package:flutter/material.dart';

import 'course_details_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data inspired by the site
    final courses = [
      {'title': 'BUP FBS & CU C UNIT', 'price': '৳2050', 'duration': '9 মাস'},
      {'title': 'ঢাবি তুফান ব্যাচ + CU,RU,GST,JU,JNU', 'price': '৳3500', 'duration': '6 মাস'},
      {'title': '2nd Timer B Unit 2025 | All in One', 'price': '৳4500', 'duration': '9 মাস'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CourseDetailsScreen(title: course['title']!),
                ),
              ),
              child: _CourseCard(
                title: course['title']!,
                price: course['price']!,
                duration: course['duration']!,
                tag: index == 0 ? 'Popular' : (index == 1 ? 'Best Value' : 'New'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.title, required this.price, required this.duration, required this.tag});
  final String title;
  final String price;
  final String duration;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E86FF)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Chip(label: Text(duration), avatar: const Icon(Icons.schedule, size: 18)),
                    const SizedBox(width: 8),
                    Chip(label: Text(price), avatar: const Icon(Icons.currency_exchange, size: 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

