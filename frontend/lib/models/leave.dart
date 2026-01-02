// lib/models/leave.dart
import 'package:flutter/material.dart' show Colors, Color;

class Leave {
  final int id;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;

  Leave({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'reason': reason,
      'status': status,
    };
  }

  int get totalDays => endDate.difference(startDate).inDays + 1;

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }
}
