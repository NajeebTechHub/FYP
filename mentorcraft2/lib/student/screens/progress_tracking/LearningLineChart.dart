// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
//
// import '../../../theme/color.dart';
//
// class LearningLineChartSection extends StatelessWidget {
//   final List<WeeklyProgress> weeklyProgress;
//
//   const LearningLineChartSection({super.key, required this.weeklyProgress});
//
//   @override
//   Widget build(BuildContext context) {
//     if (weeklyProgress.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16),
//         child: Center(
//           child: Text(
//             'No learning activity yet',
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//       );
//     }
//
//     final maxHours = weeklyProgress
//         .map((data) => data.hours)
//         .reduce((a, b) => a > b ? a : b);
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Weekly Learning Hours',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             AspectRatio(
//               aspectRatio: 1.6,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(show: true),
//                   titlesData: FlTitlesData(
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         interval: 1,
//                         getTitlesWidget: (value, meta) {
//                           final index = value.toInt();
//                           if (index < 0 || index >= weeklyProgress.length) {
//                             return const SizedBox.shrink();
//                           }
//                           final date = weeklyProgress[index].weekStart;
//                           final formatter = DateFormat.Md();
//                           return Text(formatter.format(date),
//                               style: const TextStyle(fontSize: 10));
//                         },
//                       ),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 28,
//                         getTitlesWidget: (value, meta) =>
//                             Text('${value.toInt()}h',
//                                 style: const TextStyle(fontSize: 10)),
//                       ),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: true),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: List.generate(
//                         weeklyProgress.length,
//                             (index) => FlSpot(
//                           index.toDouble(),
//                           weeklyProgress[index].hours.toDouble(),
//                         ),
//                       ),
//                       isCurved: true,
//                       color: AppColors.darkBlue,
//                       dotData: FlDotData(show: true),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: AppColors.darkBlue.withOpacity(0.3),
//                       ),
//                     ),
//                   ],
//                   minY: 0,
//                   maxY: (maxHours + 1).toDouble(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
