import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: const Color(0xFFEF3A16),
      ),
      body: ListView.separated(
        itemCount: 12,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) => ListTile(
          leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFFEF3A16)),
          title: Text('Thông báo ${i + 1}'),
          subtitle: const Text('2 phút trước'),
          onTap: () {},
        ),
      ),
    );
  }
}


