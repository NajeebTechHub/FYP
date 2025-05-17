import 'package:flutter/material.dart';

enum ActivityType {
  watchedVideo,
  completedQuiz,
  submittedAssignment,
  completedModule,
  completedCourse,
  earnedCertificate,
  joinedDiscussion,
  downloadedResource,
  startedCourse,
}

class LearningActivity {
  final String id;
  final DateTime timestamp;
  final ActivityType activityType;
  final String courseId;
  final String courseName;
  final String? moduleId;
  final String? moduleName;
  final String title;
  final String description;
  final int? durationMinutes;
  final double? score;
  final bool? passed;

  LearningActivity({
    required this.id,
    required this.timestamp,
    required this.activityType,
    required this.courseId,
    required this.courseName,
    this.moduleId,
    this.moduleName,
    required this.title,
    required this.description,
    this.durationMinutes,
    this.score,
    this.passed,
  });

  // Gets appropriate icon for the activity type
  IconData getActivityIcon() {
    switch (activityType) {
      case ActivityType.watchedVideo:
        return Icons.play_circle_fill;
      case ActivityType.completedQuiz:
        return Icons.quiz;
      case ActivityType.submittedAssignment:
        return Icons.assignment_turned_in;
      case ActivityType.completedModule:
        return Icons.check_circle;
      case ActivityType.completedCourse:
        return Icons.workspace_premium;
      case ActivityType.earnedCertificate:
        return Icons.card_membership;
      case ActivityType.joinedDiscussion:
        return Icons.forum;
      case ActivityType.downloadedResource:
        return Icons.download;
      case ActivityType.startedCourse:
        return Icons.school;
    }
  }

  // Gets color based on activity type
  Color getActivityColor() {
    switch (activityType) {
      case ActivityType.watchedVideo:
        return Colors.blue;
      case ActivityType.completedQuiz:
        return Colors.purple;
      case ActivityType.submittedAssignment:
        return Colors.orange;
      case ActivityType.completedModule:
        return Colors.green;
      case ActivityType.completedCourse:
        return Colors.indigo;
      case ActivityType.earnedCertificate:
        return Colors.amber;
      case ActivityType.joinedDiscussion:
        return Colors.teal;
      case ActivityType.downloadedResource:
        return Colors.cyan;
      case ActivityType.startedCourse:
        return Colors.deepPurple;
    }
  }

  // Creates a formatted string representation of the activity for display
  String getActivitySummary() {
    switch (activityType) {
      case ActivityType.watchedVideo:
        final duration = durationMinutes != null ? ' (${durationMinutes}m)' : '';
        return 'Watched video: $title$duration';
      case ActivityType.completedQuiz:
        final scoreText = score != null ? ' - Score: ${(score! * 100).toInt()}%' : '';
        final passText = passed != null ? (passed! ? ' - Passed' : ' - Failed') : '';
        return 'Completed quiz: $title$scoreText$passText';
      case ActivityType.submittedAssignment:
        return 'Submitted assignment: $title';
      case ActivityType.completedModule:
        return 'Completed module: ${moduleName ?? title}';
      case ActivityType.completedCourse:
        return 'Completed course: $courseName';
      case ActivityType.earnedCertificate:
        return 'Earned certificate for: $courseName';
      case ActivityType.joinedDiscussion:
        return 'Joined discussion: $title';
      case ActivityType.downloadedResource:
        return 'Downloaded resource: $title';
      case ActivityType.startedCourse:
        return 'Started learning: $courseName';
    }
  }

  // Sample data for learning activities
  static List<LearningActivity> getSampleActivities() {
    return [
      LearningActivity(
        id: 'act1',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        activityType: ActivityType.completedQuiz,
        courseId: 'c1',
        courseName: 'Flutter App Development Masterclass',
        moduleId: 'm3',
        moduleName: 'State Management',
        title: 'Provider & State Management Quiz',
        description: 'Successfully completed quiz on Provider pattern',
        score: 0.85,
        passed: true,
      ),
      LearningActivity(
        id: 'act2',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        activityType: ActivityType.watchedVideo,
        courseId: 'c1',
        courseName: 'Flutter App Development Masterclass',
        moduleId: 'm3',
        moduleName: 'State Management',
        title: 'Understanding Provider Pattern',
        description: 'Watched lecture on Provider state management',
        durationMinutes: 22,
      ),
      LearningActivity(
        id: 'act3',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        activityType: ActivityType.completedModule,
        courseId: 'c1',
        courseName: 'Flutter App Development Masterclass',
        moduleId: 'm2',
        moduleName: 'UI Components',
        title: 'UI Components & Widgets',
        description: 'Completed all lessons in UI Components module',
      ),
      LearningActivity(
        id: 'act4',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        activityType: ActivityType.joinedDiscussion,
        courseId: 'c1',
        courseName: 'Flutter App Development Masterclass',
        title: 'Best Practices for Flutter Navigation',
        description: 'Joined forum discussion on navigation patterns',
      ),
      LearningActivity(
        id: 'act5',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        activityType: ActivityType.watchedVideo,
        courseId: 'c1',
        courseName: 'Flutter App Development Masterclass',
        moduleId: 'm2',
        moduleName: 'UI Components',
        title: 'Advanced Flutter Widgets',
        description: 'Watched lecture on custom widget development',
        durationMinutes: 35,
      ),
      LearningActivity(
        id: 'act6',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        activityType: ActivityType.downloadedResource,
        courseId: 'c1',
        courseName: 'Flutter App Development Masterclass',
        title: 'Flutter Widget Cheat Sheet',
        description: 'Downloaded PDF reference material',
      ),
      LearningActivity(
        id: 'act7',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        activityType: ActivityType.earnedCertificate,
        courseId: 'c2',
        courseName: 'UI/UX Design Principles',
        title: 'UI/UX Design Principles Certificate',
        description: 'Completed course and earned certificate',
      ),
      LearningActivity(
        id: 'act8',
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        activityType: ActivityType.startedCourse,
        courseId: 'c1',
        courseName: 'Flutter App Development Masterclass',
        title: 'Started Flutter App Development Masterclass',
        description: 'Began learning Flutter development',
      ),
      LearningActivity(
        id: 'act9',
        timestamp: DateTime.now().subtract(const Duration(days: 15)),
        activityType: ActivityType.completedCourse,
        courseId: 'c2',
        courseName: 'UI/UX Design Principles',
        title: 'Completed UI/UX Design Principles',
        description: 'Finished all modules and assignments',
      ),
      LearningActivity(
        id: 'act10',
        timestamp: DateTime.now().subtract(const Duration(days: 20)),
        activityType: ActivityType.submittedAssignment,
        courseId: 'c2',
        courseName: 'UI/UX Design Principles',
        moduleId: 'm5',
        moduleName: 'Final Project',
        title: 'Mobile App Redesign Project',
        description: 'Submitted final project for review',
      ),
    ];
  }
}