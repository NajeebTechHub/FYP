import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../models/certificate.dart';

class CertificateListCard extends StatelessWidget {
  final Certificate certificate;
  final AnimationController animationController;
  final int index;
  final VoidCallback onTap;

  const CertificateListCard({
    super.key,
    required this.certificate,
    required this.animationController,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final delayedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Interval(
        math.min(1.0, index * 0.05),
        math.min(1.0, index * 0.05 + 0.45),
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: delayedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(delayedAnimation),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 153,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 150,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusRow(context),
                        const SizedBox(height: 8),
                        Text(
                          certificate.courseName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Instructor: ${certificate.instructor}',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Issued: ${DateFormat('MMMM d, yyyy').format(certificate.issueDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: certificate.getStatusColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                certificate.getStatusIcon(),
                size: 12,
                color: certificate.getStatusColor(),
              ),
              const SizedBox(width: 4),
              Text(
                certificate.getStatusText(),
                style: TextStyle(
                  color: certificate.getStatusColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            certificate.id,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
