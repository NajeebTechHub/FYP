import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/teacher_course.dart';

class CourseModulesScreen extends StatefulWidget {
  final TeacherCourse course;

  const CourseModulesScreen({super.key, required this.course});

  @override
  State<CourseModulesScreen> createState() => _CourseModulesScreenState();
}

class _CourseModulesScreenState extends State<CourseModulesScreen> {
  List<CourseModule> _modules = [];
  late final CollectionReference modulesRef;

  @override
  void initState() {
    super.initState();
    modulesRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.course.id)
        .collection('modules');
    _subscribeToModules();
  }

  void _subscribeToModules() {
    modulesRef.orderBy('order').snapshots().listen((moduleSnapshot) {
      for (final change in moduleSnapshot.docChanges) {
        final doc = change.doc;
        final moduleData = doc.data() as Map<String, dynamic>?;
        final moduleId = doc.id;

        if (change.type == DocumentChangeType.added) {
          final newModule = CourseModule.fromJson({
            ...?moduleData,
            'id': moduleId,
            'lessons': [],
          });

          setState(() {
            _modules.add(newModule);
          });

          // Subscribe to lessons
          _subscribeToLessons(doc.reference, moduleId);
        }

        else if (change.type == DocumentChangeType.modified) {
          final index = _modules.indexWhere((m) => m.id == moduleId);
          if (index != -1) {
            final oldLessons = _modules[index].lessons;
            final updatedModule = CourseModule.fromJson({
              ...?moduleData,
              'id': moduleId,
              'lessons': oldLessons.map((l) => l.toJson()).toList(),
            });

            setState(() {
              _modules[index] = updatedModule;
            });
          }
        }

        else if (change.type == DocumentChangeType.removed) {
          setState(() {
            _modules.removeWhere((m) => m.id == moduleId);
          });
        }
      }
    });
  }

  void _subscribeToLessons(DocumentReference moduleRef, String moduleId) {
    moduleRef.collection('lessons').orderBy('order').snapshots().listen((lessonSnapshot) {
      final lessons = lessonSnapshot.docs.map((lessonDoc) {
        final lessonData = lessonDoc.data();
        lessonData['id'] = lessonDoc.id;
        return Lesson.fromJson(lessonData);
      }).toList();

      if (!mounted) return;

      setState(() {
        final index = _modules.indexWhere((m) => m.id == moduleId);
        if (index != -1) {
          final updatedModule = _modules[index].copyWith(lessons: lessons);
          _modules[index] = updatedModule;
        }
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _modules.length,
        itemBuilder: (context, moduleIndex) {
          final module = _modules[moduleIndex];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                module.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                module.description,
                style: const TextStyle(fontSize: 13),
              ),
              children: [
                ...module.lessons.map((lesson) => _buildLessonTile(lesson, module)).toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      onPressed: () => _showEditModuleSheet(context, module),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Are you sure you want to delete this module? All its lessons will be removed.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await modulesRef.doc(module.id).delete();
                        }
                      },

                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Lesson"),
                      onPressed: () => _showAddLessonSheet(context, module),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddModuleSheet(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Module'),
      ),
    );
  }

  Widget _buildLessonTile(Lesson lesson, CourseModule module) {
    return ListTile(
      title: Text(
        '${lesson.order}. ${lesson.title}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Duration: ${lesson.duration} min • Type: ${lesson.type}'),
          const SizedBox(height: 8),
          if (lesson.type == 'video' && lesson.videoUrl.isNotEmpty)
            YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: YoutubePlayer.convertUrlToId(lesson.videoUrl) ?? '',
                flags: const YoutubePlayerFlags(
                  autoPlay: false,
                  mute: false,
                ),
              ),
              showVideoProgressIndicator: true,
            ),
          if (lesson.type == 'text')
            Text(
              lesson.content,
              style: const TextStyle(color: Colors.black87),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditLessonSheet(context, module, lesson),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text('Are you sure you want to delete this lesson?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await modulesRef.doc(module.id).collection('lessons').doc(lesson.id).delete();
                  }
                },

              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showAddModuleSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Module',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Module Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Module'),
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;

                      final newModule = {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': titleController.text.trim(),
                        'description': descController.text.trim(),
                        'order': _modules.length + 1,
                      };

                      await modulesRef.doc(newModule['id'] as String?).set(newModule);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditModuleSheet(BuildContext context, CourseModule module) {
    final titleController = TextEditingController(text: module.title);
    final descController = TextEditingController(text: module.description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Module', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Module Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Update Module'),
                    onPressed: () async {
                      await modulesRef.doc(module.id).update({
                        'title': titleController.text.trim(),
                        'description': descController.text.trim(),
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddLessonSheet(BuildContext context, CourseModule module) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final videoUrlController = TextEditingController();
    final durationController = TextEditingController();
    String selectedType = 'video';

    final lessonsRef = modulesRef.doc(module.id).collection('lessons');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Lesson',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Lesson Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                    DropdownMenuItem(value: 'text', child: Text('Text')),
                  ],
                  onChanged: (value) => selectedType = value ?? 'video',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'YouTube URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (min)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Lesson'),
                    onPressed: () async {
                      final newLesson = {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': titleController.text.trim(),
                        'type': selectedType,
                        'videoUrl': videoUrlController.text.trim(),
                        'content': contentController.text.trim(),
                        'duration': int.tryParse(durationController.text.trim()) ?? 0,
                        'order': module.lessons.length + 1,
                      };

                      await lessonsRef.doc(newLesson['id'] as String?).set(newLesson);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditLessonSheet(BuildContext context, CourseModule module, Lesson lesson) {
    final titleController = TextEditingController(text: lesson.title);
    final contentController = TextEditingController(text: lesson.content);
    final videoUrlController = TextEditingController(text: lesson.videoUrl);
    final durationController = TextEditingController(text: lesson.duration.toString());
    String selectedType = lesson.type;

    final lessonRef = modulesRef.doc(module.id).collection('lessons').doc(lesson.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Lesson', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Lesson Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                    DropdownMenuItem(value: 'text', child: Text('Text')),
                  ],
                  onChanged: (value) => selectedType = value ?? 'video',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(labelText: 'YouTube URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duration (min)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Update Lesson'),
                    onPressed: () async {
                      await lessonRef.update({
                        'title': titleController.text.trim(),
                        'type': selectedType,
                        'videoUrl': videoUrlController.text.trim(),
                        'content': contentController.text.trim(),
                        'duration': int.tryParse(durationController.text.trim()) ?? 0,
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
