import 'package:equatable/equatable.dart';

/// User entity representing authenticated user
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  /// Get user initials from display name or email
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final words = displayName!.trim().split(' ');
      if (words.length == 1) {
        return words[0][0].toUpperCase();
      }
      return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// Get first name
  String get firstName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!.split(' ').first;
    }
    return email.split('@').first;
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, createdAt];
}
