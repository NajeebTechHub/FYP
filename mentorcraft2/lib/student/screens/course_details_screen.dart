import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/course.dart';
import '../models/certificate.dart';
import 'certificate/certificate_detail_bottom_sheet.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  const CourseDetailsScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final Map<int, bool> _expandedModules = {};
  late String userId;
  List<String> completedLessons = [];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    fetchCompletedLessons();
  }

  Future<void> fetchCompletedLessons() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.id)
          .collection('enrolledUsers')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          completedLessons = List<String>.from(data['completedLessons'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error fetching completed lessons: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchModulesWithLessons(String courseId) async {
    final modulesSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .orderBy('order')
        .get();

    List<Map<String, dynamic>> modules = [];

    for (var moduleDoc in modulesSnapshot.docs) {
      final lessonsSnapshot = await moduleDoc.reference.collection('lessons').orderBy('order').get();
      final lessons = lessonsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      modules.add({
        'title': moduleDoc['title'],
        'description': moduleDoc['description'],
        'lessons': lessons,
      });
    }

    return modules;
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseHeader(course),
            const SizedBox(height: 24),
            const Text('Modules & Lessons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchModulesWithLessons(course.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No modules found');
                }

                final modules = snapshot.data!;
                return _buildModulesList(modules, course);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: (course.imageUrl.isNotEmpty && course.imageUrl.startsWith('http'))
              ? Image.network(course.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover)
              : Image.asset('assets/placeholder.jpg', width: double.infinity, height: 200, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('By ${course.teacherName}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 16),
        Text(course.description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.timer, size: 20),
            const SizedBox(width: 4),
            Text('${course.duration} hrs'),
            const SizedBox(width: 16),
            const Icon(Icons.school, size: 20),
            const SizedBox(width: 4),
            Text(course.level),
          ],
        ),
        const SizedBox(height: 16),
        Text('Price: \$${course.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildModulesList(List<Map<String, dynamic>> modules, Course course) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        final lessons = module['lessons'] as List<dynamic>;
        final isExpanded = _expandedModules[index] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  title: Text(module['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(module['description'] ?? ''),
                  trailing: IconButton(
                    icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    onPressed: () => setState(() => _expandedModules[index] = !isExpanded),
                  ),
                ),
                if (isExpanded)
                  ...lessons.map((lesson) => _buildLessonTile(lesson, modules)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonTile(Map<String, dynamic> lesson, List<Map<String, dynamic>> modules) {
    final videoUrl = lesson['videoUrl'] ?? '';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    final lessonId = lesson['id'];
    final alreadyCompleted = completedLessons.contains(lessonId);

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.play_circle_fill, color: alreadyCompleted ? Colors.green : Colors.redAccent, size: 30),
          title: Text(lesson['title'] ?? ''),
          subtitle: Text('${lesson['duration']} min • ${lesson['type'] ?? 'Video'}'),
          onTap: () {
            if (videoId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => YoutubeLessonPlayerScreen(videoId: videoId),
                ),
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: alreadyCompleted ? null : () => _handleMarkComplete(lessonId, modules),
            icon: Icon(alreadyCompleted ? Icons.check_circle : Icons.check),
            label: Text(alreadyCompleted ? 'Completed' : 'Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: alreadyCompleted ? Colors.green : Colors.blue,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Future<void> _handleMarkComplete(String lessonId, List<Map<String, dynamic>> modules) async {
    final newCompleted = List<String>.from(completedLessons)..add(lessonId);
    final totalLessons = modules.expand((m) => m['lessons'] as List).length;
    final progress = newCompleted.length / totalLessons;

    final docRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.course.id)
        .collection('enrolledUsers')
        .doc(userId);

    await docRef.set({
      'completedLessons': newCompleted,
      'progress': progress,
      'lastAccessedDate': Timestamp.now(),
      if (progress >= 1.0) 'isCertificateIssued': true,
    }, SetOptions(merge: true));

    if (!mounted) return;

    setState(() {
      completedLessons = newCompleted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lesson marked as complete')),
    );

    if (progress >= 1.0) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final studentName = currentUser?.displayName ?? 'Student';

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final shortId = 'CERT-${timestamp.substring(timestamp.length - 5)}';

      final certificate = Certificate(
        id: shortId,
        courseId: widget.course.id,
        courseName: widget.course.title,
        instructor: widget.course.teacherName,
        issueDate: DateTime.now(),
        completionDate: DateTime.now(),
        category: widget.course.level,
        description: widget.course.description,
        imageUrl: 'assets/certificate_template.png',
        status: CertificateStatus.issued,
        courseRating: widget.course.rating,
        courseDurationHours: int.tryParse(widget.course.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        skills: ['Skill A', 'Skill B'],
      );

      // SAVE TO FIRESTORE
      await FirebaseFirestore.instance.collection('certificates').add({
        'userId': userId,
        'courseId': certificate.courseId,
        'courseName': certificate.courseName,
        'instructor': certificate.instructor,
        'issueDate': Timestamp.fromDate(certificate.issueDate),
        'completionDate': Timestamp.fromDate(certificate.completionDate),
        'category': certificate.category,
        'description': certificate.description,
        'imageUrl': certificate.imageUrl,
        'status': certificate.status.name,
        'courseRating': certificate.courseRating,
        'courseDurationHours': certificate.courseDurationHours,
        'skills': certificate.skills,
      });

      // SHOW SHEET AFTER FRAME
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCertificateDetailsSheet(context, certificate, studentName: studentName);
      });
    }
  }

  Future<String> fetchStudentName(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc.data()!['name'] ?? 'Student';
    }
    return 'Student';
  }
}

class YoutubeLessonPlayerScreen extends StatelessWidget {
  final String videoId;

  const YoutubeLessonPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: controller),
      builder: (context, player) => Scaffold(
        appBar: AppBar(title: const Text('Lesson Video')),
        body: Center(child: player),
      ),
    );
  }
}
