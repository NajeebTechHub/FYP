import 'package:cloud_firestore/cloud_firestore.dart';

class NewsletterService {
  static Future<void> subscribeUser(String email) async {
    if (email.isEmpty) return;

    await FirebaseFirestore.instance.collection('newsletter_subscriptions').add({
      'email': email,
      'subscribedAt': Timestamp.now(),
    });
  }
}
