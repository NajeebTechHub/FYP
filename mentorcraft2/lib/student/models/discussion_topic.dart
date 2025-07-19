class DiscussionTopic {
  final String title;
  final String author;
  final String timeAgo;
  final int views;
  final int replies;
  final bool isHot;
  final String uid;
  final String docId;
  final String? category; // optional

  DiscussionTopic({
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.views,
    required this.replies,
    required this.isHot,
    required this.uid,
    required this.docId,
    this.category,
  });

  factory DiscussionTopic.fromMap(Map<String, dynamic> data, String docId) {
    return DiscussionTopic(
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      timeAgo: data['timeAgo'] ?? '',
      views: data['views'] ?? 0,
      replies: data['replies'] ?? 0,
      isHot: data['isHot'] ?? false,
      uid: data['uid'] ?? '',
      docId: docId,
      category: data['category'],
    );
  }
}
