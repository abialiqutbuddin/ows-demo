class ModuleModel {
  final int id;
  final String moduleName;
  final String moduleTitle;
  final String icon;
  bool isHovered;
  final List<int> featureIds; // List of feature IDs for dynamic permissions
  final Function(List<int> featureIds, String its, String mohalla)? onModuleOpen;

  ModuleModel({
    required this.id,
    required this.moduleName,
    required this.moduleTitle,
    required this.icon,
    this.isHovered = false,
    this.featureIds = const [],
    this.onModuleOpen,
  });

  ModuleModel copyWith({List<int>? featureIds}) {
    return ModuleModel(
      id: id,
      moduleName: moduleName,
      moduleTitle: moduleTitle,
      icon: icon,
      featureIds: featureIds ?? this.featureIds,
      onModuleOpen: onModuleOpen,
    );
  }
}
