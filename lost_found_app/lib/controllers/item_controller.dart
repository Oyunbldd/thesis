import '../models/item_report_model.dart';

class ItemController {
  final List<ItemReportModel> _reports = [];

  void createReport(ItemReportModel report) {
    _reports.add(report);
  }

  List<ItemReportModel> getAllReports() {
    return List.unmodifiable(_reports);
  }

  List<ItemReportModel> getLostReports() {
    return _reports.where((report) => report.type == 'lost').toList();
  }

  List<ItemReportModel> getFoundReports() {
    return _reports.where((report) => report.type == 'found').toList();
  }

  void markResolved(String reportId) {
    for (int i = 0; i < _reports.length; i++) {
      if (_reports[i].id == reportId) {
        final report = _reports[i];

        _reports[i] = ItemReportModel(
          id: report.id,
          title: report.title,
          description: report.description,
          category: report.category,
          type: report.type,
          status: 'resolved',
          imageUrl: report.imageUrl,
          location: report.location,
          date: report.date,
          userId: report.userId,
        );
        break;
      }
    }
  }
}
