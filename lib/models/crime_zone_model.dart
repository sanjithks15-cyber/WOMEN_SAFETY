class CrimeZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String riskLevel; // 'high', 'medium', 'low'
  final String description;
  final int reportsCount;
  final String lastIncident;

  CrimeZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.description,
    required this.reportsCount,
    required this.lastIncident,
  });

  factory CrimeZone.fromMap(Map<String, dynamic> map) {
    return CrimeZone(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      riskLevel: map['riskLevel'] ?? 'low',
      description: map['description'] ?? '',
      reportsCount: map['reportsCount'] ?? 0,
      lastIncident: map['lastIncident'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'riskLevel': riskLevel,
      'description': description,
      'reportsCount': reportsCount,
      'lastIncident': lastIncident,
    };
  }
}
