class UserPermission {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final List<Trust>? trusts; // For trust-admin and coordinator

  UserPermission({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.trusts,
  });

  factory UserPermission.fromJson(Map<String, dynamic> json) {
    return UserPermission(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRoleExtension.fromString(json['role']),
      trusts: (json['trusts'] ?? json['assigned_trusts'])?.map<Trust>((e) => Trust.fromJson(e))
          .toList(),
    );
  }
}

enum UserRole { admin, trustAdmin, coordinator, unknown }

extension UserRoleExtension on UserRole {
  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'trust_admin':
        return UserRole.trustAdmin;
      case 'coordinator':
        return UserRole.coordinator;
      default:
        return UserRole.unknown;
    }
  }

  String get name {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.trustAdmin:
        return 'Trust Admin';
      case UserRole.coordinator:
        return 'Coordinator';
      default:
        return 'Unknown';
    }
  }
}

class Trust {
  final int id;
  final String trustId;
  final String trustName;
  final TrustPermission? permissions; // Only for coordinator role

  Trust({
    required this.id,
    required this.trustId,
    required this.trustName,
    this.permissions,
  });

  factory Trust.fromJson(Map<String, dynamic> json) {
    return Trust(
      id: json['id'],
      trustId: json['trustid'] ?? '',
      trustName: json['trustname'] ?? '',
      permissions: json['permissions'] != null
          ? TrustPermission.fromJson(json['permissions'])
          : null,
    );
  }
}

class TrustPermission {
  final bool canView;
  final bool canUpdate;

  TrustPermission({required this.canView, required this.canUpdate});

  factory TrustPermission.fromJson(Map<String, dynamic> json) {
    return TrustPermission(
      canView: json['can_view'] ?? false,
      canUpdate: json['can_update'] ?? false,
    );
  }
}