import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  /// Creates a user document if it does not exist, 
  /// and updates the lastLogin field on every sign-in.
  Future<void> createUserOrUpdateLogin(String uid, String phone) async {
    final userRef = _firestore.collection(_usersCollection).doc(uid);
    final docSnapshot = await userRef.get();

    final now = DateTime.now();

    if (!docSnapshot.exists) {
      // Create new user document
      final newUser = UserModel(
        uid: uid,
        phone: phone,
        createdAt: now,
        lastLogin: now,
      );
      await userRef.set(newUser.toMap());
    } else {
      // User exists, update lastLogin
      await userRef.update({
        'lastLogin': now.toIso8601String(),
      });
    }
  }
}
