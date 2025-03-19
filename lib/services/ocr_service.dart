import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class OCRService {
  Future<Map<String, String>> scanTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    String extractedText = recognizedText.text;

    print("🔍 Texte extrait par OCR :\n$extractedText"); // DEBUG

    // Extraire Nom, Prénom, Numéro ID, Nationalité
    Map<String, String> extractedData = _extractDataFromText(extractedText);

    print("📤 Données extraites : $extractedData"); // DEBUG

    return extractedData;
  }

  // 🔍 Amélioration de l'extraction des données
  Map<String, String> _extractDataFromText(String text) {
    List<String> lines = text.split('\n');
    String name = "";
    String surname = "";
    String idNumber = "";
    String nationality = "";

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // 🔹 NOM détecté → Ligne suivante contient le nom de famille
      if (line.contains(RegExp(r'\b(NOMS|SURNAMES|Forenames)\b', caseSensitive: false))) {
        if (i + 1 < lines.length) name = lines[i + 1].trim();
        if (i + 2 < lines.length) surname = lines[i + 2].trim();
      }

      // 🔹 Nationalité détectée → Ligne suivante contient la valeur
      if (line.contains(RegExp(r'\b(NATIONALITE|NATIONALITY|NAT)\b', caseSensitive: false))) {
        if (i + 1 < lines.length) nationality = lines[i + 1].trim();
      }

      // 🔹 Numéro personnel détecté → Ligne suivante contient l'ID
      if (line.contains(RegExp(r'\b(NUMÉRO PERSONNEL|PERSONAL NUMBER)\b', caseSensitive: false))) {
        if (i + 1 < lines.length) idNumber = lines[i + 1].trim();
      }
    }

    return {
      "name": name,
      "surname": surname,
      "idNumber": idNumber,
      "nationality": nationality,
    };
  }
}
