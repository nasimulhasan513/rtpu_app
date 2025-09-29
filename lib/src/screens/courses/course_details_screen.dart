import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E86FF)]),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.star_rate_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('লাইভ মডেল টেস্ট • ব্যাখ্যাসহ উত্তর • দৈনিক কুইজ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('What you will get', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const _Bullet(text: '📝 নিয়মিত Live Model Test'),
            const _Bullet(text: '📚 Subject wise MCQ Practice'),
            const _Bullet(text: '💡 সঠিক উত্তর ও ব্যাখ্যা'),
            const _Bullet(text: '🔥 দৈনিক কুইজ এবং লিডারবোর্ড'),
            const _Bullet(text: '📊 পারফরম্যান্স ট্র্যাকিং'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Enroll Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

