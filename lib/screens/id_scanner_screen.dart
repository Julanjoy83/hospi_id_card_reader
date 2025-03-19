import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IDScannerScreen(),
    );
  }
}

class IDScannerScreen extends StatefulWidget {
  @override
  _IDScannerScreenState createState() => _IDScannerScreenState();
}

class _IDScannerScreenState extends State<IDScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  String scannedText = "";
  bool isScanning = false;

  Future<void> scanIDCard() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() => isScanning = true);

    final inputImage = InputImage.fromFile(File(image.path));
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    setState(() {
      scannedText = recognizedText.text;
      isScanning = false;
    });
  }

  Future<void> scanNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        scannedText = "NFC non disponible sur cet appareil";
      });
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        setState(() {
          scannedText = "Données NFC : ${tag.data}";
        });
        NfcManager.instance.stopSession();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ID Scanner")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: scanIDCard,
              child: Text("Scanner une carte d'identité (OCR)"),
            ),
            ElevatedButton(
              onPressed: scanNFC,
              child: Text("Scanner une carte d'identité (NFC)"),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(scannedText, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
