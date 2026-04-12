import '../models/item_report_model.dart';
import '../services/database_service.dart';

class ItemController {
  final DatabaseService _db = DatabaseService();

  Stream<List<ItemReportModel>> getLostItems() => _db.getLostItems();

  Stream<List<ItemReportModel>> getFoundItems() => _db.getFoundItems();

  Stream<List<ItemReportModel>> getUserItems(String userId) =>
      _db.getUserItems(userId);

  Future<void> updateItemStatus(String itemId, String type, String status) =>
      _db.updateItemStatus(itemId, type, status);

  Future<void> createReport(ItemReportModel report) => _db.createReport(report);
}
