// This widget assumes you already have the TeacherCourse model with modules and lessons setup.
// You also need the youtube_player_flutter package added in your pubspec.yaml
// Add this line in pubspec.yaml under dependencies:
// youtube_player_flutter: ^8.1.1

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/teacher_course.dart';

class CourseDetailScreen extends StatelessWidget {
  final TeacherCourse course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(course.description),
            const SizedBox(height: 16),
            for (var module in course.modules) ...[
              Text(
                module.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (var lesson in module.lessons)
                ListTile(
                  title: Text(lesson.title),
                  // subtitle: Text(lesson.description),
                  trailing: const Icon(Icons.play_circle_fill, color: Colors.red),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonVideoScreen(lesson: lesson),
                      ),
                    );
                  },
                ),
              const Divider(),
            ]
          ],
        ),
      ),
    );
  }
}

class LessonVideoScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonVideoScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  State<LessonVideoScreen> createState() => _LessonVideoScreenState();
}

class _LessonVideoScreenState extends State<LessonVideoScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    final videoId = YoutubePlayer.convertUrlToId(widget.lesson.videoUrl) ?? "";
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
