import 'json_helpers.dart';

class ProfileModel {
  final String id;
  final String? username;
  final String? avatarUrl;
  final String? email;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.id,
    this.username,
    this.avatarUrl,
    this.email,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      updatedAt: parseSupabaseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toUpsertJson({
    String? username,
    String? email,
    String? avatarUrl,
  }) {
    return {
      'id': id,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
