class ItemReportModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type;
  final String status;
  final String imageUrl;
  final String location;
  final DateTime date;
  final String userId;

  const ItemReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.status,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.userId,
  });

  factory ItemReportModel.fromMap(Map<String, dynamic> map) {
    return ItemReportModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      type: map['type'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      imageUrl: map['imageUrl'] as String? ?? '',
      location: map['location'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      userId: map['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'status': status,
      'imageUrl': imageUrl,
      'location': location,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }
}
