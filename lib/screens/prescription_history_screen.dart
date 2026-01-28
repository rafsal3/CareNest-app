import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/prescription.dart';
import '../models/medicine.dart';
import '../models/user.dart';

class PrescriptionHistoryScreen extends StatelessWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data using Model
    // Note: Previous UI grouped medicines. New Backend model is 1 prescription = 1 medicine.
    // We will display them as individual entries or potentially grouped in future refactors.
    // For now, listing them strictly.
    final List<Prescription> history = [
      Prescription(
        id: 1,
        medicineId: 101,
        patientId: 1,
        doctorId: 10,
        dosage: '500mg',
        frequency: 'Twice daily',
        duration: '5 days',
        status: PrescriptionStatus.active,
        prescribedAt: DateTime(2026, 1, 18),
        doctor: const User(
          id: 10,
          email: 'sarah@test.com',
          name: 'Dr. Sarah Smith',
          role: UserRole.doctor,
        ),
        medicine: const Medicine(
          id: 101,
          name: 'Amoxicillin',
          type: 'Antibiotic',
        ),
      ),
      Prescription(
        id: 2,
        medicineId: 102,
        patientId: 1,
        doctorId: 10,
        dosage: '650mg',
        frequency: 'SOS',
        duration: '3 days',
        status: PrescriptionStatus.active,
        prescribedAt: DateTime(2026, 1, 18),
        doctor: const User(
          id: 10,
          email: 'sarah@test.com',
          name: 'Dr. Sarah Smith',
          role: UserRole.doctor,
        ),
        medicine: const Medicine(
          id: 102,
          name: 'Paracetamol',
          type: 'Analgesic',
        ),
      ),
      Prescription(
        id: 3,
        medicineId: 103,
        patientId: 1,
        doctorId: 11,
        dosage: '60k IU',
        frequency: 'Weekly',
        duration: '8 weeks',
        status: PrescriptionStatus.completed,
        prescribedAt: DateTime(2025, 12, 12),
        doctor: const User(
          id: 11,
          email: 'john@test.com',
          name: 'Dr. John Doe',
          role: UserRole.doctor,
        ),
        medicine: const Medicine(
          id: 103,
          name: 'Vitamin D',
          type: 'Supplement',
        ),
      ),
      Prescription(
        id: 4,
        medicineId: 104,
        patientId: 1,
        doctorId: 12,
        dosage: '500mg',
        frequency: 'Once daily',
        duration: 'Life long',
        status: PrescriptionStatus.completed,
        prescribedAt: DateTime(2025, 11, 5),
        doctor: const User(
          id: 12,
          email: 'emily@test.com',
          name: 'Dr. Emily White',
          role: UserRole.doctor,
        ),
        medicine: const Medicine(
          id: 104,
          name: 'Metformin',
          type: 'Antidiabetic',
        ),
      ),
    ];

    final bool showBack = GoRouter.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Prescription History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Handle manually
        leading:
            showBack
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(),
                )
                : null,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final prescription = history[index];
          return _PrescriptionCard(prescription: prescription);
        },
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Prescription prescription;

  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM y').format(prescription.prescribedAt);
    final doctorName = prescription.doctor?.name ?? 'Unknown Doctor';
    final medicineName = prescription.medicine?.name ?? 'Unknown Medicine';

    return InkWell(
      onTap: () {
        context.push('/prescription-detail', extra: prescription);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineName, // Showing Medicine name as primary info now since 1:1
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$doctorName • $dateStr',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
