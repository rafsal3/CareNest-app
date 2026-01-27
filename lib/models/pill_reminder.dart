class PillReminder {
  final String id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final DateTime time;
  final bool isActive;

  PillReminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'time': time.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory PillReminder.fromJson(Map<String, dynamic> json) {
    return PillReminder(
      id: json['id'],
      medicineName: json['medicineName'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      time: DateTime.parse(json['time']),
      isActive: json['isActive'],
    );
  }

  PillReminder copyWith({
    String? id,
    String? medicineName,
    String? dosage,
    String? frequency,
    DateTime? time,
    bool? isActive,
  }) {
    return PillReminder(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
    );
  }
}
