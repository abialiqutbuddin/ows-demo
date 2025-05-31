class ModuleModel {
  final int id;
  final String moduleName;
  final String moduleTitle;
  final String icon;
  final bool isEnabled;
  bool isHovered;
  final Function() onModuleOpen;

  final String? subtitle;
  final String? note;

  final bool? profileText;
  final String? profileComplete;
  final String? familyComplete;

  ModuleModel({
    required this.isEnabled,
    required this.id,
    required this.moduleName,
    required this.moduleTitle,
    required this.icon,
    this.isHovered = false,
    this.profileText = false,
    this.profileComplete,
    this.familyComplete,
    required this.onModuleOpen,
    this.subtitle, this.note,
  });
}
