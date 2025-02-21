class Permission {
  final int moduleId;
  final String moduleName;
  final int featureId;
  final String featureName;

  Permission({
    required this.moduleId,
    required this.moduleName,
    required this.featureId,
    required this.featureName,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      moduleId: json['module_id'],
      moduleName: json['module_name'],
      featureId: json['feature_id'],
      featureName: json['feature_name'],
    );
  }
}