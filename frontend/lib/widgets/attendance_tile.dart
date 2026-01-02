// lib/widgets/attendance_tile.dart
import 'package:flutter/material.dart';

class AttendanceTile extends StatelessWidget {
  final String date;
  final String checkIn;
  final String? checkOut;
  final String status;
  final String? checkInPhoto;
  final String? location;

  const AttendanceTile({
    Key? key,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.status,
    this.checkInPhoto,
    this.location,
  }) : super(key: key);

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Status Circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                status.toLowerCase() == 'completed' ? Icons.check_circle : Icons.schedule,
                color: _statusColor,
                size: 28,
              ),
            ),
            SizedBox(width: 16),

            // Date & Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.login, size: 16, color: Colors.green[700]),
                      SizedBox(width: 4),
                      Text(checkIn, style: TextStyle(fontSize: 14, color: Colors.green[700])),
                      if (checkOut != null) ...[
                        SizedBox(width: 16),
                        Icon(Icons.logout, size: 16, color: Colors.red[700]),
                        SizedBox(width: 4),
                        Text(checkOut!, style: TextStyle(fontSize: 14, color: Colors.red[700])),
                      ],
                    ],
                  ),
                  if (location != null) ...[
                    SizedBox(height: 4),
                    Text(location!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ],
              ),
            ),

            // Photo Thumbnail (if exists)
            if (checkInPhoto != null)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage('http://10.0.2.2:8080$checkInPhoto'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
