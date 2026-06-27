class Guardian {
  final String id;
  final String name;
  final String relation;
  final String phone;

  Guardian({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'phone': phone,
    };
  }

  factory Guardian.fromMap(Map<String, dynamic> map) {
    return Guardian(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
