import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/sky_widgets.dart';
import '../../core/theme.dart';
import '../../providers/complaint_provider.dart';

class AnalyticsHub extends StatelessWidget {
  const AnalyticsHub({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure data is loaded
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    if (complaintProvider.complaints.isEmpty && !complaintProvider.isLoading) {
        Future.microtask(() => complaintProvider.fetchComplaints());
    }

    final allComplaints = complaintProvider.complaints;
    final total = allComplaints.length;
    final pending = complaintProvider.getPendingComplaints().length;
    final inProgress = complaintProvider.getInProgressComplaints().length;
    final resolved = complaintProvider.getResolvedComplaints().length;
    
    // Prevent division by zero for charts
    final safeTotal = total == 0 ? 1 : total;

    return Scaffold(
      backgroundColor: Colors.transparent, // Used inside dashboard
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
             Row(
              children: [
                 Expanded(child: _MetricCard(title: 'New Cases', value: total.toString(), trend: '+15%', isGoodOffset: true)),
                 const SizedBox(width: 12),
                 Expanded(child: _MetricCard(title: 'Resolved', value: resolved.toString(), trend: '+5%', isGoodOffset: true)),
              ],
            ),
            const SizedBox(height: 32),

            // Chart Section
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Overview',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                       SizedBox(
                        height: 150,
                        width: 150,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.blue,
                                value: total == 0 ? 1 : pending.toDouble(),
                                title: '',
                                radius: 25,
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: total == 0 ? 0 : inProgress.toDouble(),
                                title: '',
                                radius: 25,
                              ),
                              PieChartSectionData(
                                color: Colors.green,
                                value: total == 0 ? 0 : resolved.toDouble(),
                                title: '',
                                radius: 25,
                              ),
                            ],
                          ),
                        ),
                       ),
                       const SizedBox(width: 32),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _ChartLegend(color: Colors.blue, label: 'Pending (${(pending/safeTotal*100).toStringAsFixed(0)}%)'),
                             const SizedBox(height: 12),
                             _ChartLegend(color: Colors.orange, label: 'In Progress (${(inProgress/safeTotal*100).toStringAsFixed(0)}%)'),
                             const SizedBox(height: 12),
                             _ChartLegend(color: Colors.green, label: 'Resolved (${(resolved/safeTotal*100).toStringAsFixed(0)}%)'),
                           ],
                         ),
                       ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isGoodOffset;

  const _MetricCard({required this.title, required this.value, required this.trend, required this.isGoodOffset});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
           const SizedBox(height: 4),
           Row(
             children: [
               Icon(isGoodOffset ? Icons.trending_up : Icons.trending_down, size: 14, color: Colors.green),
               const SizedBox(width: 4),
               Text(trend, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
             ],
           ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
