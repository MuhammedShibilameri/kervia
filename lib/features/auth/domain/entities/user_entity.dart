import 'package:equatable/equatable.dart';

enum UserRole {
  jobSeeker,
  company,
  unassigned,
}

class UserEntity extends Equatable {
  final String id;
  final String? phoneNumber;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final bool isProfileComplete;

  const UserEntity({
    required this.id,
    this.phoneNumber,
    this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.unassigned,
    this.isProfileComplete = false,
  });

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        email,
        displayName,
        photoUrl,
        role,
        isProfileComplete,
      ];
}
