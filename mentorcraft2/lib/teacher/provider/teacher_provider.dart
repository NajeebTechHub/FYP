import 'package:flutter/material.dart';
import '../models/teacher_course.dart';
import '../models/teacher_quiz.dart';
import '../models/student_progress.dart';
import '../models/teacher_announcement.dart';

class TeacherProvider with ChangeNotifier {
  // Teacher profile
  String _teacherId = 'teacher_001';
  String _teacherName = 'Dr. Sarah Johnson';
  String _teacherEmail = 'sarah.johnson@mentorcraft.com';
  String _teacherAvatar = 'assets/images/11.png';
  String _teacherBio = 'Experienced educator and technology expert with 10+ years in the field.';

  // Dashboard stats
  DashboardStats _dashboardStats = DashboardStats(
    totalCourses: 12,
    publishedCourses: 10,
    draftCourses: 2,
    totalStudents: 1250,
    activeStudents: 890,
    totalRevenue: 45678.50,
    monthlyRevenue: 8950.25,
    totalQuizzes: 45,
    pendingSubmissions: 23,
    averageRating: 4.7,
    totalReviews: 423,
    monthlyEarnings: [
      MonthlyEarning(month: 'Jan', amount: 7500.0, enrollments: 85),
      MonthlyEarning(month: 'Feb', amount: 8200.0, enrollments: 92),
      MonthlyEarning(month: 'Mar', amount: 9100.0, enrollments: 98),
      MonthlyEarning(month: 'Apr', amount: 8950.25, enrollments: 105),
    ],
    topCourses: [
      CourseStats(courseId: '1', courseName: 'Flutter Development', enrollments: 245, revenue: 12250.0, rating: 4.8),
      CourseStats(courseId: '2', courseName: 'React Native', enrollments: 189, revenue: 9450.0, rating: 4.6),
      CourseStats(courseId: '3', courseName: 'iOS Development', enrollments: 156, revenue: 7800.0, rating: 4.7),
    ],
  );

  // Courses
  List<TeacherCourse> _courses = [
    TeacherCourse(
      id: '1',
      title: 'Complete Flutter Development',
      description: 'Master Flutter app development from basics to advanced concepts',
      category: 'Mobile Development',
      level: 'Intermediate',
      price: 99.99,
      duration: '12 hours',
      imageUrl: 'assets/flutter_course.jpg',
      teacherId: 'teacher_001',
      teacherName: 'Dr. Sarah Johnson',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      isPublished: true,
      enrolledStudents: 245,
      rating: 4.8,
      totalRatings: 89,
      tags: ['Flutter', 'Dart', 'Mobile', 'Cross-platform'],
      modules: [
        CourseModule(
          id: 'mod1',
          title: 'Introduction to Flutter',
          description: 'Getting started with Flutter development',
          order: 1,
          lessons: [
            Lesson(id: 'l1', title: 'What is Flutter?', content: 'Introduction to Flutter framework', type: 'video', videoUrl: '', duration: 15, order: 1),
            Lesson(id: 'l2', title: 'Setting up Development Environment', content: 'Install Flutter SDK and IDE', type: 'video', videoUrl: '', duration: 20, order: 2),
          ],
        ),
      ],
    ),
    TeacherCourse(
      id: '2',
      title: 'React Native Fundamentals',
      description: 'Build cross-platform mobile apps with React Native',
      category: 'Mobile Development',
      level: 'Beginner',
      price: 79.99,
      duration: '8 hours',
      imageUrl: 'assets/react_course.jpg',
      teacherId: 'teacher_001',
      teacherName: 'Dr. Sarah Johnson',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      isPublished: true,
      enrolledStudents: 189,
      rating: 4.6,
      totalRatings: 67,
      tags: ['React Native', 'JavaScript', 'Mobile'],
      modules: [],
    ),
  ];

  // Quizzes
  List<TeacherQuiz> _quizzes = [
    TeacherQuiz(
      id: 'quiz1',
      title: 'Flutter Basics Quiz',
      description: 'Test your knowledge of Flutter fundamentals',
      courseId: '1',
      courseName: 'Complete Flutter Development',
      questions: [
        QuizQuestion(
          id: 'q1',
          question: 'What is Flutter?',
          options: ['A web framework', 'A mobile UI framework', 'A database', 'An IDE'],
          correctAnswer: 1,
          explanation: 'Flutter is Google\'s UI toolkit for building natively compiled applications',
          points: 2,
        ),
      ],
      timeLimit: 30,
      attempts: 3,
      passingScore: 70.0,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      isActive: true,
      totalSubmissions: 156,
    ),
  ];

  // Student progress
  List<StudentProgress> _studentProgress = [
    StudentProgress(
      id: 'sp1',
      studentId: 'student_001',
      studentName: 'John Doe',
      studentEmail: 'john.doe@email.com',
      studentAvatar: 'assets/student1.jpg',
      courseId: '1',
      courseName: 'Complete Flutter Development',
      progressPercentage: 65.5,
      enrolledAt: DateTime.now().subtract(const Duration(days: 15)),
      lastAccessedAt: DateTime.now().subtract(const Duration(hours: 2)),
      totalLessons: 24,
      completedLessons: 16,
      lessonProgress: [],
      quizAttempts: [],
      overallGrade: 78.5,
      status: 'in_progress',
      timeSpent: 480,
    ),
  ];

  // Announcements
  List<TeacherAnnouncement> _announcements = [
    TeacherAnnouncement(
      id: 'ann1',
      title: 'New Assignment Available',
      content: 'Please complete the Flutter project assignment by next Friday.',
      courseId: '1',
      courseName: 'Complete Flutter Development',
      teacherId: 'teacher_001',
      teacherName: 'Dr. Sarah Johnson',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      isUrgent: false,
      isPublished: true,
      targetStudents: [],
      readCount: 89,
      type: 'assignment',
    ),
  ];

  // Getters
  String get teacherId => _teacherId;
  String get teacherName => _teacherName;
  String get teacherEmail => _teacherEmail;
  String get teacherAvatar => _teacherAvatar;
  String get teacherBio => _teacherBio;
  DashboardStats get dashboardStats => _dashboardStats;
  List<TeacherCourse> get courses => _courses;
  List<TeacherQuiz> get quizzes => _quizzes;
  List<StudentProgress> get studentProgress => _studentProgress;
  List<TeacherAnnouncement> get announcements => _announcements;

  // Course methods
  void addCourse(TeacherCourse course) {
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(TeacherCourse course) {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      notifyListeners();
    }
  }

  void deleteCourse(String courseId) {
    _courses.removeWhere((c) => c.id == courseId);
    notifyListeners();
  }

  void toggleCoursePublished(String courseId) {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      final course = _courses[index];
      _courses[index] = TeacherCourse(
        id: course.id,
        title: course.title,
        description: course.description,
        category: course.category,
        level: course.level,
        price: course.price,
        duration: course.duration,
        imageUrl: course.imageUrl,
        teacherId: course.teacherId,
        teacherName: course.teacherName,
        createdAt: course.createdAt,
        updatedAt: DateTime.now(),
        isPublished: !course.isPublished,
        enrolledStudents: course.enrolledStudents,
        rating: course.rating,
        totalRatings: course.totalRatings,
        tags: course.tags,
        modules: course.modules,
      );
      notifyListeners();
    }
  }

  // Quiz methods
  void addQuiz(TeacherQuiz quiz) {
    _quizzes.add(quiz);
    notifyListeners();
  }

  void updateQuiz(TeacherQuiz quiz) {
    final index = _quizzes.indexWhere((q) => q.id == quiz.id);
    if (index != -1) {
      _quizzes[index] = quiz;
      notifyListeners();
    }
  }

  void deleteQuiz(String quizId) {
    _quizzes.removeWhere((q) => q.id == quizId);
    notifyListeners();
  }

  // Announcement methods
  void addAnnouncement(TeacherAnnouncement announcement) {
    _announcements.insert(0, announcement);
    notifyListeners();
  }

  void updateAnnouncement(TeacherAnnouncement announcement) {
    final index = _announcements.indexWhere((a) => a.id == announcement.id);
    if (index != -1) {
      _announcements[index] = announcement;
      notifyListeners();
    }
  }

  void deleteAnnouncement(String announcementId) {
    _announcements.removeWhere((a) => a.id == announcementId);
    notifyListeners();
  }

  // Filter methods
  List<TeacherCourse> getCoursesByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return _courses.where((c) => c.isPublished).toList();
      case 'draft':
        return _courses.where((c) => !c.isPublished).toList();
      default:
        return _courses;
    }
  }

  List<StudentProgress> getStudentsByCourse(String courseId) {
    return _studentProgress.where((sp) => sp.courseId == courseId).toList();
  }

  List<TeacherQuiz> getQuizzesByCourse(String courseId) {
    return _quizzes.where((q) => q.courseId == courseId).toList();
  }
}