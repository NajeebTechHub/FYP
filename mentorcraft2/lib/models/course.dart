class Course {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String duration;
  final String level;
  final double rating;
  final int studentsCount;
  final String instructor;
  final List<String> tags;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.duration,
    required this.level,
    required this.rating,
    required this.studentsCount,
    required this.instructor,
    required this.tags,
  });
}