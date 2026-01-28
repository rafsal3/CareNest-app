import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String id;
  final String name;
  final String? time;
  final String? dosage;
  final Color? color;
  final bool isTaken;
  final VoidCallback? onTap;

  const MedicineCard({
    super.key,
    required this.id,
    required this.name,
    this.time,
    this.dosage,
    this.color,
    this.isTaken = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.blue.withOpacity(0.2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isTaken ? 0.7 : 1.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isTaken ? 0.98 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'medicine_icon_$id',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.medication_outlined,
                          size: 40,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isTaken ? 1.0 : 0.0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 24,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (time != null)
                Text(
                  time!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isTaken ? Colors.grey : Colors.black,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isTaken ? Colors.grey : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (dosage != null)
                Text(
                  dosage!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
