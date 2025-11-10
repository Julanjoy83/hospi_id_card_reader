// =======================
// id_scanner_screen.dart
// (Gravure NFC -> envoi à la borne uniquement APRÈS succès)
// =======================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import '../services/ocr_service.dart';
import 'styled_camera_screen.dart'; // ✅ Nouvelle caméra stylisée

class IdScannerScreen extends StatefulWidget {
  final WebSocket? socket;
  final bool isConnected;
  final VoidCallback? onReturnToSplash;

  const IdScannerScreen({
    super.key,
    this.socket,
    this.isConnected = false,
    this.onReturnToSplash,
  });

  @override
  State<IdScannerScreen> createState() => _IdScannerScreenState();
}

class _IdScannerScreenState extends State<IdScannerScreen>
    with TickerProviderStateMixin {
  // ====== Services ======
  final OCRService _ocrService = OCRService();
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  final MethodChannel _nfcChannel = const MethodChannel('com.hospi_id_scan.nfc');

  // ====== Réseau ======
  WebSocket? _socket;
  bool _isConnected = false;
  bool _ownsSocket = false;

  // ====== OCR / UI ======
  File? _selectedImage;
  Map<String, String>? _extracted;
  bool _isProcessing = false;
  bool _isSpeaking = false;

  // ====== Palette ======
  static const Color primaryBlue = Color(0xFF0A84FF);
  static const Color darkBlue = Color(0xFF0066CC);
  static const Color softBlue = Color(0xFF64B5F6);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningAmber = Color(0xFFFFB800);
  static const Color errorRed = Color(0xFFFF3B30);
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textMuted = Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    _initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _speak("Placez votre carte d'identité dans le cadre de la caméra.");
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _openStyledCamera();
    });
  }

  // ====== TTS ======
  Future<void> _initTts() async {
    await _tts.setLanguage("fr-FR");
    await _tts.setSpeechRate(0.9);
    await _tts.setVolume(0.9);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) await _tts.stop();
    try {
      await _tts.speak(text);
    } catch (_) {
      setState(() => _isSpeaking = false);
    }
  }

  // ====== Ouvrir caméra stylisée ======
  Future<void> _openStyledCamera() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StyledCameraScreen(
          onCaptured: (file) async {
            setState(() {
              _selectedImage = File(file.path);
              _isProcessing = true;
              _extracted = null;
            });

            try {
              final raw = await _ocrService.scanTextFromImage(_selectedImage!);
              final normalized = <String, String>{
                'name': (raw['nom'] ?? raw['nomUsage'] ?? '').toString(),
                'surname': (raw['prenoms'] ?? raw['givenNames'] ?? '').toString(),
                'idNumber': (raw['idNumber'] ?? '').toString(),
                'nationality': (raw['nationalite'] ?? raw['nationality'] ?? '').toString(),
                ...raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
              };

              if (!mounted) return;
              setState(() {
                _extracted = normalized;
                _isProcessing = false;
              });

              _showSnackBar("✅ Scan terminé avec succès !", successGreen);
              await _speak("Scan terminé avec succès !");
            } catch (e) {
              if (!mounted) return;
              setState(() => _isProcessing = false);
              _showSnackBar("❌ Erreur de traitement : $e", errorRed);
              await _speak("Erreur, veuillez réessayer.");
            }
          },
        ),
      ),
    );
  }

  // ====== Affichage Snackbar ======
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(14),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Scanner la pièce d'identité",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _openStyledCamera,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Recommencer",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const Column(
                children: [
                  SizedBox(height: 40),
                  CircularProgressIndicator(color: primaryBlue, strokeWidth: 4),
                  SizedBox(height: 12),
                  Text("Analyse en cours...",
                      style: TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            if (_extracted != null && !_isProcessing)
              Expanded(
                child: ListView(
                  children: _extracted!.entries
                      .map((e) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            color: primaryBlue, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: textDark)),
                              Text(e.value,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            if (!_isProcessing && _extracted == null)
              const Expanded(
                child: Center(
                  child: Text(
                    "Aucune donnée pour le moment.\nAppuyez sur 'Scanner' pour démarrer.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openStyledCamera,
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scanner"),
      ),
    );
  }
}
