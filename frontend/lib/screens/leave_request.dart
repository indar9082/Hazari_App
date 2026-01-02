// lib/screens/leave_request.dart - COMPLETE FILE
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveRequest extends StatefulWidget {
  @override
  _LeaveRequestState createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  final _reasonController = TextEditingController();
  DateTime? startDate, endDate;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Request'), backgroundColor: Colors.orange[700]),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.orange),
                title: Text(startDate == null
                    ? 'Select Start Date'
                    : DateFormat('dd MMM yyyy').format(startDate!)),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => _selectDate(context, true),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.orange),
                title: Text(endDate == null
                    ? 'Select End Date'
                    : DateFormat('dd MMM yyyy').format(endDate!)),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => _selectDate(context, false),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for leave',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: (startDate == null || endDate == null || _reasonController.text.isEmpty)
                  ? null
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Leave request submitted!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700], padding: EdgeInsets.symmetric(vertical: 16)),
              child: Text('SUBMIT LEAVE REQUEST', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
