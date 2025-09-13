import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../shared/theme/app_theme.dart';
import '../services/interfaces/document_extractor.dart';
import '../services/interfaces/nfc_service.dart';
import '../services/models/document_data.dart';
import '../services/ocr_service.dart';
import '../services/nfc_service.dart';
import '../core/config/app_config.dart';
import 'widgets/scanner_header_widget.dart';
import 'widgets/welcome_message_widget.dart';
import 'widgets/action_buttons_widget.dart';
import 'widgets/image_preview_widget.dart';
import 'widgets/processing_indicator_widget.dart';
import 'widgets/extraction_result_widget.dart';

/// Simplified document scanner screen using clean architecture
class IdScannerScreen extends StatefulWidget {
  const IdScannerScreen({super.key});

  @override
  State<IdScannerScreen> createState() => _IdScannerScreenState();
}

class _IdScannerScreenState extends State<IdScannerScreen>
    with TickerProviderStateMixin {

  // Services
  late final IDocumentExtractor _documentExtractor;
  late final INfcService _nfcService;
  late final FlutterTts _tts;

  // State
  File? _selectedImage;
  DocumentData? _extractedData;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isWritingNfc = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimations();
    _speakWelcomeMessage();
  }

  void _initializeServices() {
    _documentExtractor = GoogleMLKitDocumentExtractor();
    _nfcService = NfcService();
    _tts = FlutterTts();
    _initializeTTS();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );
  }

  void _initializeTTS() async {
    await _tts.setLanguage("fr-FR");
    await _tts.setSpeechRate(0.5); // Ralenti de 0.8 à 0.5 (plus lent)
    await _tts.setVolume(0.9);

    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _tts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
      if (AppConfig.instance.security.enableLogging) {
        print("TTS Error: $msg");
      }
    });
  }

  Future<void> _speakWelcomeMessage() async {
    const message = "Bienvenue à l'hôtel Ibis ! Je suis LOUNA, votre assistante pour l'enregistrement. Scannez votre pièce d'identité, puis nous l'écrirons sur votre carte NFC.";
    await _speakText(message);
  }

  Future<void> _speakText(String message) async {
    if (_isSpeaking) await _tts.stop();
    try {
      // Ajouter des pauses pour une lecture plus naturelle
      final messageWithPauses = message
          .replaceAll('. ', '... ') // Pause plus longue après les points
          .replaceAll(', ', '. ') // Pause courte après les virgules
          .replaceAll('!', '...') // Pause après exclamations
          .replaceAll('?', '...'); // Pause après questions

      await _tts.setSpeechRate(0.7);
      await _tts.speak(messageWithPauses);
    } catch (e) {
      setState(() => _isSpeaking = false);
      if (AppConfig.instance.security.enableLogging) {
        print("TTS Error:s $e");
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (AppConfig.instance.security.enableLogging) {
        print("🎥 Tentative d'accès à ${source == ImageSource.camera ? 'caméra' : 'galerie'}");
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        if (AppConfig.instance.security.enableLogging) {
          print("❌ Aucune image sélectionnée ou permission refusée");
        }
        _showErrorSnackBar("Aucune image sélectionnée");
        return;
      }

      if (AppConfig.instance.security.enableLogging) {
        print("✅ Image sélectionnée: ${image.path}");
      }

      setState(() {
        _selectedImage = File(image.path);
        _extractedData = null;
        _isProcessing = true;
      });

      _fadeController.forward();
      _slideController.forward();

      await _speakText("Parfait ! Je traite maintenant votre document. Patientez quelques instants.");

      // Extract document data
      if (AppConfig.instance.security.enableLogging) {
        print("🔍 Début de l'extraction OCR...");
      }

      final result = await _documentExtractor.extractData(_selectedImage!);

      result.when(
        success: (data) {
          if (AppConfig.instance.security.enableLogging) {
            print("✅ Extraction réussie: ${data.toJson()}");
          }
          setState(() {
            _extractedData = data;
            _isProcessing = false;
          });
          _speakText("Excellent ! Vos informations ont été extraites avec succès. Vous pouvez maintenant obtenir votre carte de chambre.");
        },
        failure: (error) {
          if (AppConfig.instance.security.enableLogging) {
            print("❌ Erreur d'extraction: ${error.message}");
          }
          setState(() => _isProcessing = false);
          _showErrorSnackBar("Erreur d'extraction: ${error.message}");
          _speakText("Désolé, une erreur s'est produite lors du traitement. Veuillez réessayer.");
        },
      );
    } catch (e) {
      if (AppConfig.instance.security.enableLogging) {
        print("❌ Erreur critique: $e");
      }
      setState(() => _isProcessing = false);
      _showErrorSnackBar("Erreur: $e");
      _speakText("Une erreur inattendue s'est produite. Veuillez réessayer.");
    }
  }

  Future<void> _writeToNfc() async {
    if (_extractedData == null) {
      _showErrorSnackBar("Aucune donnée à écrire");
      return;
    }

    setState(() => _isWritingNfc = true);

    await _speakText("Parfait ! Votre carte de chambre est en cours de préparation. Approchez la carte fournie du capteur orange");

    final jsonData = jsonEncode(_extractedData!.toJson());
    final result = await _nfcService.writeToCard(jsonData);

    result.when(
      success: (writeResult) {
        setState(() => _isWritingNfc = false);
        _showSuccessSnackBar("✅ Carte de chambre obtenue avec succès !");
        _speakText("Excellent ! Votre carte de chambre est prête. Votre enregistrement à l'hôtel Ibis est maintenant terminé. Bienvenue !");
      },
      failure: (error) {
        setState(() => _isWritingNfc = false);
        _showErrorSnackBar("❌ Erreur : ${error.message}");
        _speakText("Désolé, une erreur s'est produite. Veuillez réessayer.");
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.hotel, color: AppTheme.onPrimaryTextColor),
            AppSpacing.sm,
            Text(
              "IBIS • Check-in",
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.onPrimaryTextColor,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          children: [
            // Header
            const ScannerHeaderWidget(),
            AppSpacing.lg,

            // Welcome message
            const WelcomeMessageWidget(),
            AppSpacing.lg,

            // Action buttons
            ActionButtonsWidget(
              onCameraPressed: () => _pickImage(ImageSource.camera),
              onGalleryPressed: () => _pickImage(ImageSource.gallery),
              isSpeaking: _isSpeaking,
            ),

            // Image preview
            if (_selectedImage != null)
              ImagePreviewWidget(imageFile: _selectedImage!),

            // Processing indicator
            if (_isProcessing) ...[
              AppSpacing.lg,
              const ProcessingIndicatorWidget(),
            ],

            // Extracted data
            if (_extractedData != null && !_isProcessing) ...[
              AppSpacing.lg,
              ExtractionResultWidget(
                data: _extractedData!.toJson().map((k, v) => MapEntry(k, v.toString())),
                onNfcWritePressed: _writeToNfc,
                isWritingNfc: _isWritingNfc,
              ),
            ],

            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}