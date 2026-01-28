import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  Future<List<ParsedMedicine>> analyzePrescription(File imageFile) async {
    final int fileSize = await imageFile.length();
    final String fileName = imageFile.path.split('/').last;

    if (kDebugMode) {
      print('🚀 [Upload Start] Time: ${DateTime.now()}');
      print('📄 File: ${imageFile.path}');
      print('📦 Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
    }

    try {
      if (!imageFile.existsSync()) {
        throw UploadException('Image file not found at ${imageFile.path}');
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        _baseUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          if (kDebugMode && total > 0) {
            final progress = (sent / total * 100).toStringAsFixed(1);
            print('⬆️ Upload Progress: $progress% ($sent/$total)');
          }
        },
      );

      if (kDebugMode) {
        print('✅ [Upload Success] Status: ${response.statusCode}');
        print('📥 Response Body: ${response.data}');
      }

      return _parseResponse(response.data);
    } on DioException catch (e) {
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

  List<ParsedMedicine> _parseResponse(dynamic data) {
    try {
      if (data is List) {
        return data.map((json) {
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
          ); // Fallback for invalid items
        }).toList();
      } else {
        throw ParseException('Invalid response format: Expected a list.');
      }
    } catch (e) {
      debugPrint('Parsing error: $e');
      throw ParseException('Failed to parse response data.');
    }
  }
}
