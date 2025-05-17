import 'package:flutter/material.dart';

import '../theme/color.dart';

class LevelFilter extends StatelessWidget {
  final String? selectedLevel;
  final List<String> levels;
  final Function(String?) onLevelSelected;

  const LevelFilter({
    Key? key,
    required this.selectedLevel,
    required this.levels,
    required this.onLevelSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLevelChip(
                'All Levels',
                null,
                selectedLevel == null,
                context,
              ),
              ...levels.map((level) {
                return _buildLevelChip(
                  level,
                  level,
                  selectedLevel == level,
                  context,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelChip(
      String label,
      String? value,
      bool isSelected,
      BuildContext context,
      ) {
    // Choose an appropriate icon based on the level
    IconData getIconForLevel(String label) {
      switch (label) {
        case 'Beginner':
          return Icons.star_border;
        case 'Intermediate':
          return Icons.star_half;
        case 'Advanced':
          return Icons.star;
        case 'All Levels':
          return Icons.all_inclusive;
        default:
          return Icons.school;
      }
    }

    // Choose an appropriate color based on the level
    Color getColorForLevel(String label) {
      switch (label) {
        case 'Beginner':
          return Colors.green;
        case 'Intermediate':
          return Colors.orange;
        case 'Advanced':
          return Colors.red;
        case 'All Levels':
          return AppColors.primary;
        default:
          return Colors.grey;
      }
    }

    final levelColor = getColorForLevel(label);
    final levelIcon = getIconForLevel(label);

    return FilterChip(
      avatar: Icon(
        levelIcon,
        size: 16,
        color: isSelected ? Colors.white : levelColor,
      ),
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: Colors.grey[200],
      selectedColor: levelColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => onLevelSelected(value),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}