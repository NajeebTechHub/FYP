import 'package:flutter/cupertino.dart';
import 'package:flutter/src/painting/image_resolution.dart';

class Testimonial {
  final String id;
  final String name;
  final String content;
  // final String avatarUrl;
  final String role;
  final ImageProvider avatarImage;
  final uid;

  Testimonial({
    required this.id,
    required this.name,
    required this.content,
    // required this.avatarUrl,
    required this.role,
    required this.avatarImage,
    required this.uid,
  });
}
