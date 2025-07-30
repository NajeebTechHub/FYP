import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';

class CertificateTemplate extends StatelessWidget {
  final String courseName;
  final String studentName;
  final String issueDate;
  final String certificateId;
  final String instructor;

  const CertificateTemplate({
    Key? key,
    required this.courseName,
    required this.studentName,
    required this.issueDate,
    required this.certificateId,
    required this.instructor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.darkBlue.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Icon(Icons.workspace_premium, size: 30, color: AppColors.darkBlue),
                    Text(
                      'MENTORCRAFT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    Icon(Icons.workspace_premium, size: 30, color: AppColors.darkBlue),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'CERTIFICATE OF COMPLETION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'This certificate is presented to\n'),
                      TextSpan(
                        text: studentName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const TextSpan(text: '\nfor successfully completing the course\n'),
                      TextSpan(
                        text: courseName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Issue Date:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                issueDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Certificate ID:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                certificateId,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            instructor,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'cursive',
                              fontSize: 16,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(width: 100, height: 1, color: Colors.black45),
                          const SizedBox(height: 8),
                          Text(
                            'Course Instructor',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        children: [
                          const Text(
                            'Engr. Najeeb Anjum',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'cursive',
                              fontSize: 16,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(width: 100, height: 1, color: Colors.black45),
                          const SizedBox(height: 8),
                          Text(
                            'MentorCraft Director',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified, size: 15, color: AppColors.primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Verify this certificate at mentorcraft.com/verify',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
