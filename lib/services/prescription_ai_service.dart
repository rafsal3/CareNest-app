import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/medicine_draft.dart';
import '../models/parsed_medicine.dart';

class UploadException implements Exception {
  final String message;
  UploadException(this.message);
  @override
  String toString() => message;
}

class ParseException implements Exception {
  final String message;
  ParseException(this.message);
  @override
  String toString() => message;
}

class PrescriptionAiService {
  final Dio _dio;
  static const String _baseUrl =
      'https://care-nest-ai-production-ba74.up.railway.app/analyze';

  PrescriptionAiService()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

  Future<List<MedicineDraft>> analyzePrescription(File imageFile) async {
    final int fileSize = await imageFile.length();
    final String fileName = imageFile.path.split('/').last;

    // Diagnostics Log
    if (kDebugMode) {
      debugPrint('🩺 [DIAGNOSTICS] Uploading File: ${imageFile.path}');
      debugPrint(
        '🩺 [DIAGNOSTICS] Size: ${(fileSize / 1024).toStringAsFixed(2)} KB',
      );
      debugPrint('🩺 [DIAGNOSTICS] Target URL: $_baseUrl');
    }

    if (!imageFile.existsSync()) {
      throw UploadException('Image file not found at ${imageFile.path}');
    }

    // Prepare Form Data
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: DioMediaType.parse(
          'image/jpeg',
        ), // Ensure consistent content type
      ),
    });

    int retryCount = 0;
    const maxRetries = 1;

    while (retryCount <= maxRetries) {
      try {
        final response = await _dio.post(
          _baseUrl,
          data: formData,
          options: Options(
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
          onSendProgress: (int sent, int total) {
            if (kDebugMode && total > 0) {
              final progress = (sent / total * 100).toStringAsFixed(1);
              debugPrint('⬆️ Upload Progress: $progress% ($sent/$total)');
            }
          },
        );

        if (kDebugMode) {
          debugPrint(
            '✅ [DIAGNOSTICS] AI Response Code: ${response.statusCode}',
          );
          debugPrint('✅ [DIAGNOSTICS] AI Response Body: ${response.data}');
        }

        return _normalizeResponse(response.data);
      } on DioException catch (e) {
        if (retryCount < maxRetries &&
            (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.receiveTimeout)) {
          retryCount++;
          debugPrint(
            '⚠️ [DIAGNOSTICS] Timeout. Retrying ($retryCount/$maxRetries)...',
          );
          continue;
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw UploadException(
            'Connection timed out. Please check your internet.',
          );
        }
        if (e.type == DioExceptionType.connectionError) {
          throw UploadException('No internet connection.');
        }
        if (e.response != null) {
          debugPrint(
            'API Error: ${e.response?.statusCode} - ${e.response?.data}',
          );
          throw UploadException('Server error: ${e.response?.statusCode}');
        }
        throw UploadException('Upload failed: ${e.message}');
      } catch (e) {
        if (e is UploadException || e is ParseException) rethrow;
        debugPrint('Unexpected error: $e');
        throw UploadException('An unexpected error occurred.');
      }
    }
    throw UploadException('Upload failed after retries.');
  }

  List<MedicineDraft> _normalizeResponse(dynamic data) {
    try {
      if (data is! List) {
        throw ParseException('Invalid response format: Expected a list.');
      }

      final parsedMedicines =
          data.map((json) {
            if (json is Map<String, dynamic>) {
              return ParsedMedicine.fromJson(json);
            }
            return ParsedMedicine(
              medicineName: '',
              genericName: '',
              medicineType: '',
              dosage: '',
              dailyFrequencyCount: '',
              timing: '',
              duration: '',
              sideEffects: '',
              useCase: '',
              warnings: '',
              storageInstructions: '',
            );
          }).toList();

      return parsedMedicines.map((pm) {
        final frequency = _parseInt(pm.dailyFrequencyCount) ?? 1;
        final duration = _parseInt(pm.duration) ?? 1;
        final times = _generateReminders(frequency);

        return MedicineDraft(
          name: pm.medicineName,
          dosage: pm.dosage,
          frequencyPerDay: frequency,
          timingText: pm.timing,
          durationDays: duration,
          scheduleTimes: times,
          source: 'AI_SCAN',
        );
      }).toList();
    } catch (e) {
      debugPrint('Parsing error: $e');
      throw ParseException('Failed to parse response data.');
    }
  }

  int? _parseInt(String input) {
    if (input.isEmpty) return null;
    final RegExp regExp = RegExp(r'\d+');
    final match = regExp.firstMatch(input);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  List<DateTime> _generateReminders(int frequency) {
    if (frequency <= 0) return [];

    // Spread between 8:00 AM and 10:00 PM (14 hours window)
    const int startHour = 8;
    const int endHour = 22;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate evenly spaced times
    // Example: freq=3, Window=14h (840m) -> Step=420m (7h) -> 8:00, 15:00, 22:00

    if (frequency == 1) {
      // If once a day, prefer 9:00 AM
      return [today.add(const Duration(hours: 9))];
    }

    final List<DateTime> times = [];
    final int totalMinutes = (endHour - startHour) * 60;

    // We want to span the full range if possible, so we divide by (frequency - 1)
    // to put the last dose at endHour. Unless frequency is huge.
    // If freq=2 -> step 840m -> 8:00, 22:00
    // If freq=3 -> step 420m -> 8:00, 15:00, 22:00
    // If freq=4 -> step 280m -> 8:00, 12:40, 17:20, 22:00

    final double stepMinutes = totalMinutes / (frequency - 1);

    for (int i = 0; i < frequency; i++) {
      final minutesToAdd = (i * stepMinutes).round();
      final time = today.add(Duration(hours: startHour, minutes: minutesToAdd));
      times.add(time);
    }

    return times;
  }
}
