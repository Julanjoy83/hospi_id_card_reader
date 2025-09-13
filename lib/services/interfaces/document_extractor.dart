import 'dart:io';
import '../../core/errors/document_extraction_failure.dart';
import '../../core/types/result.dart';
import '../models/document_data.dart';

/// Abstract interface for document text extraction services
///
/// This interface defines the contract for extracting structured data from identity documents.
/// Implementations can use different OCR services (Google ML Kit, AWS Textract, etc.)
abstract interface class IDocumentExtractor {
  /// Extract structured data from an image file
  ///
  /// [imageFile] - The image file containing the document to extract data from
  /// Returns a [Result] containing [DocumentData] on success or [DocumentExtractionFailure] on failure
  Future<Result<DocumentData, DocumentExtractionFailure>> extractData(File imageFile);

  /// Check if the service is available and properly configured
  Future<bool> isAvailable();

  /// Get supported document types (passport, id card, driver's license, etc.)
  List<String> getSupportedDocumentTypes();
}