import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/screens/progress_tracking/analytics_tab.dart';
import 'package:mentorcraft2/student/screens/progress_tracking/certificate_tab.dart';
import 'package:mentorcraft2/student/screens/progress_tracking/overview.dart';
import '../models/course_progress.dart';
import 'package:mentorcraft2/theme/color.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({Key? key}) : super(key: key);

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<CourseProgress> _courses = [];
  late ProgressSummary _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final courses = await _fetchCourseProgress(uid);
    final certificates = await _fetchCertificates(uid);
    final summary = ProgressSummary.generateFromCourseProgress(courses, certificates);
    setState(() {
      _courses = courses;
      _summary = summary;
      _isLoading = false;
    });
  }

  Future<List<CourseProgress>> _fetchCourseProgress(String uid) async {
    final coursesSnapshot = await FirebaseFirestore.instance.collection('courses').get();
    List<CourseProgress> progressList = [];

    for (var courseDoc in coursesSnapshot.docs) {
      final courseData = courseDoc.data();
      final courseTitle = courseData['title'] ?? 'Unknown Course';
      final level = courseData['level'] ?? 'General';

      final enrolledUserDoc = await courseDoc.reference.collection('enrolledUsers').doc(uid).get();
      if (enrolledUserDoc.exists) {
        final userData = enrolledUserDoc.data();
        final progress = (userData?['progress'] ?? 0.0) as double;

        progressList.add(
          CourseProgress(
            courseId: courseDoc.id,
            courseName: courseTitle,
            category: level,
            percentComplete: progress,
            totalMinutes: 0,
            minutesCompleted: 0,
            lastAccessed: DateTime.now(),
            courseStartDate: DateTime.now(),
            activityLogs: [],
          ),
        );
      }
    }

    return progressList;
  }

  Future<List<Certificate>> _fetchCertificates(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('certificates')
        .where('userId', isEqualTo: uid)
        .get();
    return snap.docs.map((doc) {
      return Certificate.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Progress Tracker',
          style: TextStyle(
            color: theme.appBarTheme.titleTextStyle?.color ?? (isDark ? AppColors.textLight : Colors.black),
          ),
        ),
        backgroundColor: AppColors.darkBlue,
        iconTheme: theme.iconTheme,
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.textLight : Colors.white,
          unselectedLabelColor: AppColors.textFaded,
          indicatorColor: isDark ? AppColors.textLight : Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'),
            Tab(text: 'Certificates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(
            progressSummary: _summary,
            courseProgressList: _courses,
            isTablet: isTablet,
          ),
          AnalyticsTab(
            courseProgress: _courses,
            isTablet: isTablet,
          ),
          CertificatesTab(
            progressSummary: _summary,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }
}
