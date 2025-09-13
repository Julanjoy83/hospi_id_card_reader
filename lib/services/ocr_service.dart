import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../core/errors/document_extraction_failure.dart';
import '../core/types/result.dart';
import '../core/config/app_config.dart';
import 'interfaces/document_extractor.dart';
import 'models/document_data.dart';

/// Google ML Kit implementation of document text extraction
///
/// This service uses Google ML Kit's text recognition to extract structured data
/// from identity documents like passports, ID cards, and driver's licenses.
class GoogleMLKitDocumentExtractor implements IDocumentExtractor {
  GoogleMLKitDocumentExtractor({
    TextRecognizer? textRecognizer,
  }) : _textRecognizer = textRecognizer ?? TextRecognizer();

  final TextRecognizer _textRecognizer;

  @override
  Future<Result<DocumentData, DocumentExtractionFailure>> extractData(File imageFile) async {
    try {
      // Validate input file
      if (!await imageFile.exists()) {
        return const Failure(
          DocumentExtractionFailure(
            message: 'Image file does not exist',
            code: 'FILE_NOT_FOUND',
          ),
        );
      }

      final inputImage = InputImage.fromFile(imageFile);

      // Process the image
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final extractedText = recognizedText.text;

      // Log extracted text in debug mode
      if (AppConfig.instance.security.enableDebugMode) {
        print("🔍 Texte extrait par OCR :\n$extractedText");
      }

      // Check if any text was found
      if (extractedText.trim().isEmpty) {
        return const Failure(
          DocumentExtractionFailure(
            message: 'No text found in the document image',
            code: 'NO_TEXT_FOUND',
          ),
        );
      }

      // Extract structured data
      final documentData = _extractDataFromText(extractedText);

      // Validate extracted data
      if (!documentData.isValid) {
        return const Failure(
          DocumentExtractionFailure(
            message: 'Could not extract required document fields',
            code: 'INSUFFICIENT_DATA',
          ),
        );
      }

      if (AppConfig.instance.security.enableDebugMode) {
        print("📤 Données extraites : ${documentData.toJson()}");
      }

      return Success(documentData);

    } catch (e, stackTrace) {
      // Log error in debug mode
      if (AppConfig.instance.security.enableLogging) {
        print("❌ Erreur OCR: $e");
        print("Stack trace: $stackTrace");
      }

      return Failure(
        DocumentExtractionFailure(
          message: 'Failed to process document: ${e.toString()}',
          code: 'PROCESSING_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Check if ML Kit is available on the device
      return true; // Google ML Kit is available on all Flutter platforms
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> getSupportedDocumentTypes() {
    return [
      'passport',
      'id_card',
      'driver_license',
      'national_id',
    ];
  }

  /// Extract structured data from raw text using pattern matching
  ///
  /// This method uses regular expressions and text patterns to identify
  /// and extract specific fields from identity documents.
  DocumentData _extractDataFromText(String text) {
    final lines = text.split('\n').map((line) => line.trim()).toList();

    String name = "";
    String surname = "";
    String idNumber = "";
    String nationality = "";
    DateTime? dateOfBirth;
    DateTime? expirationDate;
    String? documentType;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip empty lines
      if (line.isEmpty) continue;

      // Extract names
      name = name.isEmpty ? _extractName(lines, i) : name;
      surname = surname.isEmpty ? _extractSurname(lines, i) : surname;

      // Extract nationality
      nationality = nationality.isEmpty ? _extractNationality(lines, i) : nationality;

      // Extract ID number
      idNumber = idNumber.isEmpty ? _extractIdNumber(lines, i) : idNumber;

      // Extract dates
      dateOfBirth ??= _extractDateOfBirth(lines, i);
      expirationDate ??= _extractExpirationDate(lines, i);

      // Extract document type
      documentType ??= _extractDocumentType(lines, i);
    }

    return DocumentData(
      name: name,
      surname: surname,
      idNumber: idNumber,
      nationality: nationality,
      dateOfBirth: dateOfBirth,
      expirationDate: expirationDate,
      documentType: documentType,
    );
  }

  String _extractName(List<String> lines, int index) {
    final line = lines[index];

    // Look for name indicators with improved patterns
    final namePatterns = [
      RegExp(r'\b(NOMS?|FORENAMES?|GIVEN NAMES?|PRÉNOMS?|PRÉNOM)\b', caseSensitive: false),
      RegExp(r'\b(NAME|NOM|FIRST NAME)\b', caseSensitive: false),
      RegExp(r'\b(GIVEN|DONNÉ)\b', caseSensitive: false),
    ];

    for (final pattern in namePatterns) {
      if (pattern.hasMatch(line)) {
        // Check next line first
        if (index + 1 < lines.length && lines[index + 1].trim().isNotEmpty) {
          final nextLine = lines[index + 1].trim();
          // Filter out unwanted patterns
          if (!RegExp(r'^[A-Z]{2,3}$').hasMatch(nextLine) && // Skip country codes
              !RegExp(r'^\d+$').hasMatch(nextLine) && // Skip pure numbers
              nextLine.length > 1) {
            return nextLine;
          }
        }

        // Check same line after pattern
        final match = pattern.firstMatch(line);
        if (match != null) {
          final afterMatch = line.substring(match.end).trim();
          if (afterMatch.isNotEmpty && !RegExp(r'^\d+$').hasMatch(afterMatch)) {
            return afterMatch;
          }
        }
      }
    }

    return "";
  }

  String _extractSurname(List<String> lines, int index) {
    final line = lines[index];

    // Look for surname indicators
    final surnamePatterns = [
      RegExp(r'\b(SURNAMES?|FAMILY NAMES?|NOMS? DE FAMILLE)\b', caseSensitive: false),
      RegExp(r'\b(SURNAME|NOM DE FAMILLE)\b', caseSensitive: false),
    ];

    for (final pattern in surnamePatterns) {
      if (pattern.hasMatch(line) && index + 1 < lines.length) {
        return lines[index + 1].trim();
      }
    }

    // Sometimes names are on the same line after "NOMS"
    if (line.contains(RegExp(r'\b(NOMS|SURNAMES)\b', caseSensitive: false))) {
      if (index + 2 < lines.length) {
        return lines[index + 2].trim();
      }
    }

    return "";
  }

  String _extractNationality(List<String> lines, int index) {
    final line = lines[index];

    final nationalityPatterns = [
      RegExp(r'\b(NATIONALITÉ?|NATIONALITY|NAT\.?)\b', caseSensitive: false),
    ];

    for (final pattern in nationalityPatterns) {
      if (pattern.hasMatch(line) && index + 1 < lines.length) {
        return lines[index + 1].trim();
      }
    }

    return "";
  }

  String _extractIdNumber(List<String> lines, int index) {
    final line = lines[index];

    final idPatterns = [
      RegExp(r'\b(NUMÉRO PERSONNEL|PERSONAL NUMBER|ID NUMBER|DOCUMENT NUMBER)\b', caseSensitive: false),
      RegExp(r'\b(N°|NO\.?|NUM\.?)\s*(PASSEPORT|PASSPORT|ID|CARTE)\b', caseSensitive: false),
    ];

    for (final pattern in idPatterns) {
      if (pattern.hasMatch(line) && index + 1 < lines.length) {
        return lines[index + 1].trim();
      }
    }

    // Look for standalone ID numbers (alphanumeric patterns)
    final idNumberPattern = RegExp(r'\b[A-Z0-9]{6,12}\b');
    final match = idNumberPattern.firstMatch(line);
    if (match != null) {
      return match.group(0) ?? "";
    }

    return "";
  }

  DateTime? _extractDateOfBirth(List<String> lines, int index) {
    final line = lines[index];

    final dobPatterns = [
      RegExp(r'\b(DATE OF BIRTH|BORN|BIRTH|NAISSANCE|NÉ\.?E?)\b', caseSensitive: false),
    ];

    for (final pattern in dobPatterns) {
      if (pattern.hasMatch(line) && index + 1 < lines.length) {
        return _parseDate(lines[index + 1]);
      }
    }

    return null;
  }

  DateTime? _extractExpirationDate(List<String> lines, int index) {
    final line = lines[index];

    final expPatterns = [
      RegExp(r'\b(EXPIRY|EXPIRES?|EXPIRATION|VALID UNTIL|VALIDE JUSQU)\b', caseSensitive: false),
    ];

    for (final pattern in expPatterns) {
      if (pattern.hasMatch(line) && index + 1 < lines.length) {
        return _parseDate(lines[index + 1]);
      }
    }

    return null;
  }

  String? _extractDocumentType(List<String> lines, int index) {
    final line = lines[index].toLowerCase();

    if (line.contains('passport') || line.contains('passeport')) {
      return 'passport';
    } else if (line.contains('carte') && line.contains('identité')) {
      return 'id_card';
    } else if (line.contains('driver') || line.contains('permis')) {
      return 'driver_license';
    }

    return null;
  }

  DateTime? _parseDate(String dateStr) {
    // Common date formats in documents
    final dateFormats = [
      RegExp(r'(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})'), // DD/MM/YYYY or DD-MM-YYYY
      RegExp(r'(\d{4})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})'), // YYYY/MM/DD or YYYY-MM-DD
      RegExp(r'(\d{1,2})\s+(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\s+(\d{4})'), // DD MMM YYYY
    ];

    for (final format in dateFormats) {
      final match = format.firstMatch(dateStr.toUpperCase());
      if (match != null) {
        try {
          if (format == dateFormats[2]) {
            // Handle month name format
            final monthNames = {
              'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
              'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
            };
            final day = int.parse(match.group(1)!);
            final month = monthNames[match.group(2)!]!;
            final year = int.parse(match.group(3)!);
            return DateTime(year, month, day);
          } else {
            // Handle numeric formats
            final parts = [match.group(1)!, match.group(2)!, match.group(3)!];
            final nums = parts.map(int.parse).toList();

            // Determine format based on which number could be a year
            if (nums[2] > 1900) {
              return DateTime(nums[2], nums[1], nums[0]); // DD/MM/YYYY
            } else if (nums[0] > 1900) {
              return DateTime(nums[0], nums[1], nums[2]); // YYYY/MM/DD
            }
          }
        } catch (e) {
          // Continue to next format if parsing fails
        }
      }
    }

    return null;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}