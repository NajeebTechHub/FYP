import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/models/certificate.dart';
import 'package:mentorcraft2/theme/color.dart';

class CertificateGridCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onTap;

  const CertificateGridCard({
    super.key,
    required this.certificate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.cardDark : Colors.white,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? AppColors.cardDark : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/placeholder.jpg',
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                certificate.courseName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                certificate.instructor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textFaded : Colors.grey[700],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    certificate.getStatusIcon(),
                    size: 16,
                    color: certificate.getStatusColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    certificate.getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: certificate.getStatusColor(),
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
}
