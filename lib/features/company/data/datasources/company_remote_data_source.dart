import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_profile_model.dart';

abstract class CompanyRemoteDataSource {
  Future<void> saveProfile(CompanyProfileModel profile);
  Future<CompanyProfileModel?> getProfile(String userId);
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final FirebaseFirestore _firestore;

  CompanyRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveProfile(CompanyProfileModel profile) async {
    await _firestore
        .collection('companies')
        .doc(profile.userId)
        .set(profile.toMap(), SetOptions(merge: true));

    await _firestore.collection('users').doc(profile.userId).set({
      'role': 'company',
      'isProfileComplete': profile.isProfileComplete,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  @override
  Future<CompanyProfileModel?> getProfile(String userId) async {
    final doc = await _firestore.collection('companies').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return CompanyProfileModel.fromMap(doc.data()!, userId);
    }
    return null;
  }
}
