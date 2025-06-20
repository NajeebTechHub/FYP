// import 'package:flutter/material.dart';
// import '../theme/color.dart';
//
// class CoursesHeroSection extends StatelessWidget {
//   const CoursesHeroSection({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 150,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         image: DecorationImage(
//           // image: const NetworkImage('https://via.placeholder.com/800x400'),
//           image: AssetImage('assets/images/41.png'),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(
//             AppColors.main.withOpacity(0.5),
//             BlendMode.srcOver,
//           ),
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             '"All Courses"',
//             style: Theme.of(context).textTheme.displayLarge?.copyWith(
//               color: Colors.white,
//               fontSize: MediaQuery.of(context).size.width > 600 ? 32 : 24,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Explore our wide range of courses',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: Colors.white.withOpacity(0.9),
//               fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           // const SizedBox(height: 24),
//           // ElevatedButton.icon(
//           //   onPressed: () {},
//           //   style: ElevatedButton.styleFrom(
//           //     backgroundColor: Colors.white,
//           //     foregroundColor: AppColors.primary,
//           //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           //   ),
//           //   icon: const Icon(Icons.play_circle_outline),
//           //   label: const Text('Start Learning Now'),
//           // ),
//         ],
//       ),
//     );
//   }
// }