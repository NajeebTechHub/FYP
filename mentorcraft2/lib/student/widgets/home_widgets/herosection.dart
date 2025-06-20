import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        image: DecorationImage(
          // image: const NetworkImage('https://via.placeholder.com/800x400'),
          image: AssetImage('assets/images/center_bg/pic.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.main.withOpacity(0.5),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '"Learning never exhausts the mind."',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width > 600 ? 32 : 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Discover top courses from industry experts and enhance your skills',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Start Learning Now'),
          ),
        ],
      ),
    );
  }
}