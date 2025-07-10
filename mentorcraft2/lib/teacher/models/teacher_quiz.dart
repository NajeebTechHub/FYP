import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherQuiz {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseName;
  final List<QuizQuestion> questions;
  final int timeLimit;
  final int attempts;
  final double passingPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int totalSubmissions;
  final String teacherId;

  TeacherQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseName,
    required this.questions,
    required this.timeLimit,
    required this.attempts,
    required this.passingPercentage,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.totalSubmissions,
    required this.teacherId,
  });

  factory TeacherQuiz.fromJson(Map<String, dynamic> json) {
    return TeacherQuiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      timeLimit: json['timeLimit'] ?? 60,
      attempts: json['attempts'] ?? 3,
      passingPercentage: (json['passingPercentage'] ?? 70.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      totalSubmissions: json['totalSubmissions'] ?? 0,
      teacherId: json['teacherId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'courseName': courseName,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimit': timeLimit,
      'attempts': attempts,
      'passingPercentage': passingPercentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'totalSubmissions': totalSubmissions,
      'teacherId': teacherId,
    };
  }

  TeacherQuiz copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    String? courseName,
    List<QuizQuestion>? questions,
    int? timeLimit,
    int? attempts,
    double? passingPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? totalSubmissions,
    String? teacherId,
  }) {
    return TeacherQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      questions: questions ?? this.questions,
      timeLimit: timeLimit ?? this.timeLimit,
      attempts: attempts ?? this.attempts,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      totalSubmissions: totalSubmissions ?? this.totalSubmissions,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}


class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final int points;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
      points: json['points'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'points': points,
    };
  }
}

class QuizSubmission {
  final String id;
  final String quizId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final List<StudentAnswer> answers;
  final double score;
  final double percentage;
  final DateTime submittedAt;
  final int timeSpent;
  final bool passed;

  QuizSubmission({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.answers,
    required this.score,
    required this.percentage,
    required this.submittedAt,
    required this.timeSpent,
    required this.passed,
  });

  factory QuizSubmission.fromJson(Map<String, dynamic> json, String id) {
    return QuizSubmission(
      id: id,
      quizId: json['quizId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      studentEmail: json['studentEmail'] ?? '',
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((a) => StudentAnswer.fromJson(a as Map<String, dynamic>))
          .toList(),
      score: (json['score'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      submittedAt: (json['submittedAt'] as Timestamp).toDate(),
      timeSpent: json['timeSpent'] ?? 0,
      passed: json['passed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'answers': answers.map((a) => a.toJson()).toList(),
      'score': score,
      'percentage': percentage,
      'submittedAt': submittedAt.toIso8601String(),
      'timeSpent': timeSpent,
      'passed': passed,
    };
  }
}



class StudentAnswer {
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int points;

  StudentAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.points,
  });

  factory StudentAnswer.fromJson(Map<String, dynamic> json) {
    return StudentAnswer(
      questionId: json['questionId'] ?? '',
      selectedAnswer: json['selectedAnswer'] ?? -1,
      isCorrect: json['isCorrect'] ?? false,
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'points': points,
    };
  }
}

