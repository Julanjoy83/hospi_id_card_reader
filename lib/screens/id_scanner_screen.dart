import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import '../services/ocr_service.dart'; // Import du service OCR

class IdScannerScreen extends StatefulWidget {
  @override
  _IdScannerScreenState createState() => _IdScannerScreenState();
}

class _IdScannerScreenState extends State<IdScannerScreen> {
  WebSocketChannel? channel;
  String? receiverAddress;
  bool isScanningQR = true;
  bool isConnected = false; // Ajout pour confirmer la connexion
  final OCRService _ocrService = OCRService();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  // 🔹 Demander la permission de la caméra
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      print("❌ Permission caméra refusée");
      return;
    }
  }

  // 🔹 Scanner le QR Code et récupérer l'adresse WebSocket
  Future<void> _scanQRCode(String scannedData) async {
    print("📡 QR Code scanné : $scannedData");

    setState(() {
      receiverAddress = scannedData;
      isScanningQR = false;
      isConnected = false; // Réinitialiser l'état de connexion
    });

    // Connexion au serveur WebSocket
    try {
      channel = WebSocketChannel.connect(Uri.parse(receiverAddress!));
      print("✅ Connecté au serveur WebSocket : $receiverAddress");

      // Écoute des messages pour confirmer la connexion
      channel!.stream.listen(
            (message) {
          print("📩 Message reçu : $message");
          if (message == "CONNECTED") {
            setState(() {
              isConnected = true;
            });
          }
        },
        onDone: () {
          print("🔌 Déconnecté du serveur");
          setState(() {
            isConnected = false;
          });
        },
        onError: (error) {
          print("❌ Erreur WebSocket : $error");
          setState(() {
            isConnected = false;
          });
        },
      );

      // Envoyer un message de connexion
      channel!.sink.add(jsonEncode({"status": "scanner_connected"}));
    } catch (e) {
      print("❌ Erreur de connexion WebSocket : $e");
      setState(() {
        isConnected = false;
      });
    }
  }

  // 🔹 Ouvrir la galerie ou l'appareil photo pour capturer une image
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Scanner l'image avec l'OCR et envoyer les données
      _scanImageWithOCR();
    }
  }

  // 🔹 Scanner l’image avec l’OCR et envoyer les données
  Future<void> _scanImageWithOCR() async {
    if (_selectedImage == null) return;

    Map<String, String> extractedData = await _ocrService.scanTextFromImage(_selectedImage!);

    if (channel == null) {
      print("❌ Aucune connexion WebSocket !");
      return;
    }

    // Envoi des données extraites au récepteur
    channel!.sink.add(jsonEncode(extractedData));

    print("📤 Données envoyées au serveur : $extractedData");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner QR Code & ID")),
      body: Center(
        child: isScanningQR
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "📷 Scannez le QR Code du récepteur",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MobileScanner(
                controller: MobileScannerController(torchEnabled: false),
                onDetect: (BarcodeCapture barcode) {
                  final String? scannedData = barcode.barcodes.first.rawValue;
                  if (scannedData != null) {
                    _scanQRCode(scannedData);
                  }
                },
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isConnected
                  ? "🟢 Connecté à : $receiverAddress"
                  : "🔴 Connexion en attente...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Boutons pour choisir une image ou scanner l'ID
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Galerie"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Scanner ID"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),

            // 🔹 Affichage de l'image sélectionnée
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.file(_selectedImage!, height: 200),
              ),

            const SizedBox(height: 20),

            // 🔹 Bouton pour envoyer les données après scan OCR
            ElevatedButton(
              onPressed: _scanImageWithOCR,
              child: const Text("Envoyer les données"),
            ),
          ],
        ),
      ),
    );
  }
}
