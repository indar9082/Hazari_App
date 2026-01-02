// lib/widgets/payment_card.dart
import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final String labourName;
  final double totalAmount;
  final int daysWorked;
  final double dailyRate;
  final String status;
  final VoidCallback? onDownload;

  const PaymentCard({
    Key? key,
    required this.labourName,
    required this.totalAmount,
    required this.daysWorked,
    required this.dailyRate,
    required this.status,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.account_balance_wallet, color: Colors.green[700]),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(labourName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('$daysWorked days @ ₹${dailyRate.toStringAsFixed(0)}/day',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Amount
            Text(
              '₹${totalAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.green[700],
                letterSpacing: 1,
              ),
            ),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),

            // Action Button
            if (onDownload != null) ...[
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDownload,
                  icon: Icon(Icons.download),
                  label: Text('Download Statement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
