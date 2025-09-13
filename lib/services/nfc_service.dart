import 'package:flutter/services.dart';
import 'dart:async';

import '../core/errors/nfc_failure.dart';
import '../core/types/result.dart';
import '../core/config/app_config.dart';
import 'interfaces/nfc_service.dart';
import 'models/nfc_write_result.dart';
import 'models/nfc_read_result.dart';

/// NFC service implementation using platform channels
class NfcService implements INfcService {
  static const _channel = MethodChannel('com.hospi_id_scan.nfc');

  @override
  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod('isAvailable') ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isEnabled() async {
    try {
      return await _channel.invokeMethod('isEnabled') ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<NfcWriteResult, NfcFailure>> writeToCard(
    String data, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      if (!await isAvailable()) {
        return const Failure(NfcFailure(
          message: 'NFC not available on this device',
          code: 'NFC_NOT_AVAILABLE',
        ));
      }

      final result = await _channel
          .invokeMethod('writeTag', {'text': data})
          .timeout(timeout);

      return Success(NfcWriteResult.success(
        message: result?.toString() ?? 'Write successful',
        dataSize: data.length,
      ));
    } on TimeoutException {
      return Failure(NfcFailure(message: 'NFC operation timed out', code: 'NFC_TIMEOUT'));
    } on PlatformException catch (e) {
      return Failure(NfcFailure(message: 'Write failed: ${e.message ?? 'Unknown error'}', code: 'NFC_WRITE_ERROR'));
    } catch (e) {
      return Failure(NfcFailure(message: 'Write failed: ${e.toString()}', code: 'NFC_WRITE_ERROR'));
    }
  }

  @override
  Future<Result<NfcReadResult, NfcFailure>> readFromCard({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      if (!await isAvailable()) {
        return const Failure(NfcFailure(
          message: 'NFC not available on this device',
          code: 'NFC_NOT_AVAILABLE',
        ));
      }

      final result = await _channel
          .invokeMethod('readTag')
          .timeout(timeout);

      final data = result?.toString() ?? '';
      if (data.isEmpty) {
        return Failure(NfcFailure(message: 'No data found on card', code: 'NO_DATA_FOUND'));
      }

      return Success(NfcReadResult.success(data: data));
    } on TimeoutException {
      return Failure(NfcFailure(message: 'NFC operation timed out', code: 'NFC_TIMEOUT'));
    } on PlatformException catch (e) {
      return Failure(NfcFailure(message: 'Read failed: ${e.message ?? 'Unknown error'}', code: 'NFC_READ_ERROR'));
    } catch (e) {
      return Failure(NfcFailure(message: 'Read failed: ${e.toString()}', code: 'NFC_READ_ERROR'));
    }
  }

  @override
  Future<void> stopSession() async {
    try {
      await _channel.invokeMethod('stopSession');
    } catch (e) {
      if (AppConfig.instance.security.enableLogging) {
        print('Error stopping NFC session: $e');
      }
    }
  }

  @override
  List<String> getSupportedCardTypes() {
    return ['NDEF', 'Mifare Classic', 'Mifare Ultralight'];
  }
}
