import 'package:flutter/material.dart';

class CertificateFilterSection extends StatelessWidget {
  final String searchQuery;
  final String? selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;

  const CertificateFilterSection({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Mobile Development', 'Design', 'Backend Development', 'Business'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search certificates...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Select Category',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            value: selectedCategory,
            items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
            onChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }
}
