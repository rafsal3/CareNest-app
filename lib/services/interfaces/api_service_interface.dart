abstract class IOcrService {
  Future<String> extractTextFromImage(String imagePath);
}

abstract class IAiService {
  Future<Map<String, dynamic>> parseMedicalText(String text);
}
