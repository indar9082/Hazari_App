// lib/widgets/labour_card.dart
import 'package:flutter/material.dart';

class LabourCard extends StatelessWidget {
  final String name;
  final String role;
  final int daysWorked;
  final double amount;
  final String status;
  final Color statusColor;

  const LabourCard({
    Key? key,
    required this.name,
    required this.role,
    required this.daysWorked,
    required this.amount,
    required this.status,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: statusColor,
            size: 28,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role, style: TextStyle(color: Colors.grey[600])),
            Text('$daysWorked days | ₹${amount.toStringAsFixed(0)}'),
          ],
        ),
        trailing: Chip(
          label: Text(status),
          backgroundColor: statusColor.withOpacity(0.2),
          labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
