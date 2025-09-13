import 'base_failure.dart';

/// Failure related to document text extraction
class DocumentExtractionFailure extends Failure {
  const DocumentExtractionFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });

  factory DocumentExtractionFailure.processingError(
    String details, {
    StackTrace? stackTrace,
  }) {
    return DocumentExtractionFailure(
      message: 'Failed to process document: $details',
      code: 'DOCUMENT_PROCESSING_ERROR',
      stackTrace: stackTrace,
    );
  }

  factory DocumentExtractionFailure.noTextFound() {
    return const DocumentExtractionFailure(
      message: 'No readable text found in the document',
      code: 'NO_TEXT_FOUND',
    );
  }

  factory DocumentExtractionFailure.invalidFormat() {
    return const DocumentExtractionFailure(
      message: 'Document format is not supported',
      code: 'INVALID_FORMAT',
    );
  }

  factory DocumentExtractionFailure.serviceUnavailable() {
    return const DocumentExtractionFailure(
      message: 'Text recognition service is currently unavailable',
      code: 'SERVICE_UNAVAILABLE',
    );
  }
}