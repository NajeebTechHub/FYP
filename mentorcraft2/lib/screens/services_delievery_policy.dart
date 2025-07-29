import 'package:flutter/material.dart';

class ServiceDeliveryPolicyScreen extends StatelessWidget {
  const ServiceDeliveryPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Delivery Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Service Delivery Policy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'This Service Delivery Policy explains how and when our digital products and services are provided to users who make purchases through our app.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              Text(
                'Delivery Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• All services, including online courses and learning content, are delivered digitally.\n'
                    '• Users get immediate access to purchased content once the payment is confirmed.\n'
                    '• A confirmation email and receipt are sent to the registered email address.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              Text(
                'Access & Availability',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Purchased content is available 24/7 through the app.\n'
                    '• Access remains valid based on the course duration or subscription plan.\n'
                    '• In case of server maintenance or downtime, prior notice will be provided where possible.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              Text(
                'Service Limitations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Content sharing, redistribution, or commercial use is strictly prohibited.\n'
                    '• Access may be revoked in case of policy violations or abuse.\n'
                    '• We reserve the right to modify or discontinue services with prior notice.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              Text(
                'Support & Queries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'For any assistance regarding service delivery, feel free to contact our support team at:\n'
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
