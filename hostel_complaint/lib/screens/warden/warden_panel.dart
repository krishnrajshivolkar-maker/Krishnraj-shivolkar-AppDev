import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/sky_widgets.dart';
import '../../core/theme.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint.dart';

class WardenPanel extends StatefulWidget {
  const WardenPanel({super.key});

  @override
  State<WardenPanel> createState() => _WardenPanelState();
}

class _WardenPanelState extends State<WardenPanel> {
  String _searchQuery = '';
  ComplaintStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    List<Complaint> complaints = complaintProvider.complaints;

    // Filter Logic
    if (_filterStatus != null) {
      complaints = complaints.where((c) => c.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      complaints = complaints.where((c) => 
        c.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
        c.roomNumber.contains(_searchQuery)
      ).toList();
    }

    return Scaffold(
      body: SkyBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassCard(
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search by title or room...',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All', 
                            isSelected: _filterStatus == null,
                            onTap: () => setState(() => _filterStatus = null)
                          ),
                          _FilterChip(
                            label: 'Pending', 
                            isSelected: _filterStatus == ComplaintStatus.pending,
                            onTap: () => setState(() => _filterStatus = ComplaintStatus.pending)
                          ),
                          _FilterChip(
                            label: 'In Progress', 
                            isSelected: _filterStatus == ComplaintStatus.inProgress,
                            onTap: () => setState(() => _filterStatus = ComplaintStatus.inProgress)
                          ),
                          _FilterChip(
                            label: 'Resolved', 
                            isSelected: _filterStatus == ComplaintStatus.resolved,
                            onTap: () => setState(() => _filterStatus = ComplaintStatus.resolved)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                   return _WardenComplaintCard(complaint: complaints[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.5)),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryBlue,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          )
        ),
      ),
    );
  }
}

class _WardenComplaintCard extends StatelessWidget {
  final Complaint complaint;

  const _WardenComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Room ${complaint.roomNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: complaint.urgency == UrgencyLevel.high ? AppTheme.error.withValues(alpha: 0.2) : AppTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    complaint.urgency.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                      color: complaint.urgency == UrgencyLevel.high ? AppTheme.error : AppTheme.success
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(complaint.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(complaint.description, style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                     // Show status update dialog
                  },
                  child: const Text('Reply'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Update Status Action
                    _showStatusDialog(context, complaint);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Update Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showStatusDialog(BuildContext context, Complaint complaint) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ComplaintStatus.values.map((status) {
              return ListTile(
                title: Text(status.name.toUpperCase()),
                onTap: () {
                   Provider.of<ComplaintProvider>(context, listen: false).updateComplaintStatus(complaint.id, status);
                   Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      );
  }
}
