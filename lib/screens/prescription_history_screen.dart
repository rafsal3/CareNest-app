import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/prescription.dart';

class PrescriptionHistoryScreen extends StatelessWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data using Model
    final List<Prescription> history = [
      const Prescription(
        id: '1',
        date: '18 Jan 2026',
        doctorName: 'Dr. Sarah Smith',
        medicines: [
          PrescriptionMedicine(
            name: 'Amoxicillin',
            dosage: '500mg',
            frequency: 'Twice daily',
            time: 'After food',
          ),
          PrescriptionMedicine(
            name: 'Paracetamol',
            dosage: '650mg',
            frequency: 'SOS',
            time: 'After food',
          ),
        ],
      ),
      const Prescription(
        id: '2',
        date: '12 Dec 2025',
        doctorName: 'Dr. John Doe',
        medicines: [
          PrescriptionMedicine(
            name: 'Vitamin D',
            dosage: '60k IU',
            frequency: 'Weekly',
            time: 'After breakfast',
          ),
        ],
      ),
      const Prescription(
        id: '3',
        date: '05 Nov 2025',
        doctorName: 'Dr. Emily White',
        medicines: [
          PrescriptionMedicine(
            name: 'Metformin',
            dosage: '500mg',
            frequency: 'Once daily',
            time: 'Before food',
          ),
        ],
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
                    prescription.date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prescription.doctorName,
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
