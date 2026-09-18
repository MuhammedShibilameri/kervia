import 'package:equatable/equatable.dart';

class JobSeekerProfile extends Equatable {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final String? headline;
  final List<String> skills;

  const JobSeekerProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    this.headline,
    this.skills = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        email,
        phoneNumber,
        photoUrl,
        headline,
        skills,
      ];
}
