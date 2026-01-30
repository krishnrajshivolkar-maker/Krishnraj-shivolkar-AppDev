import 'package:flutter/material.dart';

enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
}

enum ComplaintCategory {
  plumbing,
  electrical,
  furniture,
  internet,
  appliances,
  other,
}

enum UrgencyLevel {
  low,
  medium,
  high,
}

class Complaint {
  final String id;
  final String title;
  final String description;
  final ComplaintCategory category;
  final UrgencyLevel urgency;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final DateTime createdAt;
  ComplaintStatus status;
  final String? imageUrl;
  final List<ComplaintUpdate> updates;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.createdAt,
    this.status = ComplaintStatus.pending,
    this.imageUrl,
    this.updates = const [],
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: _parseCategory(json['category'] as String),
      urgency: _parseUrgency(json['urgency'] as String),
      studentId: json['student_id'] as String,
      studentName: json['student_name'] ?? 'Unknown',
      roomNumber: json['room_number'] ?? 'N/A',
      createdAt: DateTime.parse(json['created_at']),
      status: _parseStatus(json['status'] as String),
      imageUrl: json['image_url'] as String?,
      updates: (json['updates'] as List<dynamic>?)
              ?.map((e) => ComplaintUpdate.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'urgency': urgency.name,
      'student_id': studentId,
      'student_name': studentName,
      'room_number': roomNumber,
      'status': status.name,
      'image_url': imageUrl,
      // 'created_at' is usually handled by DB default
    };
  }

  static ComplaintCategory _parseCategory(String value) {
    return ComplaintCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ComplaintCategory.other,
    );
  }

  static UrgencyLevel _parseUrgency(String value) {
    return UrgencyLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UrgencyLevel.medium,
    );
  }

  static ComplaintStatus _parseStatus(String value) {
    return ComplaintStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ComplaintStatus.pending,
    );
  }
}

class ComplaintUpdate {
  final String message;
  final DateTime timestamp;
  final String senderName;
  final String senderRole;

  ComplaintUpdate({
    required this.message,
    required this.timestamp,
    required this.senderName,
    required this.senderRole,
  });

  factory ComplaintUpdate.fromJson(Map<String, dynamic> json) {
    return ComplaintUpdate(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['created_at']),
      senderName: json['sender_name'] ?? 'Unknown',
      senderRole: json['sender_role'] ?? 'Admin',
    );
  }
  
  Map<String, dynamic> toJson() {
      return {
          'message': message,
          'sender_name': senderName,
          'sender_role': senderRole,
          // created_at handled by db
      };
  }
}
