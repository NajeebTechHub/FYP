import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/course_service.dart';
import '../../services/progress_service.dart';
import '../../services/quize_service.dart';
import '../models/teacher_announcement.dart';
import 'package:mentorcraft2/teacher/models/dashboard.dart';
import '../models/teacher_course.dart';
import '../models/teacher_quiz.dart';
import '../models/student_progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  final QuizService _quizService = QuizService();
  final ProgressService _progressService = ProgressService();

  StreamSubscription<List<TeacherCourse>>? _courseSubscription;
  StreamSubscription<List<TeacherQuiz>>? _quizSubscription;
  StreamSubscription<QuerySnapshot>? _announcementSubscription;

  String _teacherId = '';

  bool _isStatsLoaded = false;
  bool get isStatsLoaded => _isStatsLoaded;

  bool _areCoursesLoaded = false;
  bool get areCoursesLoaded => _areCoursesLoaded;

  bool _areQuizzesLoaded = false;
  bool get areQuizzesLoaded => _areQuizzesLoaded;

  bool _areAnnouncementsLoaded = false;
  bool get areAnnouncementsLoaded => _areAnnouncementsLoaded;

  int _totalStudents = 0;
  int _totalCourses = 0;
  double _averageRating = 0.0;

  int get totalStudents => _totalStudents;
  int get totalCourses => _totalCourses;
  double get averageRating => _averageRating;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isStudentProgressLoaded = false;
  bool get isStudentProgressLoaded => _isStudentProgressLoaded;


  bool _disposed = false;

  String _teacherName = '';
  String _teacherEmail = '';
  String _teacherAvatar = '';
  final String _teacherBio = 'Expert instructor at MentorCraft';

  bool _isQuizLoading = false;
  bool get isQuizLoading => _isQuizLoading;

  bool _isCoursesLoading = false;
  bool get isCoursesLoading => _isCoursesLoading;

  bool _isAnnouncementsLoading = false;
  bool get isAnnouncementsLoading => _isAnnouncementsLoading;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<TeacherCourse> _courses = [];
  List<TeacherQuiz> _quizzes = [];
  List<StudentProgress> _studentProgress = [];
  List<TeacherAnnouncement> _announcements = [];

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

  Future<void> initializeDataWithUser(AppUser user) async {
    clearData();
    _teacherId = user.id;
    _teacherName = user.displayName;
    _teacherEmail = user.email;
    _teacherAvatar = user.avatar.isNotEmpty
        ? Supabase.instance.client.storage.from('profile-images').getPublicUrl(user.avatar)
        : 'assets/placeholder.jpg';
    _isInitialized = true;

    await fetchCourses();
    subscribeToCourses(_teacherId);
    subscribeToQuizzes(_teacherId);
    await fetchStudentProgress(_teacherId);
    subscribeToAnnouncements();
    await fetchCourseStats();

    _safeNotifyListeners();
  }

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
    await fetchStudentProgress(_teacherId);
    subscribeToAnnouncements();
    await fetchCourseStats();

    _safeNotifyListeners();
  }

  void reSubscribeCourses() {
    subscribeToCourses(_teacherId);
  }

  String get teacherId => _teacherId;
  String get teacherName => _teacherName;
  String get teacherEmail => _teacherEmail;
  String get teacherAvatar => _teacherAvatar;
  String get teacherBio => _teacherBio;

  DashboardStats get dashboardStats {
    return DashboardStats(
      totalCourses: _totalCourses,
      totalStudents: _totalStudents,
      averageRating: _averageRating,
      publishedCourses: getCoursesByStatus('published').length,
      draftCourses: getCoursesByStatus('draft').length,
      totalRevenue: 0.0,
      monthlyRevenue: 0.0,
      totalQuizzes: _quizzes.length,
      pendingSubmissions: 0,
      totalReviews: 0,
      monthlyEarnings: [],
      topCourses: [],
      activeStudents: 0,
    );
  }

  List<TeacherCourse> get courses => _courses;
  List<TeacherQuiz> get quizzes => _quizzes;
  List<StudentProgress> get studentProgress => _studentProgress;
  List<TeacherAnnouncement> get announcements => _announcements;

  Future<void> fetchCourses([String? teacherId]) async {
    _isCoursesLoading = true;
    _areCoursesLoaded = false;
    _safeNotifyListeners();
    try {
      _courses = await _courseService.getCoursesByTeacher(teacherId ?? _teacherId);
    } catch (e) {
    } finally {
      _isCoursesLoading = false;
      _areCoursesLoaded = true;
      _safeNotifyListeners();
    }
  }


  Future<void> fetchAllPublishedAnnouncements() async {
    try {
      _areAnnouncementsLoaded = false;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _announcements = snapshot.docs
          .map((doc) => TeacherAnnouncement.fromMap(doc.data(), doc.id))
          .toList();

      print(_announcements);

      _areAnnouncementsLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error fetching all published announcements: $e');
      _areAnnouncementsLoaded = true;
      notifyListeners();
    }
  }



  void subscribeToCourses(String teacherId) {
    _isCoursesLoading = true;
    _areCoursesLoaded = false;
    _safeNotifyListeners();

    _courseSubscription?.cancel();
    _courseSubscription = _courseService.listenToCoursesByTeacher(teacherId).listen((updatedCourses) {
      _courses = updatedCourses;
      _isCoursesLoading = false;
      _areCoursesLoaded = true;
      fetchCourseStats();
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

  void subscribeToQuizzes(String teacherId) {
    _isQuizLoading = true;
    _areQuizzesLoaded = false;
    _safeNotifyListeners();

    _quizSubscription?.cancel();
    _quizSubscription = _quizService.listenToQuizzesByTeacher(teacherId).listen((updatedQuizzes) {
      _quizzes = updatedQuizzes;
      _isQuizLoading = false;
      _areQuizzesLoaded = true;
      fetchCourseStats();
      _safeNotifyListeners();
    });
  }

  Future<void> fetchQuizzes() async {
    _quizSubscription?.cancel();
    _isQuizLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('teacherId', isEqualTo: _teacherId)
          .get();

      _quizzes = querySnapshot.docs
          .map((doc) => TeacherQuiz.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching quizzes: $e');
    }

    _isQuizLoading = false;
    notifyListeners();
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

  Future<void> fetchStudentProgress(String currentTeacherId) async {
    try {
      _studentProgress.clear();
      _courses.clear();
      _isStudentProgressLoaded = false;
      notifyListeners();

      final enrollmentSnapshot = await FirebaseFirestore.instance
          .collectionGroup('enrolledUsers')
          .get();

      for (var doc in enrollmentSnapshot.docs) {
        final data = doc.data();
        final courseId = doc.reference.parent.parent?.id;
        if (courseId == null) continue;

        final courseDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .get();

        if (!courseDoc.exists) continue;
        final courseData = courseDoc.data()!;
        final courseTeacherId = courseData['teacherId'];

        if (courseTeacherId != currentTeacherId) continue;

        final courseName = courseData['title'] ?? 'Unknown Course';

        List<CourseModule> parsedModules = [];
        final rawModules = courseData['modules'];
        if (rawModules is List) {
          parsedModules = rawModules
              .whereType<Map<String, dynamic>>()
              .map((e) => CourseModule.fromJson(e))
              .toList();
        }

        if (_courses.every((c) => c.id != courseId)) {
          _courses.add(
            TeacherCourse(
              id: courseId,
              title: courseData['title'] ?? '',
              description: courseData['description'] ?? '',
              category: courseData['category'] ?? '',
              level: courseData['level'] ?? '',
              price: (courseData['price'] ?? 0).toDouble(),
              duration: courseData['duration'] ?? '',
              imageUrl: courseData['imageUrl'] ?? '',
              teacherId: courseTeacherId,
              teacherName: courseData['teacherName'] ?? '',
              createdAt: _parseTimestamp(courseData['createdAt']),
              updatedAt: _parseTimestamp(courseData['updatedAt']),
              isPublished: courseData['isPublished'] ?? false,
              enrolledStudents: courseData['enrolledStudents'] is List
                  ? (courseData['enrolledStudents'] as List).length
                  : 0,
              rating: (courseData['rating'] ?? 0).toDouble(),
              totalRating: courseData['totalRating'] ?? 0,
              modules: parsedModules,
            ),
          );
        }

        List<Map<String, dynamic>> parsedQuizAttempts = [];
        if (data['quizAttempts'] is List) {
          parsedQuizAttempts = (data['quizAttempts'] as List)
              .whereType<Map<String, dynamic>>()
              .toList();
        }

        final student = StudentProgress(
          id: '',
          studentId: data['userId']?.toString() ?? '',
          studentName: data['studentName']?.toString() ?? 'Unknown',
          studentEmail: data['studentEmail']?.toString() ?? '@gmail.com',
          studentAvatar: data['studentAvatar']?.toString() ?? '',
          courseId: courseId,
          courseName: courseName,
          progressPercentage: (data['progress'] is num)
              ? (data['progress'] as num).toDouble() * 100
              : 0.0,
          enrolledAt: data['enrolledAt'] is Timestamp
              ? (data['enrolledAt'] as Timestamp).toDate()
              : DateTime.now(),
          lastAccessedAt: data['lastAccessedAt'] is Timestamp
              ? (data['lastAccessedAt'] as Timestamp).toDate()
              : DateTime.now(),
          completedLessons: (data['completedLessons'] is List)
              ? (data['completedLessons'] as List).length
              : 0,
          totalLessons: data['totalLessons'] is int
              ? data['totalLessons'] as int
              : 0,
          overallGrade: (data['overallGrade'] is num)
              ? (data['overallGrade'] as num).toDouble()
              : 0.0,
          timeSpent: data['timeSpent'] is int ? data['timeSpent'] as int : 0,
          lessonProgress: [],
          quizAttempts: parsedQuizAttempts,
          status: data['status']?.toString() ?? 'enrolled',
        );

        _studentProgress.add(student);
      }

      _isStudentProgressLoaded = true;
      notifyListeners();
    } catch (e) {
      _isStudentProgressLoaded = true;
      notifyListeners();
    }
  }


  DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }




  void subscribeToAnnouncements() {
    _isAnnouncementsLoading = true;
    _areAnnouncementsLoaded = false;
    _safeNotifyListeners();

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

      _isAnnouncementsLoading = false;
      _areAnnouncementsLoaded = true;
      _safeNotifyListeners();
    });
  }


  Future<void> fetchAnnouncements() async {
    _isAnnouncementsLoading = true;
    _safeNotifyListeners();
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
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      _isAnnouncementsLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> addAnnouncement(TeacherAnnouncement announcement) async {
    await FirebaseFirestore.instance.collection('announcements').doc(announcement.id).set(announcement.toMap());
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

  void _safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchCourseStats() async {
    try {
      _isStatsLoaded = false;
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('teacherId', isEqualTo: _teacherId)
          .get();

      int totalCourses = snapshot.docs.length;
      int totalStudents = 0;
      double totalRating = 0.0;
      int ratingCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final enrolled = (data['enrolledStudents'] is num)
            ? (data['enrolledStudents'] as num).toInt()
            : 0;
        final rating = (data['rating'] ?? 0.0).toDouble();
        final reviewCount = (data['totalRating'] ?? 0).toInt();

        totalStudents += enrolled;

        if (rating > 0 && reviewCount > 0) {
          totalRating += rating;
          ratingCount++;
        }
      }

      _totalCourses = totalCourses;
      _totalStudents = totalStudents;
      _averageRating = ratingCount > 0 ? (totalRating / ratingCount) : 0.0;

      _isStatsLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error in fetchCourseStats: $e');
    }
  }


  List<MonthlyEarning> _monthlyEarningsList = [];
  List<MonthlyEarning> get monthlyEarningsList => _monthlyEarningsList;

  Future<void> fetchRealEarningsForChart() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final coursesSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('teacherId', isEqualTo: userId)
        .get();

    // Step 1: Map for earnings and enrollments per day
    Map<String, double> earningsPerDay = {};
    Map<String, int> enrollmentsPerDay = {};

    for (var courseDoc in coursesSnapshot.docs) {
      final courseId = courseDoc.id;
      final price = (courseDoc['price'] ?? 0).toDouble();

      final enrolledSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('enrolledUsers')
          .where('enrolledAt', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      for (var enrolledDoc in enrolledSnapshot.docs) {
        final enrolledAt = (enrolledDoc['enrolledAt'] as Timestamp).toDate();
        final day = enrolledAt.day.toString(); // like "1", "2", etc.

        final earning = price * 0.7;

        earningsPerDay.update(day, (value) => value + earning, ifAbsent: () => earning);
        enrollmentsPerDay.update(day, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    // Step 2: Convert to MonthlyEarning list
    _monthlyEarningsList = earningsPerDay.entries.map((entry) {
      final day = entry.key;
      final amount = entry.value;
      final enrollments = enrollmentsPerDay[day] ?? 0;

      return MonthlyEarning(
        month: day,
        amount: amount,
        enrollments: enrollments,
      );
    }).toList()
      ..sort((a, b) => int.parse(a.month).compareTo(int.parse(b.month)));

    notifyListeners();
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
