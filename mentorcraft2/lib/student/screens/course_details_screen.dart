import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/course.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  const CourseDetailsScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final Map<int, bool> _expandedModules = {};

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
      modules.add({
        'title': moduleDoc['title'],
        'description': moduleDoc['description'],
        'lessons': lessonsSnapshot.docs.map((doc) => doc.data()).toList(),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (course.imageUrl.isNotEmpty &&
                  course.imageUrl.startsWith('http'))
                  ? Image.network(
                course.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/placeholder.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
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
                              title: Text(
                                module['title'] ?? '',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(module['description'] ?? ''),
                              trailing: IconButton(
                                icon: Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _expandedModules[index] = !isExpanded;
                                  });
                                },
                              ),
                            ),
                            if (isExpanded) ...[
                              const Divider(),
                              ...lessons.map((lesson) {
                                final videoUrl = lesson['videoUrl'] ?? '';
                                final videoId = YoutubePlayer.convertUrlToId(videoUrl);

                                return ListTile(
                                  leading: const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 30),
                                  title: Text(lesson['title'] ?? ''),
                                  subtitle: Text(
                                    '${lesson['duration']} min • ${lesson['type'] ?? 'Video'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onTap: () {
                                    if (videoId != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => YoutubeLessonPlayerScreen(videoId: videoId),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Invalid YouTube URL')),
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class YoutubeLessonPlayerScreen extends StatefulWidget {
  final String videoId;

  const YoutubeLessonPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YoutubeLessonPlayerScreen> createState() => _YoutubeLessonPlayerScreenState();
}

class _YoutubeLessonPlayerScreenState extends State<YoutubeLessonPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) => Scaffold(
        appBar: AppBar(title: const Text('Lesson Video')),
        body: Center(child: player),
      ),
    );
  }
}
