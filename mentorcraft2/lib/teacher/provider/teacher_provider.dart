import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/course_service.dart';
import '../../services/progress_service.dart';
import '../../services/quize_service.dart';
import '../models/teacher_course.dart';
import '../models/teacher_quiz.dart';
import '../models/student_progress.dart';
import '../models/teacher_announcement.dart';

class TeacherProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  final QuizService _quizService = QuizService();
  final ProgressService _progressService = ProgressService();

  StreamSubscription<List<TeacherCourse>>? _courseSubscription;
  StreamSubscription<List<TeacherQuiz>>? _quizSubscription;
  StreamSubscription<QuerySnapshot>? _announcementSubscription;

  // Teacher Info
  final String _teacherId = 'teacher_001';
  final String _teacherName = 'Dr. Sarah Johnson';
  final String _teacherEmail = 'sarah.johnson@mentorcraft.com';
  final String _teacherAvatar = 'assets/images/11.png';
  final String _teacherBio =
      'Experienced educator and technology expert with 10+ years in the field.';

  // State
  bool _isQuizLoading = false;
  bool get isQuizLoading => _isQuizLoading;

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

  // Constructor
  TeacherProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchCourses();
    subscribeToCourses(_teacherId);
    subscribeToQuizzes(_teacherId);
    await fetchStudentProgress();
    subscribeToAnnouncements(); // ✅ Real-time listener
  }

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
    try {
      _courses = await _courseService.getCoursesByTeacher(teacherId ?? _teacherId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }
  }

  void subscribeToCourses(String teacherId) {
    _courseSubscription?.cancel();
    _courseSubscription = _courseService
        .listenToCoursesByTeacher(teacherId)
        .listen((updatedCourses) {
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
    _quizSubscription = _quizService
        .listenToQuizzesByTeacher(teacherId)
        .listen((updatedQuizzes) {
      _quizzes = updatedQuizzes;
      notifyListeners();
    });
  }

  Future<void> fetchStudentProgress() async {
    try {
      _studentProgress = await _progressService.getStudentProgressByTeacher(_teacherId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching student progress: $e");
    }
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
      await _quizService.deleteQuiz(quizId);
      _quizzes.removeWhere((q) => q.id == quizId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting quiz: $e");
    }
  }

  Future<void> updateQuiz(TeacherQuiz quiz) async {
    try {
      await _quizService.updateQuiz(quiz);
      final index = _quizzes.indexWhere((q) => q.id == quiz.id);
      if (index != -1) {
        _quizzes[index] = quiz;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating quiz: $e");
    }
  }

  // 🔥 Real-Time Announcement Listener
  void subscribeToAnnouncements() {
    _announcementSubscription?.cancel();
    _announcementSubscription = FirebaseFirestore.instance
        .collection('announcements')
        .where('teacherId', isEqualTo: _teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _announcements = snapshot.docs.map((doc) {
        final data = doc.data();
        return TeacherAnnouncement.fromMap(data, doc.id);
      }).toList();
      notifyListeners();
    });
  }

  // Optional (still usable but not necessary if stream is active)
  Future<void> fetchAnnouncements() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .where('teacherId', isEqualTo: _teacherId)
          .orderBy('createdAt', descending: true)
          .get();

      _announcements = snapshot.docs.map((doc) {
        final data = doc.data();
        return TeacherAnnouncement.fromMap(data, doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    await FirebaseFirestore.instance.collection('announcements').doc(id).delete();
  }

  Future<void> addAnnouncement(TeacherAnnouncement announcement) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      final docRef = _firestore.collection('announcements').doc(announcement.id);
      await docRef.set(announcement.toMap());
    } catch (e) {
      debugPrint('Error adding announcement: $e');
      rethrow;
    }
  }

  void toggleAnnouncementPublish(String id) {
    final index = _announcements.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = _announcements[index].copyWith(
        isPublished: !_announcements[index].isPublished,
        updatedAt: DateTime.now(),
      );
      FirebaseFirestore.instance
          .collection('announcements')
          .doc(id)
          .update(updated.toMap());
    }
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
    _announcementSubscription?.cancel(); // ✅ stop announcement stream
    super.dispose();
  }
}
