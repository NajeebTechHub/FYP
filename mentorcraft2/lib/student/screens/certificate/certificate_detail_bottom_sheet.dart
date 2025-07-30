import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorcraft2/student/models/certificate.dart';
import '../../../theme/color.dart';
import '../../widgets/certificate_widgets/certificate_template.dart';
import 'certificate_preview_screen.dart';

void showCertificateDetailsSheet(
    BuildContext context,
    Certificate certificate, {
      required String studentName,
    }) {
  final dateFormat = DateFormat('MMMM d, yyyy');
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
  final primaryText = isDark ? AppColors.textLight : AppColors.textPrimary;
  final secondaryText = isDark ? AppColors.textFaded : AppColors.textSecondary;
  final descriptionText =
  isDark ? AppColors.textLight.withOpacity(0.9) : Colors.grey.shade800;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: 0.45,
                          child: CertificateTemplate(
                            courseName: certificate.courseName,
                            studentName: studentName,
                            issueDate:
                            dateFormat.format(certificate.issueDate),
                            certificateId: certificate.id,
                            instructor: certificate.instructor,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.black38,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.visibility,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CertificatePreviewScreen(
                                    certificate: certificate,
                                    studentName: studentName,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  certificate.courseName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Instructor: ${certificate.instructor}',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryText,
                        ),
                      ),
                    ),
                    Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      certificate.courseRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  certificate.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: descriptionText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completion Date',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(certificate.completionDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issue Date',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(certificate.issueDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 12),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Certificate verified!')),
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
                            const SnackBar(
                                content: Text('Sharing certificate...')),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                            Text('Downloading certificate as PDF...')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
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
          );
        },
      );
    },
  );
}
