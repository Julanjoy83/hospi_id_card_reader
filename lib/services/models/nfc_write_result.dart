/// Result of an NFC write operation
class NfcWriteResult {
  const NfcWriteResult({
    required this.success,
    required this.message,
    this.cardId,
    this.dataSize,
  });

  final bool success;
  final String message;
  final String? cardId;
  final int? dataSize;

  factory NfcWriteResult.success({
    required String message,
    String? cardId,
    int? dataSize,
  }) {
    return NfcWriteResult(
      success: true,
      message: message,
      cardId: cardId,
      dataSize: dataSize,
    );
  }

  factory NfcWriteResult.failure(String message) {
    return NfcWriteResult(
      success: false,
      message: message,
    );
  }

  @override
  String toString() => 'NfcWriteResult(success: $success, message: $message, cardId: $cardId)';
}