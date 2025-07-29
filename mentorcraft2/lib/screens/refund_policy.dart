import 'package:flutter/material.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Return & Refund Policy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Thank you for choosing our platform. This Refund Policy outlines the conditions under which refunds are granted for digital services such as courses or subscriptions offered through our application.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              Text(
                'Eligibility for Refunds',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Refunds are only applicable within 7 days of purchase.\n'
                    '• The course must not have been completed more than 10%.\n'
                    '• Technical issues must be reported with proof (screenshots, error messages).\n'
                    '• No refund will be given for change of mind or accidental purchase.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              Text(
                'Non-Refundable Conditions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• If the content has been largely accessed or completed.\n'
                    '• If more than 7 days have passed since the purchase.\n'
                    '• If the refund request lacks sufficient justification.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              Text(
                'How to Request a Refund',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Please send an email to support@mentorcraft.com with the following details:\n'
                    '• Full Name\n'
                    '• Registered Email\n'
                    '• Order ID or Payment Proof\n'
                    '• Reason for Refund\n\n'
                    'Our support team will review your request and respond within 3–5 working days.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              Text(
                'Contact Us',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'If you have any questions or concerns about our Refund Policy, feel free to contact us at:\n'
                    'Email: support@mentorcraft.com\nPhone: +92-348-9337309',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
