// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
// import '../models/teacher_course.dart';
// import '../../theme/color.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// class ModuleEditorScreen extends StatefulWidget {
//   final TeacherCourse course;
//
//   const ModuleEditorScreen({Key? key, required this.course}) : super(key: key);
//
//   @override
//   State<ModuleEditorScreen> createState() => _ModuleEditorScreenState();
// }
//
// class _ModuleEditorScreenState extends State<ModuleEditorScreen> {
//   List<Module> _modules = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _modules = List.from(widget.course.modules);
//   }
//
//   void _addModule() {
//     setState(() {
//       _modules.add(Module(title: 'New Module', lessons: [], id: ''));
//     });
//   }
//
//   void _addLesson(Module module) {
//     setState(() {
//       module.lessons.add(
//         Lesson(title: 'New Lesson', description: '', videoUrl: '', id: ''),
//       );
//     });
//   }
//
//   void _saveModules() {
//     final updatedCourse = widget.course.copyWith(modules: _modules);
//     Provider.of<TeacherProvider>(context, listen: false).updateCourse(updatedCourse);
//     Navigator.pop(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Modules updated successfully')),
//     );
//   }
//
//   Widget _buildLesson(Lesson lesson, Module module) {
//     final videoId = YoutubePlayer.convertUrlToId(lesson.videoUrl);
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               initialValue: lesson.title,
//               decoration: const InputDecoration(labelText: 'Lesson Title'),
//               onChanged: (value) => lesson.title = value,
//             ),
//             TextFormField(
//               initialValue: lesson.description,
//               decoration: const InputDecoration(labelText: 'Description'),
//               onChanged: (value) => lesson.description = value,
//             ),
//             TextFormField(
//               initialValue: lesson.videoUrl,
//               decoration: const InputDecoration(labelText: 'YouTube Video URL'),
//               onChanged: (value) => lesson.videoUrl = value,
//             ),
//             if (videoId != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: YoutubePlayer(
//                   controller: YoutubePlayerController(
//                     initialVideoId: videoId,
//                     flags: const YoutubePlayerFlags(autoPlay: false),
//                   ),
//                   showVideoProgressIndicator: true,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildModule(Module module) {
//     return ExpansionTile(
//       title: Text(module.title),
//       children: [
//         ...module.lessons.map((lesson) => _buildLesson(lesson, module)).toList(),
//         TextButton.icon(
//           onPressed: () => _addLesson(module),
//           icon: const Icon(Icons.add),
//           label: const Text('Add Lesson'),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Modules & Lessons'),
//         actions: [
//           TextButton(
//             onPressed: _saveModules,
//             child: const Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           ..._modules.map(_buildModule).toList(),
//           ElevatedButton.icon(
//             onPressed: _addModule,
//             icon: const Icon(Icons.add),
//             label: const Text('Add Module'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Extend TeacherCourse class with copyWith method
// extension TeacherCourseCopy on TeacherCourse {
//   TeacherCourse copyWith({List<Module>? modules}) {
//     return TeacherCourse(
//       id: id,
//       title: title,
//       description: description,
//       category: category,
//       level: level,
//       price: price,
//       duration: duration,
//       imageUrl: imageUrl,
//       teacherId: teacherId,
//       teacherName: teacherName,
//       createdAt: createdAt,
//       updatedAt: DateTime.now(),
//       isPublished: isPublished,
//       enrolledStudents: enrolledStudents,
//       rating: rating,
//       totalRatings: totalRatings,
//       modules: modules ?? this.modules,
//     );
//   }
// }
