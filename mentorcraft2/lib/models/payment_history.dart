import 'package:flutter/material.dart';

enum PaymentStatus {
  successful,
  failed,
  pending,
  refunded
}

class PaymentHistory {
  final String id;
  final String courseName;
  final String instructorName;
  final String transactionId;
  final DateTime dateTime;
  final double amount;
  final String paymentMethod;
  final PaymentStatus status;
  final String? receiptUrl;

  PaymentHistory({
    required this.id,
    required this.courseName,
    required this.instructorName,
    required this.transactionId,
    required this.dateTime,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.receiptUrl,
  });

  // Method to get color based on payment status
  Color getStatusColor() {
    switch (status) {
      case PaymentStatus.successful:
        return Colors.green.shade700;
      case PaymentStatus.failed:
        return Colors.red.shade700;
      case PaymentStatus.pending:
        return Colors.orange.shade700;
      case PaymentStatus.refunded:
        return Colors.blue.shade700;
    }
  }

  // Method to get text based on payment status
  String getStatusText() {
    switch (status) {
      case PaymentStatus.successful:
        return 'Successful';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  // Sample data for testing
  static List<PaymentHistory> getSampleData() {
    return [
      PaymentHistory(
        id: '1',
        courseName: 'Advanced Flutter Development',
        instructorName: 'Sarah Johnson',
        transactionId: 'TXN-12345-ABCDE',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        amount: 49.99,
        paymentMethod: 'Credit Card (Visa)',
        status: PaymentStatus.successful,
      ),
      PaymentHistory(
        id: '2',
        courseName: 'UI/UX Design Masterclass',
        instructorName: 'Michael Chen',
        transactionId: 'TXN-67890-FGHIJ',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        amount: 39.99,
        paymentMethod: 'PayPal',
        status: PaymentStatus.successful,
      ),
      PaymentHistory(
        id: '3',
        courseName: 'Web Development Bootcamp',
        instructorName: 'Jessica Smith',
        transactionId: 'TXN-24680-KLMNO',
        dateTime: DateTime.now().subtract(const Duration(days: 12)),
        amount: 29.99,
        paymentMethod: 'JazzCash',
        status: PaymentStatus.failed,
        receiptUrl: 'receipt/txn-24680.pdf',
      ),
      PaymentHistory(
        id: '4',
        courseName: 'Data Science Fundamentals',
        instructorName: 'Robert Wilson',
        transactionId: 'TXN-13579-PQRST',
        dateTime: DateTime.now().subtract(const Duration(days: 15)),
        amount: 59.99,
        paymentMethod: 'Credit Card (Mastercard)',
        status: PaymentStatus.pending,
      ),
      PaymentHistory(
        id: '5',
        courseName: 'Digital Marketing Strategy',
        instructorName: 'Emily Zhang',
        transactionId: 'TXN-97531-UVWXY',
        dateTime: DateTime.now().subtract(const Duration(days: 20)),
        amount: 45.99,
        paymentMethod: 'Google Pay',
        status: PaymentStatus.successful,
      ),
      PaymentHistory(
        id: '6',
        courseName: 'Mobile App Development with React Native',
        instructorName: 'David Kim',
        transactionId: 'TXN-86420-ZABCD',
        dateTime: DateTime.now().subtract(const Duration(days: 25)),
        amount: 54.99,
        paymentMethod: 'Apple Pay',
        status: PaymentStatus.refunded,
      ),
      PaymentHistory(
        id: '7',
        courseName: 'Python for Machine Learning',
        instructorName: 'Lisa Brown',
        transactionId: 'TXN-75319-EFGHI',
        dateTime: DateTime.now().subtract(const Duration(days: 30)),
        amount: 49.99,
        paymentMethod: 'Credit Card (Visa)',
        status: PaymentStatus.successful,
      ),
    ];
  }
}