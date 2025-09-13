import '../../core/errors/nfc_failure.dart';
import '../../core/types/result.dart';
import '../models/nfc_write_result.dart';
import '../models/nfc_read_result.dart';

/// Abstract interface for NFC operations
///
/// This interface defines the contract for reading from and writing to NFC cards.
/// Implementations can use different NFC libraries or hardware interfaces.
abstract interface class INfcService {
  /// Check if NFC is available on the device
  Future<bool> isAvailable();

  /// Check if NFC is enabled on the device
  Future<bool> isEnabled();

  /// Write data to an NFC card
  ///
  /// [data] - The string data to write to the card
  /// [timeout] - Optional timeout for the operation
  /// Returns a [Result] with [NfcWriteResult] on success or [NfcFailure] on failure
  Future<Result<NfcWriteResult, NfcFailure>> writeToCard(
    String data, {
    Duration timeout = const Duration(seconds: 30),
  });

  /// Read data from an NFC card
  ///
  /// [timeout] - Optional timeout for the operation
  /// Returns a [Result] with [NfcReadResult] on success or [NfcFailure] on failure
  Future<Result<NfcReadResult, NfcFailure>> readFromCard({
    Duration timeout = const Duration(seconds: 15),
  });

  /// Stop any ongoing NFC session
  Future<void> stopSession();

  /// Get NFC card types supported by this implementation
  List<String> getSupportedCardTypes();
}