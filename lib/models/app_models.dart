class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'sos', 'crime', 'journey', 'guardian'
  final String time;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'info',
      isRead: map['isRead'] ?? false,
      time: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']).toLocal().toString().substring(11, 16) 
          : 'Just now',
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      time: time,
      isRead: isRead ?? this.isRead,
    );
  }
}

class RoadReport {
  final String id;
  final String roadName;
  final String reporter;
  final double rating;
  final List<String> tags;
  final String comment;
  final String time;

  RoadReport({
    required this.id,
    required this.roadName,
    required this.reporter,
    required this.rating,
    required this.tags,
    required this.comment,
    required this.time,
  });

  factory RoadReport.fromMap(Map<String, dynamic> map) {
    return RoadReport(
      id: map['id'] ?? '',
      roadName: map['roadName'] ?? '',
      reporter: map['reporterName'] ?? 'Anonymous',
      rating: (map['rating'] as num).toDouble(),
      tags: List<String>.from(map['tags'] ?? []),
      comment: map['comment'] ?? '',
      time: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']).toLocal().toString().substring(0, 16) 
          : 'Just now',
    );
  }
}

class Helpline {
  final String title;
  final String number;
  final String description;

  Helpline({
    required this.title,
    required this.number,
    required this.description,
  });
}
