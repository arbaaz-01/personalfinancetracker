import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get profileCollection =>
      _firestore.collection('user_profiles');

  // Get current user profile
  Stream<UserProfileModel?> getUserProfile() {
    return profileCollection
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      DocumentSnapshot doc = snapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return UserProfileModel(
        id: doc.id,
        userId: data['userId'],
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        photoUrl: data['photoUrl'],
        phoneNumber: data['phoneNumber'],
        currency: data['currency'] ?? '₹',
      );
    });
  }

  // Create or update user profile
  Future<void> updateUserProfile(UserProfileModel profile) async {
    // Check if profile exists
    QuerySnapshot existingProfiles = await profileCollection
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();

    if (existingProfiles.docs.isNotEmpty) {
      // Update existing profile
      String docId = existingProfiles.docs.first.id;
      await profileCollection.doc(docId).update({
        'name': profile.name,
        'email': profile.email,
        'photoUrl': profile.photoUrl,
        'phoneNumber': profile.phoneNumber,
        'currency': profile.currency,
      });
    } else {
      // Create new profile
      await profileCollection.add({
        'userId': _auth.currentUser!.uid,
        'name': profile.name,
        'email': profile.email,
        'photoUrl': profile.photoUrl,
        'phoneNumber': profile.phoneNumber,
        'currency': profile.currency,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Initialize user profile after registration
  Future<void> initializeUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Check if profile already exists
      QuerySnapshot existingProfiles =
          await profileCollection.where('userId', isEqualTo: user.uid).get();

      if (existingProfiles.docs.isEmpty) {
        // Create new profile with default values
        await profileCollection.add({
          'userId': user.uid,
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'photoUrl': null, // Set to null since we're not using remote storage
          'phoneNumber': user.phoneNumber,
          'currency': '₹',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
