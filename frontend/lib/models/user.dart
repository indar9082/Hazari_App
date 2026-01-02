// lib/models/user.dart - ✅ COMBINED & ENHANCED VERSION
import 'package:flutter/material.dart';

class User {
  final int id;
  final String username;
  final String phone;
  final String role;
  final String? token; // JWT token after login (optional, stored in ApiService)
  final String? name;  // Display name
  final String? profilePhoto;

  User({
    required this.id,
    required this.username,
    required this.phone,
    required this.role,
    this.token,
    this.name,
    this.profilePhoto,
  });

  // ✅ From JSON (handles both API formats + fallback)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['userId'] ?? 0,
      username: json['username'] ?? json['name'] ?? json['login'] ?? 'Unknown',
      phone: json['phone'] ?? 'N/A',
      role: json['role'] ?? 'LABOUR',
      name: json['name'] ?? json['displayName'],
      profilePhoto: json['profilePhoto'] ?? json['photoUrl'],
      // Note: token comes from login response, not profile API
    );
  }

  // ✅ To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'role': role,
      if (name != null) 'name': name,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
    };
  }

  // ✅ Copy with (immutable updates)
  User copyWith({
    int? id,
    String? username,
    String? phone,
    String? role,
    String? token,
    String? name,
    String? profilePhoto,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  // ✅ Role-based display name
  String get roleDisplay {
    switch (role.toUpperCase()) {
      case 'LABOUR':
        return 'Labour Worker';
      case 'CONTRACTOR':
        return 'Contractor';
      case 'ADMIN':
        return 'Admin';
      case 'MANAGER':
        return 'Manager';
      default:
        return role;
    }
  }

  // ✅ Role-based status color
  Color get roleColor {
    switch (role.toUpperCase()) {
      case 'LABOUR':
        return Colors.blue.shade600;
      case 'CONTRACTOR':
        return Colors.purple.shade600;
      case 'ADMIN':
        return Colors.orange.shade600;
      case 'MANAGER':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // ✅ Full display name (name or username fallback)
  String get displayName => name?.isNotEmpty == true ? name! : username;

  // ✅ Profile image URL (with fallback)
  String get profileImageUrl => profilePhoto ?? '';

  // ✅ Equality override (for ListView distinct items)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode;

  // ✅ String representation for debugging
  @override
  String toString() {
    return 'User(id: $id, username: $username, role: $role, phone: $phone)';
  }
}
