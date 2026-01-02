import 'package:flutter/material.dart';

class AttendanceHistory extends StatelessWidget {
  AttendanceHistory({super.key}); // Add key constructor

  final List<Map<String, String?>> dummyData = [
    {'date': '2025-12-04', 'checkIn': '09:00 AM', 'checkOut': '06:00 PM', 'status': 'Completed'},
    {'date': '2025-12-03', 'checkIn': '09:15 AM', 'checkOut': null, 'status': 'Pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          final item = dummyData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                item['status'] == 'Completed' ? Colors.green : Colors.orange,
                child: Icon(
                  item['status'] == 'Completed' ? Icons.check : Icons.schedule,
                ),
              ),
              title: Text(item['date']!),
              subtitle: Text(
                'In: ${item['checkIn']} | Out: ${item['checkOut'] ?? 'Pending'}',
              ),
              trailing: Text(
                item['status'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
