import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';

class DurationFilter extends StatelessWidget {
  final String? selectedDuration;
  final List<String> durations;
  final Function(String?) onDurationSelected;

  const DurationFilter({
    Key? key,
    required this.selectedDuration,
    required this.durations,
    required this.onDurationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildDurationOption(
                'Any Duration',
                null,
                selectedDuration == null,
                context,
              ),
              ...durations.map((duration) => _buildDurationOption(
                duration,
                duration,
                selectedDuration == duration,
                context,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(
      String label,
      String? value,
      bool isSelected,
      BuildContext context,
      ) {
    // Helper function to get an estimate of hours
    String _getHoursEstimate(String duration) {
      switch (duration) {
        case 'Less than 1 hour':
          return '< 1h';
        case '1-3 hours':
          return '1-3h';
        case '3-6 hours':
          return '3-6h';
        case '6-10 hours':
          return '6-10h';
        case 'Over 10 hours':
          return '> 10h';
        default:
          return 'Any';
      }
    }

    return InkWell(
      onTap: () => onDurationSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBlue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getHoursEstimate(label),
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}