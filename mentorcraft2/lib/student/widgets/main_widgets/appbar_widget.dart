import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final Color? titleColor;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.elevation = 2,
    this.backgroundColor,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor ?? AppColors.darkBlue,
      elevation: elevation,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}