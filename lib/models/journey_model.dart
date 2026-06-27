class Journey {
  final String id;
  final String from;
  final String to;
  final String date;
  final String time;
  final String status; // 'completed', 'active', 'cancelled', 'sos'
  final String duration;
  final String routeType; // 'safest', 'fastest'
  final double progress; // 0.0 to 1.0

  Journey({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.status,
    required this.duration,
    required this.routeType,
    required this.progress,
  });

  factory Journey.fromMap(Map<String, dynamic> map) {
    String dateStr = map['date'] ?? '';
    String timeStr = map['time'] ?? '';
    if (map['createdAt'] != null) {
      try {
        final parsed = DateTime.parse(map['createdAt']).toLocal();
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        dateStr = "${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}";
        timeStr = "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      } catch (_) {}
    }
    return Journey(
      id: map['id'] ?? '',
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      date: dateStr,
      time: timeStr,
      status: map['status'] ?? 'completed',
      duration: map['duration'] ?? '',
      routeType: map['routeType'] ?? 'safest',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'date': date,
      'time': time,
      'status': status,
      'duration': duration,
      'routeType': routeType,
      'progress': progress,
    };
  }
}
