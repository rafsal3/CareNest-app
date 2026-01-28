import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/parsed_medicine.dart';

class AiPrescriptionService {
  static const String _baseUrl =
      'https://care-nest-ai-production-ba74.up.railway.app/analyze';

  Future<List<ParsedMedicine>> uploadPrescription(File imageFile) async {
    try {
      final uri = Uri.parse(_baseUrl);
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      if (kDebugMode) {
        print('Starting upload for: ${imageFile.path}');
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timed out. Please check your internet.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Upload status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading prescription: $e');
      }
      rethrow;
    }
  }

  List<ParsedMedicine> _parseResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is List) {
        return decoded.map((json) {
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
      } else {
        throw Exception('Invalid response format: Expected a list.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Parsing error: $e');
      }
      throw Exception('Failed to parse response data.');
    }
  }
}
