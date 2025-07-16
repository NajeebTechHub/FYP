import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/certificate.dart';
import 'package:mentorcraft2/theme/color.dart';
import '../widgets/certificate_widgets/certificate_template.dart';

class CertificatePreviewScreen extends StatelessWidget {
  final Certificate certificate;
  final String studentName;

  const CertificatePreviewScreen({
    Key? key,
    required this.certificate, required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(certificate.issueDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Preview'),
        backgroundColor: AppColors.darkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Certificate',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing certificate...'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Certificate',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading certificate as PDF...'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Certificate preview
              CertificateTemplate(
                courseName: certificate.courseName,
                studentName: studentName,
                issueDate: formattedDate,
                certificateId: certificate.id,
                instructor: certificate.instructor,
              ),
              const SizedBox(height: 24),

              // Certificate details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Certificate Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Course', certificate.courseName),
                    _buildDetailRow('Category', certificate.category),
                    _buildDetailRow('Instructor', certificate.instructor),
                    _buildDetailRow('Date of Issue', formattedDate),
                    _buildDetailRow('Certificate ID', certificate.id),
                    _buildDetailRow('Status', certificate.getStatusText()),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Certificate verified!')),
                        );
                      },
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Verify'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkBlue,
                        side: const BorderSide(color: AppColors.darkBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Adding to LinkedIn...')),
                        );
                      },
                      icon: const Icon(Icons.add_box),
                      label: const Text('Add to LinkedIn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}