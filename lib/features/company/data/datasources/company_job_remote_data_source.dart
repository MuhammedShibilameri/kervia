import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../applications/data/models/job_application_model.dart';
import '../../../applications/domain/entities/job_application_entity.dart';
import '../models/job_post_model.dart';

abstract class CompanyJobRemoteDataSource {
  Future<String> saveJobPost(JobPostModel job);
  Future<List<JobPostModel>> getCompanyJobs(String companyId);
  Future<void> updateJobStatus(String jobId, String status);
  Future<void> deleteJobPost(String jobId);
  Future<List<JobApplicationModel>> getApplicationsForCompany(
      String companyId);
  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status);
}

class CompanyJobRemoteDataSourceImpl implements CompanyJobRemoteDataSource {
  final FirebaseFirestore _firestore;

  CompanyJobRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> saveJobPost(JobPostModel job) async {
    if (job.id != null && job.id!.isNotEmpty) {
      await _firestore
          .collection('jobs')
          .doc(job.id)
          .set(job.toMap(), SetOptions(merge: true));
      return job.id!;
    }
    final docRef = await _firestore.collection('jobs').add(job.toMap());
    return docRef.id;
  }

  @override
  Future<List<JobPostModel>> getCompanyJobs(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .orderBy('updatedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => JobPostModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      try {
        final fallback = await _firestore
            .collection('jobs')
            .where('companyId', isEqualTo: companyId)
            .get();
        return fallback.docs
            .map((doc) => JobPostModel.fromMap(doc.data(), doc.id))
            .toList();
      } catch (_) {
        return const [];
      }
    }
  }

  @override
  Future<void> updateJobStatus(String jobId, String status) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'jobStatus': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteJobPost(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).delete();
  }

  @override
  Future<List<JobApplicationModel>> getApplicationsForCompany(
      String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('companyId', isEqualTo: companyId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => JobApplicationModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {
      // Fall through to empty list when the index/query is unavailable.
    }
    return const [];
  }

  @override
  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'status': status.name,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }
}