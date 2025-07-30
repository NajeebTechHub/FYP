import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorcraft2/theme/color.dart';
import '../../models/certificate.dart';
import '../../widgets/certificate_widgets/certificate_template.dart';

class CertificatePreviewScreen extends StatelessWidget {
  final Certificate certificate;
  final String studentName;

  const CertificatePreviewScreen({
    Key? key,
    required this.certificate,
    required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(certificate.issueDate);
    final isDark = theme.brightness == Brightness.dark;

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
                const SnackBar(content: Text('Sharing certificate...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Certificate',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading certificate as PDF...')),
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
              CertificateTemplate(
                courseName: certificate.courseName,
                studentName: studentName,
                issueDate: formattedDate,
                certificateId: certificate.id,
                instructor: certificate.instructor,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDark
                      ? []
                      : [
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
                    Text(
                      'Certificate Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Course', certificate.courseName, theme),
                    _buildDetailRow('Category', certificate.category, theme),
                    _buildDetailRow('Instructor', certificate.instructor, theme),
                    _buildDetailRow('Date of Issue', formattedDate, theme),
                    _buildDetailRow('Certificate ID', certificate.id, theme),
                    _buildDetailRow('Status', certificate.getStatusText(), theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                        foregroundColor: AppColors.background,
                        side: BorderSide(color: AppColors.darkBlue),
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
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.background,
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

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textFaded : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
