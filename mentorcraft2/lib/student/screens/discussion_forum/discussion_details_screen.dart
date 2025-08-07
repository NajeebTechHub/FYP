import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../theme/color.dart';

class DiscussionDetailScreen extends StatefulWidget {
  final String docId;
  final String title;

  const DiscussionDetailScreen({
    Key? key,
    required this.docId,
    required this.title,
  }) : super(key: key);

  @override
  State<DiscussionDetailScreen> createState() =>
      _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  void _postReply() async {
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty || currentUser == null) return;

    final reply = {
      'author': currentUser?.displayName ?? 'User',
      'uid': currentUser?.uid,
      'reply': replyText,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'likedBy': <String>[],
    };

    final discussionRef =
    FirebaseFirestore.instance.collection('discussions').doc(widget.docId);

    await discussionRef.collection('replies').add(reply);
    await discussionRef.update({
      'replies': FieldValue.increment(1),
    });

    _replyController.clear();
  }

  void _toggleLike(String replyId, List likedBy) async {
    final replyRef = FirebaseFirestore.instance
        .collection('discussions')
        .doc(widget.docId)
        .collection('replies')
        .doc(replyId);

    final userId = currentUser?.uid;
    if (userId == null) return;

    final alreadyLiked = likedBy.contains(userId);

    await replyRef.update({
      'likes': FieldValue.increment(alreadyLiked ? -1 : 1),
      'likedBy': alreadyLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
    });
  }

  void _editReply(String replyId, String currentText) async {
    final controller = TextEditingController(text: currentText);
    final updatedReply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reply'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Update your reply'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (updatedReply != null && updatedReply.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('discussions')
          .doc(widget.docId)
          .collection('replies')
          .doc(replyId)
          .update({'reply': updatedReply});
    }
  }

  void _deleteReply(String replyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final discussionRef =
      FirebaseFirestore.instance.collection('discussions').doc(widget.docId);

      await discussionRef.collection('replies').doc(replyId).delete();
      await discussionRef.update({
        'replies': FieldValue.increment(-1),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('discussions')
                  .doc(widget.docId)
                  .collection('replies')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No replies yet.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final Timestamp? ts = data['timestamp'];
                    final String timeAgo = ts != null
                        ? timeago.format(ts.toDate())
                        : 'some time ago';

                    final likedBy = List<String>.from(data['likedBy'] ?? []);
                    final isLiked = likedBy.contains(currentUser?.uid);
                    final replyId = doc.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(data['reply'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('by ${data['author']} • $timeAgo'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () =>
                                      _toggleLike(replyId, likedBy),
                                ),
                                Text('${data['likes'] ?? 0} likes'),
                              ],
                            )
                          ],
                        ),
                        trailing: data['uid'] == currentUser?.uid
                            ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editReply(replyId, data['reply']);
                            } else if (value == 'delete') {
                              _deleteReply(replyId);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        )
                            : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: 'Write a reply...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _postReply,
                  child: const Text('Reply'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
