class Instruction {
  final int id;
  final String shortDesc;
  final String longDesc;
  final int grpSerId;

  Instruction({
    required this.id,
    required this.shortDesc,
    required this.longDesc,
    required this.grpSerId,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) {
    return Instruction(
      id: int.parse(json['codId'].toString()),
      shortDesc: json['shortDesc'] ?? '',
      longDesc: json['longDesc'] ?? '',
      grpSerId: int.tryParse(json['grpSerId'].toString()) ?? 0,
    );
  }
}