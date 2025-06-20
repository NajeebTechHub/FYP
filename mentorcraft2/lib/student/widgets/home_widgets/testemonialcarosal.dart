import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/testmonial.dart';
import 'package:mentorcraft2/theme/color.dart';

class TestimonialCarousel extends StatelessWidget {
  const TestimonialCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final testimonials = [
      // Testimonial(
      //   id: '1',
      //   name: 'John Doe',
      //   content: 'Great learning experience!',
      //   avatarUrl: 'assets/images/11.png',
      //   role: 'Student',
      // ),
      Testimonial(
        id: '1',
        name: 'John Doe',
        content: 'Great learning experience!',
        avatarImage: AssetImage('assets/images/pic.jpg'),
        role: 'Student',
      ),
      Testimonial(
        id: '2',
        name: 'Jane Smith',
        content: 'Excellent course material!',
        role: 'Professional',
        avatarImage: AssetImage('assets/images/pic.jpg'),
      ),
    ];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Testimonials',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.8,
            enableInfiniteScroll: true,
            autoPlay: true,
          ),
          items: testimonials.map((testimonial) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: testimonial.avatarImage,
                          radius: 30,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          testimonial.content,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          testimonial.name,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          testimonial.role,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
