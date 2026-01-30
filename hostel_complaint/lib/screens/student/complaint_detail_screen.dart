import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    final complaint = Provider.of<ComplaintProvider>(context)
        .complaints
        .firstWhere((c) => c.id == complaintId, orElse: () => throw Exception('Complaint not found'));

    return Scaffold(
      appBar: AppBar(
        title: Text(complaint.id),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(complaint.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(complaint.status).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _getStatusColor(complaint.status)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                      Text(
                        _getStatusText(complaint.status),
                        style: TextStyle(
                            color: _getStatusColor(complaint.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details
            Text(
              complaint.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
             Row(
              children: [
                _DetailChip(label: complaint.category.name.toUpperCase(), icon: Icons.category),
                const SizedBox(width: 8),
                _DetailChip(label: complaint.urgency.name.toUpperCase(), icon: Icons.priority_high),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              complaint.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Timeline / Updates
            Text(
              'Updates & History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (complaint.updates.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No updates yet.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...complaint.updates.map((update) => _UpdateItem(update: update)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending: return Colors.orange;
      case ComplaintStatus.inProgress: return Colors.blue;
      case ComplaintStatus.resolved: return Colors.green;
    }
  }

  String _getStatusText(ComplaintStatus status) {
     switch (status) {
      case ComplaintStatus.pending: return 'Pending';
      case ComplaintStatus.inProgress: return 'In Progress';
      case ComplaintStatus.resolved: return 'Resolved';
    }
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _DetailChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _UpdateItem extends StatelessWidget {
  final ComplaintUpdate update;

  const _UpdateItem({required this.update});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${update.senderName} (${update.senderRole})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                 "${update.timestamp.hour}:${update.timestamp.minute}",
                 style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(update.message),
        ],
      ),
    );
  }
}
