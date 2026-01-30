import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/sky_widgets.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint.dart';
import 'complaint_detail_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const Center(child: Text('Please login'));

    final myComplaints = complaintProvider.getComplaintsForStudent(user.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('My Reports'), backgroundColor: Colors.transparent),
      body: myComplaints.isEmpty
          ? const Center(child: Text('No complaints submitted yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myComplaints.length,
              itemBuilder: (context, index) {
                final complaint = myComplaints[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ComplaintDetailScreen(complaintId: complaint.id)),
                      );
                    },
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(complaint.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            _StatusBadge(status: complaint.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(complaint.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              "${complaint.createdAt.day}/${complaint.createdAt.month}/${complaint.createdAt.year}",
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ComplaintStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ComplaintStatus.resolved: color = AppTheme.success; break;
      case ComplaintStatus.inProgress: color = AppTheme.warning; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
