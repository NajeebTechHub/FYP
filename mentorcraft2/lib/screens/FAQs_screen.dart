import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          FAQItem(
              question: '1. PayFast kya hai?',
              answer:
              'PayFast Pakistan ka ek online payment gateway hai jo secure transactions ki sahulat deta hai.'
          ),
          FAQItem(
              question: '2. Main apna data kaise delete karwa sakta hoon?',
              answer:
              'App ke settings section mein "Delete Account" option available hai. Aapka data permanently delete ho jaye ga.'
          ),
          FAQItem(
              question: '3. Kya app card information save karti hai?',
              answer:
              'Nahi, hum kisi user ki card ya payment information ko store nahi karte. PayFast PCI-DSS compliance ke sath direct process karta hai.'
          ),
          FAQItem(
              question: '4. Agar payment fail ho jaye to kya karen?',
              answer:
              'Please apna internet connection check karein aur retry karein. Agar masla barqarar rahe to support team se rabta karein.'
          ),
          FAQItem(
              question: '5. Support team se kaise rabta karein?',
              answer:
              'Aap humein email kar sakte hain: support@mentorcraft.com ya app ke contact section se form fill karke.'
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({required this.question, required this.answer, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(answer),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}
