import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class OCRService {
  Future<String> scanTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }
}
