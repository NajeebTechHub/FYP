import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ManageModulesScreen extends StatefulWidget {
  const ManageModulesScreen({Key? key, required String courseId}) : super(key: key);

  @override
  State<ManageModulesScreen> createState() => _ManageModulesScreenState();
}

class _ManageModulesScreenState extends State<ManageModulesScreen> {
  List<Module> modules = [
    Module(title: 'Module 1', lessons: [
      Lesson(title: 'Lesson 1', description: 'Intro', videoUrl: 'https://www.youtube.com/watch?v=K18cpp_-gP8'),
    ]),
  ];

  void _addModule() async {
    final title = await _inputDialog(context, 'Add Module');
    if (title != null && title.isNotEmpty) {
      setState(() => modules.add(Module(title: title)));
    }
  }

  void _addLesson(Module module) async {
    final lesson = await Navigator.push<Lesson>(
      context,
      MaterialPageRoute(builder: (_) => LessonEditScreen()),
    );
    if (lesson != null) {
      setState(() => module.lessons.add(lesson));
    }
  }

  void _editLesson(Module module, int index) async {
    final lesson = await Navigator.push<Lesson>(
      context,
      MaterialPageRoute(builder: (_) => LessonEditScreen(existingLesson: module.lessons[index])),
    );
    if (lesson != null) {
      setState(() => module.lessons[index] = lesson);
    }
  }

  void _deleteLesson(Module module, int index) {
    setState(() => module.lessons.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Modules')),
      body: ListView.builder(
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return ExpansionTile(
            title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              ...module.lessons.asMap().entries.map((entry) {
                final i = entry.key;
                final lesson = entry.value;
                return ListTile(
                  title: Text(lesson.title),
                  subtitle: Text(lesson.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoUrl: lesson.videoUrl)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editLesson(module, i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteLesson(module, i),
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 12),
                child: OutlinedButton.icon(
                  onPressed: () => _addLesson(module),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Lesson'),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addModule,
        icon: const Icon(Icons.add),
        label: const Text('Add Module'),
      ),
    );
  }

  Future<String?> _inputDialog(BuildContext context, String title) async {
    String input = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          onChanged: (value) => input = value,
          decoration: const InputDecoration(hintText: 'Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, input), child: const Text('OK')),
        ],
      ),
    );
  }
}

class LessonEditScreen extends StatefulWidget {
  final Lesson? existingLesson;

  const LessonEditScreen({super.key, this.existingLesson});

  @override
  State<LessonEditScreen> createState() => _LessonEditScreenState();
}

class _LessonEditScreenState extends State<LessonEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _videoController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingLesson?.title ?? '');
    _descController = TextEditingController(text: widget.existingLesson?.description ?? '');
    _videoController = TextEditingController(text: widget.existingLesson?.videoUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Editor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Lesson Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _videoController,
              decoration: const InputDecoration(labelText: 'YouTube Video URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final lesson = Lesson(
                  title: _titleController.text,
                  description: _descController.text,
                  videoUrl: _videoController.text,
                );
                Navigator.pop(context, lesson);
              },
              child: const Text('Save Lesson'),
            )
          ],
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
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
      appBar: AppBar(title: const Text('Video Player')),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}

class Module {
  String title;
  List<Lesson> lessons;
  Module({required this.title, this.lessons = const []});
}

class Lesson {
  String title;
  String description;
  String videoUrl;
  Lesson({required this.title, required this.description, required this.videoUrl});
}
