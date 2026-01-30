import 'package:flutter/material.dart';
import '../../core/sky_widgets.dart';
import '../../core/theme.dart';
import '../../models/complaint.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for inbox (Supabase 'messages' table integration later)
    final messages = [
      {'title': 'Broken Fan', 'msg': 'Technician assigned.', 'time': '2h ago'},
      {'title': 'Leaking Tap', 'msg': 'We need more details regarding...', 'time': '1d ago'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Inbox'), backgroundColor: Colors.transparent),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final item = messages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.lightBlue,
                  child: const Icon(Icons.notifications, color: AppTheme.primaryBlue),
                ),
                title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['msg']!),
                trailing: Text(item['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ),
          );
        },
      ),
    );
  }
}
