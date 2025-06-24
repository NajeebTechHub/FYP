import 'package:cloud_firestore/cloud_firestore.dart';

import '../teacher/models/teacher_announcement.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'announcements';

  // Add new announcement
  Future<void> addAnnouncement(TeacherAnnouncement announcement) async {
    await _firestore.collection(collectionName).doc(announcement.id).set(announcement.toJson());
  }

  // Update existing announcement
  Future<void> updateAnnouncement(TeacherAnnouncement announcement) async {
    await _firestore.collection(collectionName).doc(announcement.id).update(announcement.toJson());
  }

  // Delete an announcement
  Future<void> deleteAnnouncement(String announcementId) async {
    await _firestore.collection(collectionName).doc(announcementId).delete();
  }

  // Get announcements by teacherId
  Future<List<TeacherAnnouncement>> getAnnouncementsByTeacher(String teacherId) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TeacherAnnouncement.fromJson(doc.data()))
        .toList();
  }

  // Get announcements by courseId
  Future<List<TeacherAnnouncement>> getAnnouncementsByCourse(String courseId) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .where('courseId', isEqualTo: courseId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TeacherAnnouncement.fromJson(doc.data()))
        .toList();
  }
}
