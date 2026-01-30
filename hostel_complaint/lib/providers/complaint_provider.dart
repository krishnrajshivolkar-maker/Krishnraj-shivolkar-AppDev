import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../core/supabase_service.dart';
import '../models/complaint.dart';

class ComplaintProvider with ChangeNotifier {
  List<Complaint> _complaints = [];
  bool _isLoading = false;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;

  final _client = SupabaseService.client;

  // Real-time subscription handle
  supabase.RealtimeChannel? _complaintsSubscription;

  void fetchComplaints() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('complaints')
          .select('*, updates: complaint_updates(*)') // Fetch complaints with updates
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      _complaints = data.map((e) => Complaint.fromJson(e)).toList();
      
      _subscribeToComplaints();

    } catch (e) {
      debugPrint('Error fetching complaints: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToComplaints() {
    _complaintsSubscription = _client
        .channel('public:complaints')
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.all,
          schema: 'public',
          table: 'complaints',
          callback: (payload) {
             // Simple reload for now, optimization would be to update local list
             fetchComplaints();
          },
        )
        .subscribe();
  }

  Future<void> addComplaint(Complaint complaint) async {
    try {
      // 1. Upload Image if exists (Logic to be added if image path is real)
      String? uploadedImageUrl;
      /*
      if (complaint.imageUrl != null) {
         // upload logic
      }
      */

      // 2. Insert Complaint
      final complaintData = complaint.toJson();
      complaintData.remove('updates'); // Don't try to insert updates here
      complaintData['image_url'] = uploadedImageUrl;

      await _client.from('complaints').insert(complaintData);
      
      // Local list update handled by subscription or re-fetch
    } catch (e) {
      debugPrint('Error adding complaint: $e');
      rethrow;
    }
  }

  Future<void> updateComplaintStatus(String id, ComplaintStatus status) async {
    try {
      await _client
          .from('complaints')
          .update({'status': status.name})
          .eq('id', id);
    } catch (e) {
      debugPrint('Error updating status: $e');
      rethrow;
    }
  }
  
  List<Complaint> getComplaintsForStudent(String studentId) {
    return _complaints.where((c) => c.studentId == studentId).toList();
  }
  
  List<Complaint> getPendingComplaints() {
    return _complaints.where((c) => c.status == ComplaintStatus.pending).toList();
  }

  List<Complaint> getInProgressComplaints() {
    return _complaints.where((c) => c.status == ComplaintStatus.inProgress).toList();
  }

  List<Complaint> getResolvedComplaints() {
    return _complaints.where((c) => c.status == ComplaintStatus.resolved).toList();
  }

  @override
  void dispose() {
    _client.removeChannel(_complaintsSubscription!);
    super.dispose();
  }
}
