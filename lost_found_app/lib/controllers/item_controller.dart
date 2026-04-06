import '../models/item_report_model.dart';
import '../services/database_service.dart';

class ItemController {
  final DatabaseService _db = DatabaseService();

  Stream<List<ItemReportModel>> getLostItems() => _db.getLostItems();

  Stream<List<ItemReportModel>> getFoundItems() => _db.getFoundItems();

  Future<void> createReport(ItemReportModel report) => _db.createReport(report);
}
