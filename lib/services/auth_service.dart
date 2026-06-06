import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required String role, // 'student' or 'staff'
  }) async {
    try {
      final normalizedRole = role.toLowerCase().trim();
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: normalizedRole,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
            
        // Save FCM Token
        await NotificationService().updateToken(user.uid);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Save FCM Token
        await NotificationService().updateToken(userCredential.user!.uid);
      }
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Backward-compatible wrappers.
  Future<User?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return signUp(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }

  Future<User?> login({
    required String email,
    required String password,
  }) {
    return signIn(
      email: email,
      password: password,
    );
  }

  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching user details: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}