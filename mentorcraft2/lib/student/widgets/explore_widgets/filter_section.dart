import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'category_filter.dart';

class FilterSection extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedLevel;
  final String? selectedDuration;
  final String? searchQuery;
  final List<String> categories;
  final List<String>? levels;
  final List<String>? durations;
  final int? totalCourses;
  final int? filteredCoursesCount;
  final Function(String?) onCategorySelected;
  final Function(String?)? onLevelSelected;
  final Function(String?)? onDurationSelected;
  final VoidCallback? onClearFilters;
  // final Function(String) onSearchQueryRemoved;

  const FilterSection({
    Key? key,
    required this.selectedCategory,
    this.selectedLevel,
    this.selectedDuration,
    this.searchQuery,
    required this.categories,
    this.levels,
    this.durations,
    this.totalCourses,
    this.filteredCoursesCount,
    required this.onCategorySelected,
    this.onLevelSelected,
    this.onDurationSelected,
    this.onClearFilters,
    // required this.onSearchQueryRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedCategory != null ||
        selectedLevel != null ||
        selectedDuration != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filter
        CategoryFilter(
          selectedCategory: selectedCategory,
          categories: categories,
          onCategorySelected: onCategorySelected,
        ),

        // Advanced filter section (currently disabled)
        // ExpansionTile(
        //   title: const Text(
        //     'Advanced Filters',
        //     style: TextStyle(
        //       fontSize: 16,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
          // leading: const Icon(Icons.filter_list),
          // initiallyExpanded: hasActiveFilters,
          // childrenPadding: EdgeInsets.zero,
          // expandedCrossAxisAlignment: CrossAxisAlignment.start,
          // children: [
            // Uncomment below if needed later:

            // LevelFilter(
            //   selectedLevel: selectedLevel,
            //   levels: levels,
            //   onLevelSelected: onLevelSelected,
            // ),
            //
            // const Divider(),
            //
            // DurationFilter(
            //   selectedDuration: selectedDuration,
            //   durations: durations,
            //   onDurationSelected: onDurationSelected,
            // ),
          ],
        // ),

        // if (hasActiveFilters) _buildActiveFilters(),
      // ],
    );
  }

  // Widget _buildActiveFilters() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text(
  //               'Active Filters',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             TextButton.icon(
  //               onPressed: onClearFilters,
  //               icon: const Icon(Icons.clear_all, size: 18),
  //               label: const Text('Clear All'),
  //               style: TextButton.styleFrom(
  //                 foregroundColor: AppColors.primary,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Wrap(
  //           spacing: 8,
  //           runSpacing: 8,
  //           children: [
  //             // if (selectedCategory != null)
  //             //   _buildFilterChip(
  //             //     'Category: $selectedCategory',
  //             //         () => onCategorySelected(null),
  //             //   ),
  //             // if (selectedLevel != null && onLevelSelected != null)
  //             //   _buildFilterChip(
  //             //     'Level: $selectedLevel',
  //             //         () => onLevelSelected!(null),
  //             //   ),
  //             // if (selectedDuration != null && onDurationSelected != null)
  //             //   _buildFilterChip(
  //             //     'Duration: $selectedDuration',
  //             //         () => onDurationSelected!(null),
  //             //   ),
  //             // if (searchQuery != null && searchQuery!.isNotEmpty)
  //               // _buildFilterChip(
  //                 // 'Search: $searchQuery',
  //                 //     () => onSearchQueryRemoved(searchQuery!),
  //               // ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             const Icon(Icons.filter_list_alt, size: 16, color: Colors.grey),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Showing $filteredCoursesCount of $totalCourses courses',
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.grey[600],
  //                 fontStyle: FontStyle.italic,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.lightBlue.withOpacity(0.2),
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.darkBlue),
      deleteIcon: const Icon(Icons.close, size: 16),
      deleteIconColor: AppColors.darkBlue,
      onDeleted: onDelete,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
