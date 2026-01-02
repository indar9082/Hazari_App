// lib/widgets/leave_card.dart
import 'package:flutter/material.dart';

class LeaveCard extends StatelessWidget {
  final String labourName;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const LeaveCard({
    Key? key,
    required this.labourName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, color: Colors.blue[700]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(labourName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('$startDate to $endDate', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status.toUpperCase(), style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Reason
            Text(reason, style: TextStyle(fontSize: 16, height: 1.4)),

            // Action Buttons (Contractor Only)
            if (status.toLowerCase() == 'pending' && onApprove != null && onReject != null) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: Icon(Icons.check, size: 18),
                      label: Text('APPROVE'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: Icon(Icons.close, size: 18),
                      label: Text('REJECT'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
