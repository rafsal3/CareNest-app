class MedicineDraft {
  final String? name;
  final String? dosage;
  final int? frequencyPerDay;
  final String? timingText;
  final int? durationDays;
  final List<DateTime> scheduleTimes;
  final String source;

  MedicineDraft({
    this.name,
    this.dosage,
    this.frequencyPerDay,
    this.timingText,
    this.durationDays,
    this.scheduleTimes = const [],
    this.source = 'AI_SCAN',
  });

  @override
  String toString() {
    return 'MedicineDraft(name: $name, dosage: $dosage, freq: $frequencyPerDay, times: $scheduleTimes)';
  }
}
