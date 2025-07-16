import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/course_service.dart';
import '../../services/progress_service.dart';
import '../../services/quize_service.dart';
import '../models/teacher_announcement.dart';
import '../models/teacher_course.dart';
import '../models/teacher_quiz.dart';
import '../models/student_progress.dart';

class TeacherProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  final QuizService _quizService = QuizService();
  final ProgressService _progressService = ProgressService();

  StreamSubscription<List<TeacherCourse>>? _courseSubscription;
  StreamSubscription<List<TeacherQuiz>>? _quizSubscription;
  StreamSubscription<QuerySnapshot>? _announcementSubscription;

  bool _disposed = false;

  // Dynamic fields
  String _teacherId = '';
  String _teacherName = '';
  String _teacherEmail = '';
  String _teacherAvatar = '';
  final String _teacherBio = 'Expert instructor at MentorCraft';

  bool _isQuizLoading = false;
  bool get isQuizLoading => _isQuizLoading;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final DashboardStats _dashboardStats = DashboardStats(
    totalCourses: 0,
    publishedCourses: 0,
    draftCourses: 0,
    totalStudents: 0,
    activeStudents: 0,
    totalRevenue: 0,
    monthlyRevenue: 0,
    totalQuizzes: 0,
    pendingSubmissions: 0,
    averageRating: 0,
    totalReviews: 0,
    monthlyEarnings: [],
    topCourses: [],
  );

  List<TeacherCourse> _courses = [];
  List<TeacherQuiz> _quizzes = [];
  List<StudentProgress> _studentProgress = [];
  List<TeacherAnnouncement> _announcements = [];

  // Clears all data when user logs out or switches
  void clearData() {
    _teacherId = '';
    _teacherName = '';
    _teacherEmail = '';
    _teacherAvatar = '';
    _isInitialized = false;

    _courses = [];
    _quizzes = [];
    _studentProgress = [];
    _announcements = [];

    _courseSubscription?.cancel();
    _quizSubscription?.cancel();
    _announcementSubscription?.cancel();

    _safeNotifyListeners();
  }

  // Initialize using custom user
  Future<void> initializeDataWithUser(AppUser user) async {
    clearData();

    _teacherId = user.id;
    _teacherName = user.displayName;
    _teacherEmail = user.email;
    _teacherAvatar = user.avatar.isNotEmpty ? user.avatar : 'assets/placeholder.jpg';
    _isInitialized = true;

    await fetchCourses();
    subscribeToCourses(_teacherId);
    subscribeToQuizzes(_teacherId);
    await fetchStudentProgress();
    subscribeToAnnouncements();

    _safeNotifyListeners();
  }

  // ✅ Fallback init using FirebaseAuth user
  Future<void> initializeData() async {
    clearData();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _teacherId = user.uid;
      _teacherName = user.displayName ?? 'Instructor';
      _teacherEmail = user.email ?? '';
      _teacherAvatar = user.photoURL ?? 'assets/placeholder.jpg';
      _isInitialized = true;
    }

    await fetchCourses();
    subscribeToCourses(_teacherId);
    subscribeToQuizzes(_teacherId);
    await fetchStudentProgress();
    subscribeToAnnouncements();

    _safeNotifyListeners();
  }

  void reSubscribeCourses() {
    subscribeToCourses(_teacherId);
  }

  // GETTERS
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

  // COURSES
  Future<void> fetchCourses([String? teacherId]) async {
    try {
      _courses = await _courseService.getCoursesByTeacher(teacherId ?? _teacherId);
      _safeNotifyListeners();
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
      _safeNotifyListeners();
    });
  }

  Future<void> addCourse(TeacherCourse course) async {
    await _courseService.addCourse(course);
    reSubscribeCourses();
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

  // QUIZZES
  void subscribeToQuizzes(String teacherId) {
    _quizSubscription?.cancel();
    _quizSubscription = _quizService.listenToQuizzesByTeacher(teacherId).listen((updatedQuizzes) {
      _quizzes = updatedQuizzes;
      _safeNotifyListeners();
    });
  }

  Future<void> fetchQuizzes() async {
    _isQuizLoading = true;
    _safeNotifyListeners();
    try {
      _quizzes = await _quizService.getQuizzesByTeacher(_teacherId);
    } catch (e) {
      debugPrint("Error fetching quizzes: $e");
    } finally {
      _isQuizLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> addQuiz(TeacherQuiz quiz) async {
    await _quizService.addQuiz(quiz);
  }

  Future<void> deleteQuiz(String quizId) async {
    await _quizService.deleteQuiz(quizId);
    _quizzes.removeWhere((q) => q.id == quizId);
    _safeNotifyListeners();
  }

  Future<void> updateQuiz(TeacherQuiz quiz) async {
    await _quizService.updateQuiz(quiz);
    final index = _quizzes.indexWhere((q) => q.id == quiz.id);
    if (index != -1) {
      _quizzes[index] = quiz;
      _safeNotifyListeners();
    }
  }

  // STUDENT PROGRESS
  Future<void> fetchStudentProgress() async {
    try {
      _studentProgress = await _progressService.getStudentProgressByTeacher(_teacherId);
      _safeNotifyListeners();
    } catch (e) {
      debugPrint("Error fetching student progress: $e");
    }
  }

  // ANNOUNCEMENTS
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
      _safeNotifyListeners();
    });
  }

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

      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    }
  }

  Future<void> addAnnouncement(TeacherAnnouncement announcement) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(announcement.id)
        .set(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await FirebaseFirestore.instance.collection('announcements').doc(id).delete();
  }

  void toggleAnnouncementPublish(String id) {
    final index = _announcements.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = _announcements[index].copyWith(
        isPublished: !_announcements[index].isPublished,
        updatedAt: DateTime.now(),
      );
      FirebaseFirestore.instance.collection('announcements').doc(id).update(updated.toMap());
    }
  }

  // FILTERS
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

  // INTERNAL
  void _safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _courseSubscription?.cancel();
    _quizSubscription?.cancel();
    _announcementSubscription?.cancel();
    super.dispose();
  }
}
