class TeacherQuiz {
  final String id;
  final String title;
  final String description;
  final int timeLimit;
  final int attempts;
  final double duration; // ✅ Added this
  final double passingScore;
  final List<dynamic> questions;

  TeacherQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLimit,
    required this.attempts,
    required this.duration, // ✅ Added this
    required this.passingScore,
    required this.questions,
  });

  factory TeacherQuiz.fromMap(Map<String, dynamic> data, String docId) {
    return TeacherQuiz(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timeLimit: (data['timeLimit'] ?? 0).toInt(),
      attempts: (data['attempts'] ?? 0).toInt(),
      duration: (data['duration'] ?? 0).toDouble(), // ✅ Corrected assignment
      passingScore: (data['passingScore'] ?? 0).toDouble(),
      questions: data['questions'] ?? [],
    );
  }
}
