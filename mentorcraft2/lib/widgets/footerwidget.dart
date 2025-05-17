import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/color.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.zero,
      color: AppColors.primary,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo/Vector.png',height: 30,),
              const SizedBox(width: 8),
              Image.asset('assets/images/logo/MENTOR CRAFT.png'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(FontAwesomeIcons.facebook),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.twitter),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.instagram),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.whatsapp),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            child: Text(
              textAlign: TextAlign.center,
              '© ${DateTime.now().year} Mentor Craft. All rights reserved.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return IconButton(
      icon: FaIcon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      onPressed: () {},
    );
  }
}
