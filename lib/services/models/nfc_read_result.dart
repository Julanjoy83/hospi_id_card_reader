/// Result of an NFC read operation
class NfcReadResult {
  const NfcReadResult({
    required this.success,
    required this.message,
    this.data,
    this.cardId,
  });

  final bool success;
  final String message;
  final String? data;
  final String? cardId;

  factory NfcReadResult.success({
    required String data,
    String? message,
    String? cardId,
  }) {
    return NfcReadResult(
      success: true,
      message: message ?? 'NFC read successful',
      data: data,
      cardId: cardId,
    );
  }

  factory NfcReadResult.failure(String message) {
    return NfcReadResult(
      success: false,
      message: message,
    );
  }

  @override
  String toString() => 'NfcReadResult(success: $success, message: $message, hasData: ${data != null})';
}