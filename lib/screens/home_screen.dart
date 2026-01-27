import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/medicine.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Right Emergency Button
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => context.push('/emergency-support'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.shield_outlined, size: 18),
                  label: const Text('Emergency'),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Scan Card Section (Hero Area)
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push('/scan'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1E1E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Scan'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              // Upload logic placeholder
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Previous Prescription Shortcut
              InkWell(
                onTap: () {
                  // Navigate to prescription history or details
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.history, color: Colors.black54),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'My previous prescription',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 4. Medicine Today Section
              const Text(
                'Medicine Today',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _mockMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = _mockMedicines[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap:
                            () => context.push(
                              '/medicine-detail',
                              extra: medicine,
                            ),
                        child: _MedicineCard(
                          name: medicine.name,
                          time: medicine.time,
                          dosage: medicine.dosage,
                          color: medicine.color,
                          isActive: medicine.isCompleted,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 5. Activity Today Section
              const Text(
                'Activity Today',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Column(
                children: [
                  _ActivityCard(label: 'Drink 2L water', isChecked: false),
                  SizedBox(height: 12),
                  _ActivityCard(label: 'Walk 5000 steps', isChecked: false),
                  SizedBox(height: 12),
                  _ActivityCard(label: 'Sleep 8 hours', isChecked: false),
                ],
              ),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

final List<Medicine> _mockMedicines = [
  const Medicine(
    name: 'Metformin',
    dosage: '500mg',
    time: '8:00 AM',
    frequency: 'Daily',
    category: 'Diabetes',
    type: 'Tablet',
    color: Color(0xFFE3F2FD),
    purpose: 'Controls high blood sugar in people with type 2 diabetes.',
  ),
  const Medicine(
    name: 'Vitamin D3',
    dosage: '1 capsule',
    time: '1:00 PM',
    frequency: 'Daily',
    category: 'Supplement',
    type: 'Capsule',
    color: Color(0xFFF3E5F5),
    purpose: 'Helps absorb calcium and promote bone growth.',
    isCompleted: true,
  ),
  const Medicine(
    name: 'Lisinopril',
    dosage: '10mg',
    time: '8:00 PM',
    frequency: 'Daily',
    category: 'Hypertension',
    type: 'Tablet',
    color: Color(0xFFE8F5E9),
    purpose: 'Treats high blood pressure and heart failure.',
  ),
];

class _MedicineCard extends StatelessWidget {
  final String name;
  final String time;
  final String dosage;
  final Color color;
  final bool isActive;

  const _MedicineCard({
    required this.name,
    required this.time,
    required this.dosage,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage(
                'https://via.placeholder.com/100', // Placeholder for now
              ),
              fit: BoxFit.cover,
              opacity: 0.2, // Blend with color
            ),
          ),
          child:
              isActive
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 20,
                        color: Colors.green,
                      ),
                    ),
                  )
                  : null,
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          dosage,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          maxLines: 1, // Added maxLines
          overflow: TextOverflow.ellipsis, // Added ellipsis
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String label;
  final bool isChecked;

  const _ActivityCard({required this.label, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Replaced withOpacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!, width: 2),
              color: isChecked ? Colors.black : Colors.transparent,
            ),
            child:
                isChecked
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
