import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/student_main_app.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/11.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF0A1F44).withOpacity(0.85),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: isTablet ? 48 : 32,
        ),
        child: isTablet
            ? _buildTabletLayout(context)
            : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildFeatureCards(),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 2,
          child: _buildCallToAction(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCards(),
        const SizedBox(height: 32),
        _buildCallToAction(context),
      ],
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: const [
        ExpandableFeatureCard(
          title: 'Experience',
          description: 'Expert instructors with real-world experience guiding your learning journey.',
          expandedText:
          'Our instructors have spent years in the industry, solving real-world problems. '
              'They bring practical insights, mentorship, and case studies to help you succeed.',
          icon: Icons.emoji_events,
        ),
        SizedBox(height: 16),
        ExpandableFeatureCard(
          title: 'Education',
          description: 'High-quality curriculum designed for mastering in-demand skills.',
          expandedText:
          'The curriculum is crafted by domain experts and updated regularly to match industry trends. '
              'Each module includes hands-on projects, assessments, and learning paths.',
          icon: Icons.school,
        ),
        SizedBox(height: 16),
        ExpandableFeatureCard(
          title: 'Certificate',
          description: 'Earn industry-recognized certificates to showcase your expertise.',
          expandedText:
          'On course completion, you’ll receive a digital certificate that can be shared on LinkedIn, resumes, and job platforms. '
              'These certificates are backed by our partner institutions.',
          icon: Icons.workspace_premium,
        ),
      ],
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study at your own pace',
            style: TextStyle(
              color: Color(0xFF0A1F44),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Boost your career by learning skills in high demand',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentMainScreen(initialIndex: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1F44),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableFeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String expandedText;

  const ExpandableFeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.expandedText,
  }) : super(key: key);

  @override
  State<ExpandableFeatureCard> createState() => _ExpandableFeatureCardState();
}

class _ExpandableFeatureCardState extends State<ExpandableFeatureCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.icon, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            Text(
              widget.expandedText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4A90E2),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              _expanded ? 'See Less ...' : 'See More ...',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
