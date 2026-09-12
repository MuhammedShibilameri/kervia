import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.phoneNumber,
    super.email,
    super.displayName,
    super.photoUrl,
    super.role = UserRole.unassigned,
    super.isProfileComplete = false,
  });

  factory UserModel.fromFirebaseUser(fb.User user, {UserRole role = UserRole.unassigned, bool isProfileComplete = false}) {
    return UserModel(
      id: user.uid,
      phoneNumber: user.phoneNumber,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: role,
      isProfileComplete: isProfileComplete,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: _parseRole(map['role'] as String?),
      isProfileComplete: (map['isProfileComplete'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'isProfileComplete': isProfileComplete,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role?.trim().toLowerCase()) {
      case 'jobseeker':
        return UserRole.jobSeeker;
      case 'company':
        return UserRole.company;
      default:
        return UserRole.unassigned;
    }
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
