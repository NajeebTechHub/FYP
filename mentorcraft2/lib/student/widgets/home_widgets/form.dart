import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:mentorcraft2/services/newsletter_service.dart';

class NewsletterForm extends StatefulWidget {
  const NewsletterForm({Key? key}) : super(key: key);

  @override
  State<NewsletterForm> createState() => _NewsletterFormState();
}

class _NewsletterFormState extends State<NewsletterForm> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _subscribe() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await NewsletterService.subscribeUser(email);
      _emailController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscribed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to subscribe: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E) // dark card color
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join Our Community',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Enter your email address to subscribe to our newsletter.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
              filled: true,
              fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _subscribe,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}
