import 'package:flutter/material.dart';
import '../../../theme/color.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
