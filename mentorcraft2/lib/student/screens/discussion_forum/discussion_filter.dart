import 'package:flutter/material.dart';

class FilterPage extends StatelessWidget {
  final String selectedCategory;

  const FilterPage({Key? key, required this.selectedCategory}) : super(key: key);

  final List<String> categories = const [
    'All',
    'Programming',
    'UI/UX',
    'Career',
    'Mobile Dev',
    'Web Dev',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter by Category')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return RadioListTile<String>(
            title: Text(category),
            value: category,
            groupValue: selectedCategory,
            onChanged: (value) {
              Navigator.pop(context, value); // return selected category
            },
          );
        },
      ),
    );
  }
}
