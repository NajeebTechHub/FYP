import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mentorcraft2/theme/color.dart';
import '../models/discussion_topic.dart';
import 'Add_new_post.dart';
import 'discussion_details_screen.dart';
import 'edit_post.dart';
import 'package:share_plus/share_plus.dart';

class ForumsScreen extends StatefulWidget {
  const ForumsScreen({Key? key}) : super(key: key);

  @override
  State<ForumsScreen> createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = [
    'All',
    'Programming',
    'UI/UX',
    'Career',
    'Mobile Dev',
    'Web Dev',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Discussion Forums'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: theme.textTheme.titleLarge!.color,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(theme),
          const SizedBox(height: 16),
          _buildCategoryTabs(theme),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('discussions')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No discussions yet.', style: theme.textTheme.bodyMedium);
              }

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final category = data['category'] ?? '';
                final title = (data['title'] ?? '').toString().toLowerCase();

                final matchesCategory = selectedCategory == 'All' || category == selectedCategory;
                final matchesSearch = searchQuery.isEmpty || title.contains(searchQuery.toLowerCase());

                return matchesCategory && matchesSearch;
              }).toList();

              if (docs.isEmpty) {
                return Text('No discussions found.', style: theme.textTheme.bodyMedium);
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ts = data['timestamp'] as Timestamp?;
                  final timeAgo = ts != null ? timeago.format(ts.toDate()) : 'some time ago';
                  final isCurrentUserPost = data['uid'] == currentUser?.uid;

                  final rawLikes = data['likes'];
                  final Map<String, dynamic> likesMap = rawLikes is Map<String, dynamic> ? rawLikes : {};
                  final hasLiked = currentUser != null && likesMap.containsKey(currentUser!.uid);
                  final totalLikes = likesMap.length;

                  return _buildDiscussionCard(
                    context: context,
                    title: data['title'] ?? '',
                    author: data['author'] ?? 'Unknown',
                    uid: data['uid'] ?? '',
                    timeAgo: timeAgo,
                    replies: data['replies'] ?? 0,
                    isHot: data['isHot'] ?? false,
                    docId: doc.id,
                    showActions: isCurrentUserPost,
                    category: data['category'] ?? '',
                    totalLikes: totalLikes,
                    hasLiked: hasLiked,
                    theme: theme,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkBlue,
        child: const Icon(Icons.add_comment, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDiscussionScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Search discussions...'
        ,
        hintStyle: theme.textTheme.bodySmall,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((label) {
          final isSelected = selectedCategory == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => selectedCategory = label),
              backgroundColor: theme.cardColor,
              selectedColor: AppColors.primary.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : theme.textTheme.bodySmall!.color,
                fontWeight: FontWeight.w500,
              ),
              checkmarkColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiscussionCard({
    required BuildContext context,
    required String title,
    required String author,
    required String uid,
    required String timeAgo,
    required int replies,
    required bool isHot,
    required String docId,
    required bool showActions,
    required String category,
    required int totalLikes,
    required bool hasLiked,
    required ThemeData theme,
  }) {
    final imageUrl =
        'https://tqzoozpckrmmprwnhweg.supabase.co/storage/v1/object/public/profile-images/public/$uid.jpg';

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[800],
                child: ClipOval(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        author.isNotEmpty ? author[0].toUpperCase() : '?',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    if (isHot)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.local_fire_department, color: AppColors.accent, size: 14),
                            SizedBox(width: 4),
                            Text('Hot', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    if (showActions)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditDiscussionScreen(docId: docId, currentTitle: title),
                              ),
                            );
                          } else if (value == 'delete') {
                            FirebaseFirestore.instance.collection('discussions').doc(docId).delete();
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      )
                  ]),
                  const SizedBox(height: 4),
                  Text('Category: $category', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  Text('Posted by $author • $timeAgo', style: theme.textTheme.bodySmall),
                ]),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(docId, hasLiked),
                child: Row(
                  children: [
                    Icon(
                      hasLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: hasLiked ? Colors.red : theme.iconTheme.color,
                    ),
                    const SizedBox(width: 4),
                    Text('$totalLikes likes', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiscussionDetailScreen(docId: docId, title: title),
                    ),
                  );
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.comment_outlined, size: 16, color: Theme.of(context).iconTheme.color),
                      const SizedBox(width: 4),
                      Text(
                        '$replies replies',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.share_outlined, color: theme.iconTheme.color),
                onPressed: () => Share.share('Check out this discussion: "$title" on MentorCraft.'),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  void _toggleLike(String docId, bool hasLiked) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final postRef = FirebaseFirestore.instance.collection('discussions').doc(docId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      final data = snapshot.data() as Map<String, dynamic>;
      final rawLikes = data['likes'];
      final Map<String, dynamic> likesMap =
      rawLikes is Map<String, dynamic> ? Map<String, dynamic>.from(rawLikes) : {};

      if (hasLiked) {
        likesMap.remove(uid);
      } else {
        likesMap[uid] = true;
      }

      transaction.update(postRef, {'likes': likesMap});
    });
  }
}
