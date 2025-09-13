import 'base_failure.dart';

/// Failure related to NFC operations
class NfcFailure extends Failure {
  const NfcFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });

  factory NfcFailure.notSupported() {
    return const NfcFailure(
      message: 'NFC is not supported on this device',
      code: 'NFC_NOT_SUPPORTED',
    );
  }

  factory NfcFailure.disabled() {
    return const NfcFailure(
      message: 'NFC is disabled. Please enable it in device settings',
      code: 'NFC_DISABLED',
    );
  }

  factory NfcFailure.writeError(String details) {
    return NfcFailure(
      message: 'Failed to write to NFC card: $details',
      code: 'NFC_WRITE_ERROR',
    );
  }

  factory NfcFailure.readError(String details) {
    return NfcFailure(
      message: 'Failed to read from NFC card: $details',
      code: 'NFC_READ_ERROR',
    );
  }

  factory NfcFailure.timeout() {
    return const NfcFailure(
      message: 'NFC operation timed out. Please try again',
      code: 'NFC_TIMEOUT',
    );
  }

  factory NfcFailure.cardNotFound() {
    return const NfcFailure(
      message: 'No NFC card detected. Please place the card near the reader',
      code: 'NFC_CARD_NOT_FOUND',
    );
  }
}