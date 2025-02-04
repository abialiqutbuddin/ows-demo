class Institute {
  final int id;
  final String name;
  final int cityId;
  final String cityName;
  final int marhalaId;
  final int isImani;

  Institute({
    required this.id,
    required this.name,
    required this.cityId,
    required this.cityName,
    required this.marhalaId,
    required this.isImani,
  });

  factory Institute.fromJson(Map<String, dynamic> json) {
    return Institute(
      id: json['id'] ?? 0, // Default to 0 if null
      name: json['name'] ?? 'Unknown University', // Default name if missing
      cityId: json['city_id'] ?? 0, // Default to 0
      cityName: json['city_name'] ?? 'Unknown City', // Default to prevent errors
      marhalaId: json['marhala_id'] ?? 0, // Default to 0
      isImani: json['is_imani'] ?? 0, // Default to 0
    );
  }
}