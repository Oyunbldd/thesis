import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/item_report_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<ItemReportModel>> getLostItems() {
    return _db
        .collection('lost_items')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ItemReportModel.fromFirestore).toList());
  }

  Stream<List<ItemReportModel>> getFoundItems() {
    return _db
        .collection('found_items')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ItemReportModel.fromFirestore).toList());
  }

  Stream<List<ItemReportModel>> getUserItems(String userId) {
    final lost = _db
        .collection('lost_items')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(ItemReportModel.fromFirestore).toList());

    final found = _db
        .collection('found_items')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(ItemReportModel.fromFirestore).toList());

    return lost.asyncMap((lostItems) async {
      final foundItems = await found.first;
      return [...lostItems, ...foundItems]
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> updateItemStatus(String itemId, String type, String status) async {
    final collection = type == 'lost' ? 'lost_items' : 'found_items';
    await _db.collection(collection).doc(itemId).update({'status': status});
  }

  Future<void> createReport(ItemReportModel report) async {
    final collection = report.type == 'lost' ? 'lost_items' : 'found_items';

    String imageUrl = report.imageUrl;
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = await _uploadImage(imageUrl, report.id);
    }

    final data = report.toFirestore();
    data['imageUrl'] = imageUrl;

    await _db.collection(collection).doc(report.id).set(data);
  }

  Future<String> _uploadImage(String localPath, String reportId) async {
    final file = File(localPath);
    final dotIndex = localPath.lastIndexOf('.');
    final rawExt = dotIndex != -1
        ? localPath.substring(dotIndex + 1).toLowerCase()
        : 'jpg';
    final ext = rawExt.isEmpty ? 'jpg' : rawExt;
    final contentType = ext == 'jpg' || ext == 'jpeg'
        ? 'image/jpeg'
        : 'image/$ext';
    final ref = _storage.ref('item_images/$reportId.$ext');
    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );
    return await uploadTask.ref.getDownloadURL();
  }
}
