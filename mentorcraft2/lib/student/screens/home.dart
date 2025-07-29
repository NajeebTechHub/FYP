import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../student_main_app.dart';
import '../widgets/home_widgets/benifitsection.dart';
import '../models/course.dart';
import '../widgets/home_widgets/coursecard.dart';
import '../widgets/home_widgets/feature.dart';
import '../widgets/home_widgets/footerwidget.dart';
import '../widgets/home_widgets/form.dart';
import '../widgets/home_widgets/herosection.dart';
import '../widgets/home_widgets/testemonialcarosal.dart';
import 'course_details_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const HeroSection(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildFeatureSection(context),
                      const SizedBox(height: 32),
                      _buildPopularCourses(context),
                      const SizedBox(height: 32),
                      const BenefitsSection(),
                      const SizedBox(height: 32),
                      const TestimonialCarousel(),
                      const SizedBox(height: 32),
                      const NewsletterForm(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                const FooterWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            'Why Choose Us',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            FeatureCard(
              icon: Icons.school,
              title: 'Expert Instructors',
              description: 'Learn from industry professionals',
            ),
            const SizedBox(height: 10),
            FeatureCard(
              icon: Icons.schedule,
              title: 'Flexible Learning',
              description: 'Study at your own pace',
            ),
            const SizedBox(height: 10),
            FeatureCard(
              icon: Icons.book,
              title: 'Quality Content',
              description: 'Curated learning materials',
            ),
          ].map((card) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // Consistent padding
              child: SizedBox(
                width: double.infinity, // Full width
                child: card,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPopularCourses(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('courses')
          .orderBy('rating', descending: true)
          .limit(3)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Failed to load popular courses"));
        }

        final docs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Courses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return StudentMainScreen(initialIndex: 1);
                    }));
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;

                  final course = Course(
                    id: docs[index].id,
                    title: data['title'] ?? '',
                    description: data['description'] ?? '',
                    price: (data['price'] as num?)?.toDouble() ?? 0.0,
                    duration: data['duration'] ?? '',
                    level: data['level'] ?? '',
                    rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
                    imageUrl: data['imageUrl'] ?? '',
                    teacherId: data['teacherId'] ?? '',
                    teacherName: data['teacherName'] ?? '',
                    totalRating: (data['totalRating'] as num?)?.toDouble() ?? 0.0,
                    createdAt: parseDate(data['createdAt']),
                    updatedAt: parseDate(data['updatedAt']),
                    enrolledStudents: data['enrolledStudents'] ?? 0,
                    modules: [],
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailsScreen(course: course),
                        ),
                      );
                    },
                    child: Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 12),
                      child: CourseCard(course: course),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }




  DateTime parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else {
      return DateTime.now();
    }
  }


}