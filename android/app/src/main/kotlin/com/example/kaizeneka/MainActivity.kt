package com.example.kaizeneka

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kaizeneka.nk/widget"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Manejar intents desde el widget
        handleIntent(intent)

        // Configurar MethodChannel para comunicación con Flutter
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "getWidgetTab" -> {
                        val tabIndex = intent.getIntExtra("open_tab", -1)
                        result.success(tabIndex)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        val tabIndex = intent.getIntExtra("open_tab", -1)
        if (tabIndex != -1) {
            // Guardar el índice del tab para que Flutter lo lea
            intent.putExtra("open_tab", tabIndex)
        }
    }
}
