import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class BootstrapWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const BootstrapWrapper({super.key, required this.child});

  @override
  ConsumerState<BootstrapWrapper> createState() => _BootstrapWrapperState();
}

class _BootstrapWrapperState extends ConsumerState<BootstrapWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Initialize services
    // We access providers via ref to ensure they are created and their resources are init
    try {
      final storageService = ref.read(storageServiceProvider);
      final reminderService = ref.read(reminderServiceProvider);

      await Future.wait([
        storageService.init(),
        reminderService.init(),
        // Add a minimum delay to prevent flicker if init is too fast
        Future.delayed(const Duration(milliseconds: 800)),
      ]);
    } catch (e) {
      debugPrint('Bootstrap initialization error: $e');
      // Proceed anyway or show error screen? For now proceed.
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return widget.child;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // You can replace this with your app logo
              const Icon(
                Icons.medical_services_rounded,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }
}
