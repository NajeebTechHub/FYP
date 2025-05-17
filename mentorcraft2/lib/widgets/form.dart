import 'package:flutter/material.dart';
import '../theme/color.dart';

class NewsletterForm extends StatelessWidget {
  const NewsletterForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join Our Community',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Enter your email address to register to our newsletter Subscription delivered on regular basis'),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12), // Space between input and button
          SizedBox(
            width: double.infinity, // Full-width button
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}
