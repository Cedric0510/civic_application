import 'package:civic_app/features/account/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({required super.userId, super.preferredCity});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['id'] as String,
      preferredCity: json['preferred_city'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': userId, 'preferred_city': preferredCity};
  }
}
