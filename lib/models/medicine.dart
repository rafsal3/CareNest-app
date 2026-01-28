import 'package:equatable/equatable.dart';

class Medicine extends Equatable {
  final int id;
  final String name;
  final String? genericName;
  final String type;
  final String? sideEffects;
  final String? useCase;
  final String? warnings;
  final String? storageInstructions;

  const Medicine({
    required this.id,
    required this.name,
    this.genericName,
    required this.type,
    this.sideEffects,
    this.useCase,
    this.warnings,
    this.storageInstructions,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as int,
      name: json['name'] as String,
      genericName: json['genericName'] as String?,
      type:
          json['medicineType'] as String? ??
          json['type'] as String? ??
          'Unknown',
      sideEffects: json['sideEffects'] as String?,
      useCase: json['useCase'] as String?,
      warnings: json['warnings'] as String?,
      storageInstructions: json['storageInstructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'medicineType': type,
      'sideEffects': sideEffects,
      'useCase': useCase,
      'warnings': warnings,
      'storageInstructions': storageInstructions,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    genericName,
    type,
    sideEffects,
    useCase,
    warnings,
    storageInstructions,
  ];
}
