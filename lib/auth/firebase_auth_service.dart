import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUser(result.user);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _clearUser();
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String nim,
    required String programStudi,
  }) async {
    try {
      DocumentSnapshot existingUser =
          await _firestore.collection('users').doc(nim).get();
      if (existingUser.exists) {
        throw FirebaseAuthException(
          message: "NIM already exists",
          code: "NIM_EXISTS",
        );
      }

      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      await _firestore.collection('users').doc(user?.uid).set({
        'uid': user?.uid,
        'nama': nama,
        'nim': nim,
        'programStudi': programStudi,
        'email': email,
      });

      await _saveUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<void> _saveUser(User? user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', user?.uid ?? '');
  }

  Future<void> _clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('user');
    if (uid != null && uid.isNotEmpty) {
      return _firebaseAuth.currentUser;
    }
    return null;
  }
}
