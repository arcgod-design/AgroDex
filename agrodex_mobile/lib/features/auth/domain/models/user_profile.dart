import 'package:flutter/foundation.dart';

/// Immutable domain model representing a user's profile in AgroDex
/// matching the Supabase `profiles` table and wallet association metadata.
@immutable
class UserProfile {
  final String id;
  final String? email;
  final String? hederaAccountId;
  final String authMethod; // 'email', 'wallet', or 'hybrid'
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  const UserProfile({
    required this.id,
    this.email,
    this.hederaAccountId,
    this.authMethod = 'email',
    this.createdAt,
    this.metadata,
  });

  bool get isWalletConnected =>
      hederaAccountId != null && hederaAccountId!.isNotEmpty;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString(),
      hederaAccountId: json['hedera_account_id']?.toString(),
      authMethod: json['auth_method']?.toString() ?? 'email',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (hederaAccountId != null) 'hedera_account_id': hederaAccountId,
      'auth_method': authMethod,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? hederaAccountId,
    String? authMethod,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      hederaAccountId: hederaAccountId ?? this.hederaAccountId,
      authMethod: authMethod ?? this.authMethod,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.hederaAccountId == hederaAccountId &&
        other.authMethod == authMethod;
  }

  @override
  int get hashCode => Object.hash(id, email, hederaAccountId, authMethod);

  @override
  String toString() =>
      'UserProfile(id: $id, email: $email, hederaAccountId: $hederaAccountId, authMethod: $authMethod)';
}
