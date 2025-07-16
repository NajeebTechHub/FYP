import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CertificateStatus {
  issued,
  downloaded,
  shared,
  pending,
}

class Certificate {
  final String id;
  final String courseId;
  final String courseName;
  final String instructor;
  final DateTime issueDate;
  final DateTime completionDate;
  final String category;
  final String description;
  final String imageUrl;
  final CertificateStatus status;
  final double courseRating;
  final int courseDurationHours;
  final List<String> skills;

  Certificate({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.instructor,
    required this.issueDate,
    required this.completionDate,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.courseRating,
    required this.courseDurationHours,
    required this.skills,
  });

  // Helper method to get status text
  String getStatusText() {
    switch (status) {
      case CertificateStatus.issued:
        return 'Issued';
      case CertificateStatus.downloaded:
        return 'Downloaded';
      case CertificateStatus.shared:
        return 'Shared';
      case CertificateStatus.pending:
        return 'Pending Issue';
    }
  }

  // Helper method to get status color
  Color getStatusColor() {
    switch (status) {
      case CertificateStatus.issued:
        return Colors.blue;
      case CertificateStatus.downloaded:
        return Colors.green;
      case CertificateStatus.shared:
        return Colors.purple;
      case CertificateStatus.pending:
        return Colors.orange;
    }
  }

  // Helper method to get status icon
  IconData getStatusIcon() {
    switch (status) {
      case CertificateStatus.issued:
        return Icons.verified;
      case CertificateStatus.downloaded:
        return Icons.file_download_done;
      case CertificateStatus.shared:
        return Icons.share;
      case CertificateStatus.pending:
        return Icons.pending_actions;
    }
  }

  // Sample data for certificates
  static List<Certificate> getSampleCertificates() {
    return [
      Certificate(
        id: 'CERT-FL-1234',
        courseId: 'c1',
        courseName: 'Flutter App Development Masterclass',
        instructor: 'Sarah Johnson',
        issueDate: DateTime.now().subtract(const Duration(days: 15)),
        completionDate: DateTime.now().subtract(const Duration(days: 20)),
        category: 'Mobile Development',
        description: 'Successfully completed all modules and projects in the Flutter App Development course.',
        imageUrl: 'attached_assets/certificate_template.png',
        status: CertificateStatus.downloaded,
        courseRating: 4.8,
        courseDurationHours: 24,
        skills: ['Flutter', 'Dart', 'Mobile UI/UX', 'State Management'],
      ),
      Certificate(
        id: 'CERT-UX-5678',
        courseId: 'c2',
        courseName: 'UI/UX Design Principles',
        instructor: 'Michael Chen',
        issueDate: DateTime.now().subtract(const Duration(days: 45)),
        completionDate: DateTime.now().subtract(const Duration(days: 50)),
        category: 'Design',
        description: 'Mastered user interface and experience design principles and practices.',
        imageUrl: 'attached_assets/certificate_template.png',
        status: CertificateStatus.shared,
        courseRating: 4.9,
        courseDurationHours: 18,
        skills: ['UI Design', 'UX Research', 'Prototyping', 'User Testing'],
      ),
      Certificate(
        id: 'CERT-BE-9012',
        courseId: 'c3',
        courseName: 'Advanced Node.js Backend Development',
        instructor: 'Dr. Rebecca Williams',
        issueDate: DateTime.now().subtract(const Duration(days: 5)),
        completionDate: DateTime.now().subtract(const Duration(days: 7)),
        category: 'Backend Development',
        description: 'Completed advanced server-side programming with Node.js and related technologies.',
        imageUrl: 'attached_assets/certificate_template.png',
        status: CertificateStatus.issued,
        courseRating: 4.7,
        courseDurationHours: 30,
        skills: ['Node.js', 'Express', 'MongoDB', 'RESTful APIs', 'Authentication'],
      ),
      Certificate(
        id: 'CERT-PM-3456',
        courseId: 'c4',
        courseName: 'Project Management Fundamentals',
        instructor: 'Jennifer Lopez',
        issueDate: DateTime.now(),
        completionDate: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Business',
        description: 'Learned essential project management methodologies and best practices.',
        imageUrl: 'attached_assets/certificate_template.png',
        status: CertificateStatus.pending,
        courseRating: 4.6,
        courseDurationHours: 15,
        skills: ['Agile', 'Scrum', 'Project Planning', 'Risk Management'],
      ),
    ];
  }

  factory Certificate.fromFirestore(String id, Map<String, dynamic> data) {
    return Certificate(
      id: id,
      courseId: data['courseId'] ?? '',
      courseName: data['courseName'] ?? '',
      instructor: data['instructor'] ?? '',
      issueDate: (data['issueDate'] as Timestamp).toDate(),
      completionDate: (data['completionDate'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: _parseStatus(data['status']),
      courseRating: (data['courseRating'] as num).toDouble(),
      courseDurationHours: data['courseDurationHours'] ?? 0,
      skills: List<String>.from(data['skills'] ?? []),
    );
  }

  static CertificateStatus _parseStatus(String? status) {
    switch (status) {
      case 'issued':
        return CertificateStatus.issued;
      case 'downloaded':
        return CertificateStatus.downloaded;
      case 'shared':
        return CertificateStatus.shared;
      case 'pending':
        return CertificateStatus.pending;
      default:
        return CertificateStatus.issued;
    }
  }

}