import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/testmonial.dart';
import 'package:mentorcraft2/theme/color.dart';

class TestimonialCarousel extends StatefulWidget {
  const TestimonialCarousel({Key? key}) : super(key: key);

  @override
  State<TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<TestimonialCarousel> {
  List<Testimonial> testimonials = [];
  String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? '';
  Map<String, bool> expandedStates = {};

  @override
  void initState() {
    super.initState();
    fetchTestimonials();
  }

  Future<void> fetchTestimonials() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('testimonials').get();

    final data = snapshot.docs.map((doc) {
      final map = doc.data();
      final id = doc.id;
      expandedStates[id] = false;

      return Testimonial(
        id: id,
        name: map['name'] ?? '',
        content: map['content'] ?? '',
        role: map['role'] ?? 'Student',
        avatarImage: (map['avatarUrl'] != null &&
            map['avatarUrl'].toString().isNotEmpty)
            ? NetworkImage(map['avatarUrl'])
            : const AssetImage('assets/images/default_avatar.png'),
        uid: map['uid'],
      );
    }).toList();

    setState(() {
      testimonials = data;
    });
  }

  void _showFeedbackDialog({Testimonial? existing}) {
    final nameController =
    TextEditingController(text: existing?.name ?? currentUserName);
    final contentController =
    TextEditingController(text: existing?.content ?? '');

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String defaultAvatarUrl =
        'https://tqzoozpckrmmprwnhweg.supabase.co/storage/v1/object/public/profile-images/public/$uid.jpg';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing != null ? "Edit Feedback" : "Submit Feedback"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Feedback'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Name and Feedback cannot be empty')),
                );
                return;
              }

              final feedbackData = {
                'name': nameController.text.trim(),
                'role': 'Student',
                'content': contentController.text.trim(),
                'avatarUrl': defaultAvatarUrl,
                'uid': uid,
              };

              if (existing != null) {
                await FirebaseFirestore.instance
                    .collection('testimonials')
                    .doc(existing.id)
                    .update(feedbackData);
              } else {
                await FirebaseFirestore.instance
                    .collection('testimonials')
                    .add(feedbackData);
              }

              Navigator.pop(context);
              fetchTestimonials();
            },
            child: Text(existing != null ? "Update" : "Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTestimonial(String id) async {
    await FirebaseFirestore.instance.collection('testimonials').doc(id).delete();
    fetchTestimonials();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Student Testimonials',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.feedback, color: theme.colorScheme.primary),
              onPressed: () => _showFeedbackDialog(),
              tooltip: 'Give Feedback',
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (testimonials.isEmpty)
          Text(
            "No feedback yet. Be the first to share!",
            style: theme.textTheme.bodyLarge,
          )
        else
          CarouselSlider(
            options: CarouselOptions(
              height: 260,
              viewportFraction: 0.85,
              enableInfiniteScroll: true,
              autoPlay: true,
            ),
            items: testimonials.map((testimonial) {
              final isOwner = testimonial.uid == currentUid;
              final isExpanded = expandedStates[testimonial.id] ?? false;
              final content = testimonial.content;

              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: testimonial.avatarImage,
                                  radius: 30,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      testimonial.name,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      testimonial.role,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: isExpanded
                                    ? const BouncingScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    Text(
                                      isExpanded || content.length <= 120
                                          ? content
                                          : '${content.substring(0, 120)}...',
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    if (content.length > 120)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            expandedStates[testimonial.id] =
                                            !isExpanded;
                                          });
                                        },
                                        child: Text(isExpanded ? 'See Less' : 'See More'),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isOwner)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert,
                                  color: theme.iconTheme.color),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showFeedbackDialog(existing: testimonial);
                                } else if (value == 'delete') {
                                  _deleteTestimonial(testimonial.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                      ],
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
