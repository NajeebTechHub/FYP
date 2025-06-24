import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/widgets/main_widgets/appbar_widget.dart';
import '../widgets/home_widgets/benifitsection.dart';
import '../models/course.dart';
import '../widgets/explore_widgets/category_filter.dart';
import '../widgets/home_widgets/coursecard.dart';
import '../widgets/home_widgets/feature.dart';
import '../widgets/home_widgets/footerwidget.dart';
import '../widgets/home_widgets/form.dart';
import '../widgets/home_widgets/herosection.dart';
import '../widgets/home_widgets/testemonialcarosal.dart';


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
                      // const ownface(),
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
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Wrapping ListView in a constrained box
        Container(
          height: 270, // Ensure ListView has a fixed height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 300, // Fixed width for each course card
                margin: const EdgeInsets.only(right: 12), // Space between cards
                child: CourseCard(
                  course: Course(
                    id: 'course$index',
                    name: 'Complete Web Development Bootcamp',
                    description: 'Learn web development from scratch',
                    price: 99.99,
                    duration: '12 weeks',
                    level: 'Beginner',
                    rating: 4.5,
                    studentsCount: 1234,
                    instructor: 'John Doe',
                    tags: ['Web Development', 'JavaScript', 'HTML', 'CSS'], imageUrl: '',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}