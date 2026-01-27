class Prescription {
  final String id;
  final String date;
  final String doctorName;
  final List<PrescriptionMedicine> medicines;

  const Prescription({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.medicines,
  });
}

class PrescriptionMedicine {
  final String name;
  final String dosage;
  final String frequency;
  final String time;

  const PrescriptionMedicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
  });
}
