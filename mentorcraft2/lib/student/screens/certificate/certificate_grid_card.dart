import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/models/certificate.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Certificate Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/placeholder.jpg',
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),

              // Course Name
              Text(
                certificate.courseName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Instructor
              Text(
                certificate.instructor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const Spacer(), // <- Spacer is safe in Column

              // Status Row
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
