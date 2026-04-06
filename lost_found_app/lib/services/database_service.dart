import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item_report_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<void> createReport(ItemReportModel report) {
    final collection = report.type == 'lost' ? 'lost_items' : 'found_items';
    return _db.collection(collection).doc(report.id).set(report.toFirestore());
  }
}
