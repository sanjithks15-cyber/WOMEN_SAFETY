class UserModel {
  final String uid;
  final String phone;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.phone,
    required this.createdAt,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : DateTime.now(),
    );
  }
}
