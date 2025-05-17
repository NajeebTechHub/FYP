import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/course_progress.dart';
import '../theme/color.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({Key? key}) : super(key: key);

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<CourseProgress> _courseProgress;
  late ProgressSummary _progressSummary;
  String _selectedTimeFrame = 'All Time';
  final List<String> _timeFrames = ['This Week', 'This Month', 'All Time'];
  int _currentQuoteIndex = 0;

  final List<String> _motivationalQuotes = [
    "The expert in anything was once a beginner.",
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    "Believe you can and you're halfway there.",
    "The beautiful thing about learning is nobody can take it away from you.",
    "Education is the most powerful weapon which you can use to change the world.",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize with sample data
    _courseProgress = CourseProgress.getSampleProgressData();
    _progressSummary = ProgressSummary.generateFromCourseProgress(_courseProgress);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export feature coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
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
          // Overview Tab
          _buildOverviewTab(context, isTablet),

          // Analytics Tab
          _buildAnalyticsTab(context, isTablet),

          // Certificates Tab
          _buildCertificatesTab(context, isTablet),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, bool isTablet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeFrameSelector(),
          _buildSummaryCards(isTablet),
          _buildMotivationalQuote(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'COURSE PROGRESS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ..._courseProgress.map((course) => _buildCourseProgressItem(course)).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: DropdownButton<String>(
          value: _selectedTimeFrame,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.darkBlue),
          elevation: 1,
          underline: const SizedBox(),
          style: const TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTimeFrame = newValue;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          items: _timeFrames.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isTablet) {
    Widget buildSummaryCard(String title, String value, IconData icon, Color color) {
      return Expanded(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Responsive layout for summary cards
    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            buildSummaryCard('Total Courses', _progressSummary.totalCoursesEnrolled.toString(), Icons.collections_bookmark, AppColors.primary),
            const SizedBox(width: 12),
            buildSummaryCard('Completed', _progressSummary.coursesCompleted.toString(), Icons.check_circle, Colors.green),
            const SizedBox(width: 12),
            buildSummaryCard('Certificates', _progressSummary.certificatesEarned.toString(), Icons.workspace_premium, Colors.amber),
            const SizedBox(width: 12),
            buildSummaryCard('Learning Hours', _progressSummary.totalLearningHours.toString(), Icons.timer, AppColors.accent),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                buildSummaryCard('Total Courses', _progressSummary.totalCoursesEnrolled.toString(), Icons.collections_bookmark, AppColors.primary),
                const SizedBox(width: 12),
                buildSummaryCard('Completed', _progressSummary.coursesCompleted.toString(), Icons.check_circle, Colors.green),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                buildSummaryCard('Certificates', _progressSummary.certificatesEarned.toString(), Icons.workspace_premium, Colors.amber),
                const SizedBox(width: 12),
                buildSummaryCard('Learning Hours', _progressSummary.totalLearningHours.toString(), Icons.timer, AppColors.accent),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMotivationalQuote() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _motivationalQuotes.length;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.7),
              AppColors.darkBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.format_quote,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _motivationalQuotes[_currentQuoteIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to see another quote',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgressItem(CourseProgress course) {
    // Format estimated time left
    String timeLeft;
    final minutesLeft = course.estimatedMinutesLeft;
    if (minutesLeft >= 60) {
      final hours = minutesLeft ~/ 60;
      final minutes = minutesLeft % 60;
      timeLeft = '$hours hr ${minutes > 0 ? '$minutes min' : ''} left';
    } else {
      timeLeft = '$minutesLeft min left';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.courseName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.category,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeLeft,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: course.percentComplete >= 0.95
                        ? Colors.green.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${(course.percentComplete * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: course.percentComplete >= 0.95
                            ? Colors.green
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: LinearPercentIndicator(
              animation: true,
              animationDuration: 1000,
              lineHeight: 10.0,
              percent: course.percentComplete,
              barRadius: const Radius.circular(8),
              progressColor: course.percentComplete >= 0.95 ? Colors.green : AppColors.primary,
              backgroundColor: Colors.grey.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, bool isTablet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryPieChart(),
          const SizedBox(height: 24),
          _buildLearningLineChart(),
          const SizedBox(height: 24),
          _buildEngagementHeatmap(),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Courses by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _getCategorySections(),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildPieChartLegend(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getCategorySections() {
    // Define colors for different categories
    final categoryColors = {
      'Mobile Development': Colors.blue,
      'Data Science': Colors.red,
      'Design': Colors.purple,
      'Web Development': Colors.orange,
      'Business': Colors.teal,
    };

    // Count courses by category
    final categoryCount = <String, int>{};
    for (final course in _courseProgress) {
      categoryCount[course.category] = (categoryCount[course.category] ?? 0) + 1;
    }

    // Create pie chart sections
    final sections = <PieChartSectionData>[];
    var i = 0;

    for (final entry in categoryCount.entries) {
      final color = categoryColors[entry.key] ?? Colors.grey;
      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '', // No title inside pie chart
          radius: 50,
        ),
      );
      i++;
    }

    return sections;
  }

  Widget _buildPieChartLegend() {
    // Define colors for different categories
    final categoryColors = {
      'Mobile Development': Colors.blue,
      'Data Science': Colors.red,
      'Design': Colors.purple,
      'Web Development': Colors.orange,
      'Business': Colors.teal,
    };

    // Count courses by category
    final categoryCount = <String, int>{};
    for (final course in _courseProgress) {
      categoryCount[course.category] = (categoryCount[course.category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: categoryCount.entries.map((entry) {
        final color = categoryColors[entry.key] ?? Colors.grey;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLearningLineChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Activity (Hours)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Mon';
                              break;
                            case 2:
                              text = 'Wed';
                              break;
                            case 4:
                              text = 'Fri';
                              break;
                            case 6:
                              text = 'Sun';
                              break;
                            default:
                              return Container();
                          }
                          return Text(text, style: style);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return Container();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 4,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1.5),
                        FlSpot(1, 2.5),
                        FlSpot(2, 2),
                        FlSpot(3, 3),
                        FlSpot(4, 2.5),
                        FlSpot(5, 1.8),
                        FlSpot(6, 3.2),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementHeatmap() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Generate sample data for heatmap
    final heatmapDatasets = <DateTime, int>{};
    for (var i = 0; i < daysInMonth; i++) {
      final date = startDate.add(Duration(days: i));
      if (date.isAfter(now)) continue;

      // Random value between 0-4 (intensity levels)
      final value = (date.day * 7) % 5;
      if (value > 0) {
        heatmapDatasets[date] = value;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Engagement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Daily learning activity for this month',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: HeatMapCalendar(
                size: 35,
                datasets: heatmapDatasets,
                colorsets: const {
                  1: Color(0xFFCCE5FF),
                  2: Color(0xFF99CCFF),
                  3: Color(0xFF66B2FF),
                  4: Color(0xFF3399FF),
                },
                defaultColor: Colors.white,
                textColor: AppColors.textPrimary,
                showColorTip: false,
                monthFontSize: 14,
                weekFontSize: 12,
                borderRadius: 8,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeatmapColorKey('Less', const Color(0xFFCCE5FF)),
                const SizedBox(width: 6),
                _buildHeatmapColorKey('', const Color(0xFF99CCFF)),
                const SizedBox(width: 6),
                _buildHeatmapColorKey('', const Color(0xFF66B2FF)),
                const SizedBox(width: 6),
                _buildHeatmapColorKey('', const Color(0xFF3399FF)),
                const SizedBox(width: 6),
                _buildHeatmapColorKey('More', AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapColorKey(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (label.isNotEmpty) const SizedBox(width: 4),
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildCertificatesTab(BuildContext context, bool isTablet) {
    final certificates = _progressSummary.certificates;

    if (certificates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Certificates Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete courses to earn certificates',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Certificates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final certificate = certificates[index];
                return _buildCertificateCard(certificate, isTablet);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(Certificate certificate, bool isTablet) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.amber,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      certificate.courseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Course Category',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            certificate.category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date Earned',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(certificate.dateEarned),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Certificate downloaded'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Certificate shared'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share, size: 20),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}