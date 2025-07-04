import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/course_service.dart';
import '../../services/quize_service.dart';
import '../models/teacher_course.dart';
import '../models/teacher_quiz.dart';
import '../models/student_progress.dart';
import '../models/teacher_announcement.dart';

class TeacherProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  final QuizService _quizService = QuizService();
  StreamSubscription<List<TeacherCourse>>? _courseSubscription;
  StreamSubscription<List<TeacherQuiz>>? _quizSubscription;

  // constructor to auto-fetch data
  TeacherProvider() {
    fetchCourses(_teacherId);
    subscribeToCourses(_teacherId);
    subscribeToQuizzes(_teacherId);
  }

  // State
  bool _isQuizLoading = false;
  bool get isQuizLoading => _isQuizLoading;

  // Teacher Info
  String _teacherId = 'teacher_001';
  String _teacherName = 'Dr. Sarah Johnson';
  String _teacherEmail = 'sarah.johnson@mentorcraft.com';
  String _teacherAvatar = 'assets/images/11.png';
  String _teacherBio = 'Experienced educator and technology expert with 10+ years in the field.';

  // Dashboard Stats
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

  // Data Lists
  List<TeacherCourse> _courses = [];
  List<TeacherQuiz> _quizzes = [];
  List<StudentProgress> _studentProgress = [];
  List<TeacherAnnouncement> _announcements = [];

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

  // Course Methods
  Future<void> fetchCourses([String? teacherId]) async {
    _courses = await _courseService.getCoursesByTeacher(teacherId ?? _teacherId);
    notifyListeners();
  }

  void subscribeToCourses(String teacherId) {
    _courseSubscription?.cancel();
    _courseSubscription = _courseService.listenToCoursesByTeacher(teacherId).listen((updatedCourses) {
      _courses = updatedCourses;
      notifyListeners();
    });
  }

  Future<void> addCourse(TeacherCourse course) async {
    await _courseService.addCourse(course);
  }

  Future<void> updateCourse(TeacherCourse course) async {
    await _courseService.updateCourse(course);
  }

  Future<void> deleteCourse(String courseId) async {
    await _courseService.deleteCourse(courseId);
  }

  Future<void> toggleCoursePublished(String courseId, bool publish) async {
    await _courseService.toggleCoursePublished(courseId, publish);
  }

  // Quiz Methods
  void subscribeToQuizzes(String teacherId) {
    _quizSubscription?.cancel();
    _quizSubscription = _quizService.listenToQuizzesByTeacher(teacherId).listen((updatedQuizzes) {
      _quizzes = updatedQuizzes;
      notifyListeners();
    });
  }

  Future<void> fetchQuizzes() async {
    _isQuizLoading = true;
    notifyListeners();
    try {
      _quizzes = await _quizService.getQuizzesByTeacher(_teacherId);
    } catch (e) {
      debugPrint("Failed to fetch quizzes: $e");
    } finally {
      _isQuizLoading = false;
      notifyListeners();
    }
  }

  Future<void> addQuiz(TeacherQuiz quiz) async {
    try {
      await _quizService.addQuiz(quiz);
    } catch (e) {
      debugPrint("Error adding quiz: $e");
    }
  }


  Future<void> deleteQuiz(String quizId) async {
    try {
      await _quizService.deleteQuiz(quizId);  // Firestore delete
      _quizzes.removeWhere((q) => q.id == quizId);  // Local state update
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting quiz: $e");
    }
  }


  Future<void> updateQuiz(TeacherQuiz quiz) async {
    try {
      await _quizService.updateQuiz(quiz);  // Firestore update
      final index = _quizzes.indexWhere((q) => q.id == quiz.id);
      if (index != -1) {
        _quizzes[index] = quiz;             // Local state update
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating quiz: $e");
    }
  }


  // Announcement Methods
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

  // Filters
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

  // Cleanup
  @override
  void dispose() {
    _courseSubscription?.cancel();
    _quizSubscription?.cancel();
    super.dispose();
  }
}
