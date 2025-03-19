import 'package:nfc_manager/nfc_manager.dart';

class NFCService {
  Future<String> scanNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      return "NFC non disponible sur cet appareil.";
    }

    String nfcData = "";
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        nfcData = "Données NFC : ${tag.data}";
        await NfcManager.instance.stopSession();
      },
    );
    return nfcData;
  }
}
