package com.hospi_id_scan.hospi_id_scanner

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "com.hospi_id_scan.nfc"
        const val REQ_NFC = 1001
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readTag" -> {
                        pendingResult = result
                        startNfcActivity(mode = "read", text = null)
                    }
                    "writeTag" -> {
                        val text = call.argument<String>("text") ?: ""
                        pendingResult = result
                        startNfcActivity(mode = "write", text = text)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startNfcActivity(mode: String, text: String?) {
        Intent(this, NfcActivity::class.java).apply {
            putExtra("mode", mode)
            text?.let { putExtra("text", it) }
            startActivityForResult(this, REQ_NFC)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQ_NFC) {
            val payload = data?.getStringExtra("nfc_result") ?: ""
            if (resultCode == Activity.RESULT_OK) {
                pendingResult?.success(payload)
            } else {
                pendingResult?.error("NFC_ERROR", payload, null)
            }
            pendingResult = null
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}