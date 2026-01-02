// lib/screens/payment_screen.dart - COMPLETE FILE
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Summary'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      '₹5,000',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Total Payment This Month',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PaymentInfo('Days Worked', '22'),
                        _PaymentInfo('Daily Rate', '₹227'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Statement sent to email!')),
                    ),
                    icon: Icon(Icons.download),
                    label: Text('Download'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Share via WhatsApp!')),
                    ),
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _PaymentInfo(String label, String value) {
  return Column(
    children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
    ],
  );
}
