class ParsedMedicine {
  final String medicineName;
  final String genericName;
  final String medicineType;
  final String dosage;
  final String dailyFrequencyCount;
  final String timing;
  final String duration;
  final String sideEffects;
  final String useCase;
  final String warnings;
  final String storageInstructions;

  ParsedMedicine({
    required this.medicineName,
    required this.genericName,
    required this.medicineType,
    required this.dosage,
    required this.dailyFrequencyCount,
    required this.timing,
    required this.duration,
    required this.sideEffects,
    required this.useCase,
    required this.warnings,
    required this.storageInstructions,
  });

  factory ParsedMedicine.fromJson(Map<String, dynamic> json) {
    return ParsedMedicine(
      medicineName: json['medicine_name']?.toString() ?? '',
      genericName: json['generic_name']?.toString() ?? '',
      medicineType: json['medicine_type']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      dailyFrequencyCount: json['daily_frequency_count']?.toString() ?? '',
      timing: json['timing']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      sideEffects: json['side_effects']?.toString() ?? '',
      useCase: json['use_case']?.toString() ?? '',
      warnings: json['warnings']?.toString() ?? '',
      storageInstructions: json['storage_instructions']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'ParsedMedicine(medicineName: $medicineName, dosage: $dosage)';
  }
}
