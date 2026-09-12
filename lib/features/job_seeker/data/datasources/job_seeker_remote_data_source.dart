import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_seeker_profile_model.dart';

abstract class JobSeekerRemoteDataSource {
  Future<void> saveProfile(JobSeekerProfileModel profile);
  Future<JobSeekerProfileModel?> getProfile(String userId);
}

class JobSeekerRemoteDataSourceImpl implements JobSeekerRemoteDataSource {
  final FirebaseFirestore _firestore;

  JobSeekerRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveProfile(JobSeekerProfileModel profile) async {
    await _firestore
        .collection('job_seekers')
        .doc(profile.userId)
        .set(profile.toMap(), SetOptions(merge: true));

    // Also update users collection flag
    await _firestore.collection('users').doc(profile.userId).set({
      'role': 'jobSeeker',
      'isProfileComplete': profile.isSubmitted,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  @override
  Future<JobSeekerProfileModel?> getProfile(String userId) async {
    final doc = await _firestore.collection('job_seekers').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return JobSeekerProfileModel.fromMap(doc.data()!, userId);
    }
    return null;
  }
}
