import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
       if (user != null) {
          await _loadUserFromFirestore(user.uid);
       } else {
          _currentUser = null;
          notifyListeners();
       }
    });
  }

  Future<void> _loadUserFromFirestore(String uid) async {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
            _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
        } else {
            _currentUser = null;
        }
      } catch (e) {
        _currentUser = null;
        debugPrint("Error loading user: $e");
      }
      notifyListeners();
  }

  Future<void> login(String phone, String password) async {
      String email = "$phone@mandi.com";
      await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signupAsFarmer({
    required String name,
    required String phone,
    required String password,
    required String village,
    required String preferredCrop,
  }) async {
    String email = "$phone@mandi.com";
    UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    final newUser = UserModel(
      uid: cred.user!.uid,
      name: name,
      phone: phone,
      role: UserRole.farmer,
      village: village,
      preferredCrop: preferredCrop,
    );
    
    await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
    _currentUser = newUser;
    notifyListeners();
  }

  Future<void> signupAsOperator({
    required String name,
    required String phone,
    required String password,
    required String mandiId,
  }) async {
    String email = "$phone@mandi.com";
    UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    final newUser = UserModel(
      uid: cred.user!.uid,
      name: name,
      phone: phone,
      role: UserRole.operator,
      mandiId: mandiId,
    );
    
    await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
    _currentUser = newUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? village,
    String? preferredCrop,
  }) async {
    if (_currentUser == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (village != null) updates['village'] = village;
    if (preferredCrop != null) updates['preferredCrop'] = preferredCrop;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(_currentUser!.uid).update(updates);
      
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        role: _currentUser!.role,
        village: village ?? _currentUser!.village,
        preferredCrop: preferredCrop ?? _currentUser!.preferredCrop,
        mandiId: _currentUser!.mandiId,
        notificationToken: _currentUser!.notificationToken,
      );
      notifyListeners();
    }
  }
}
