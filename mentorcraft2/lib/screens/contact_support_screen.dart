import 'package:flutter/material.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Need Help?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Feel free to reach out to us for support or any questions you might have.',
              ),
              const SizedBox(height: 16),
              const Text('Name'),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Email'),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Message'),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add support sending logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your message has been sent!'),
                      ),
                    );
                  },
                  child: const Text('Send Message'),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Other Contact Options:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('📧 Email: support@mentorcraft.com'),
              const Text('☎️ Phone: +92 348 9337309'),
              const Text('📍 Address: Landi Akhun Ahmad, KPK, Pakistan'),
            ],
          ),
        ),
      ),
    );
  }
}
