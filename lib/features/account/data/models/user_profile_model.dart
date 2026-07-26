import 'package:civic_app/features/account/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({required super.id, required super.email});

  // Reflète GET /citizens/me (civic_api).
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }
}
