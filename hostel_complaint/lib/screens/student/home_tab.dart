import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/sky_widgets.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
       // Should technically not happen if Auth guard works, but safe handle
       return const Center(child: CircularProgressIndicator()); 
    }

    // Refresh Logic (Simple)
    if (complaintProvider.complaints.isEmpty && !complaintProvider.isLoading) {
       Future.microtask(() => complaintProvider.fetchComplaints());
    }

    final myComplaints = complaintProvider.getComplaintsForStudent(user.id);
    final total = myComplaints.length;
    final pending = myComplaints.where((c) => c.status == ComplaintStatus.pending).length;
    final resolved = myComplaints.where((c) => c.status == ComplaintStatus.resolved).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: TextStyle(color: AppTheme.textSecondary)),
                        Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.lightBlue,
                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                      child: user.avatarUrl == null ? const Icon(Icons.person, color: AppTheme.primaryBlue) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Carousel
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Total', count: total.toString(), color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Pending', count: pending.toString(), color: AppTheme.warning)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Resolved', count: resolved.toString(), color: AppTheme.success)),
                ],
              ),
              const SizedBox(height: 24),

              // CTA
              ElevatedButton(
                onPressed: () { 
                   // Logic to switch tab or show modal
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Quick Report Issue', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ).animate().shimmer(delay: 1.seconds, duration: 1.seconds),

              const SizedBox(height: 32),
              
              const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              if (myComplaints.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No recent activity')))
              else
                ...myComplaints.take(3).map((c) => _ActivityItem(complaint: c)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String count;
  final Color color;

  const _StatCard({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Complaint complaint;
  const _ActivityItem({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.build, color: AppTheme.primaryBlue, size: 20), // Placeholder icon logic
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(complaint.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    complaint.status.name.toUpperCase(), 
                    style: TextStyle(
                      fontSize: 10, 
                      color: complaint.status == ComplaintStatus.resolved ? AppTheme.success : AppTheme.warning
                    )
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
