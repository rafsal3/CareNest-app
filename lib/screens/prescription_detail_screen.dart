import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final String date;

  const PrescriptionDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Details for $date',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Prescription image and details would appear here.'),
          ],
        ),
      ),
    );
  }
}
