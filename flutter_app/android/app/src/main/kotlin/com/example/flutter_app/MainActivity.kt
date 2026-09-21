package com.example.flutter_app

import android.os.Bundle
import java.io.File

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "thserver/native"
        const val ENGINE_BINARY = "librust_egine.so"
    }

    private var engineProcess: Process? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            android.util.Log.d(
                "ThServerNative",
                "MethodChannel call: ${call.method}"
            )

            when (call.method) {
                "startServer" -> {
                    startServer(result)
                }

                "stopServer" -> {
                    stopServer(result)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startServer(
    result: MethodChannel.Result
) {
    android.util.Log.d(
        "ThServerNative",
        "startServer() CALLED"
    )

    if (engineProcess?.isAlive == true) {
        android.util.Log.d(
            "ThServerNative",
            "Rust process already alive"
        )

        result.success(true)
        return
    }

    Thread {
        try {
            val binary = File(
                applicationInfo.nativeLibraryDir,
                ENGINE_BINARY
            )

            android.util.Log.d(
                "ThServerNative",
                "Engine binary: ${binary.absolutePath}"
            )

            if (!binary.exists()) {
                throw Exception(
                    "Engine binary not found: ${binary.absolutePath}"
                )
            }

            val databaseDir = File(
                filesDir,
                "data"
            )

            if (!databaseDir.exists()) {
                databaseDir.mkdirs()
            }

            val databasePath = File(
                databaseDir,
                "thserver.db"
            )

            android.util.Log.d(
                "ThServerNative",
                "Database path: ${databasePath.absolutePath}"
            )

            val process = ProcessBuilder(
                binary.absolutePath
            )
                .apply {
                    environment()["THSERVER_DB_PATH"] =
                        databasePath.absolutePath
                }
                .redirectErrorStream(true)
                .start()

            engineProcess = process

            android.util.Log.d(
                "ThServerNative",
                "Rust process alive=${process.isAlive}"
            )

            Thread {
                try {
                    process.inputStream
                        .bufferedReader()
                        .forEachLine { line ->
                            android.util.Log.d(
                                "ThServerRust",
                                line
                            )
                        }
                } catch (error: Exception) {
                    android.util.Log.d(
                        "ThServerNative",
                        "Rust log reader stopped: ${error.message}"
                    )
                }
            }.start()

            runOnUiThread {
                android.util.Log.d(
                    "ThServerNative",
                    "Calling result.success(true)"
                )

                result.success(true)

                android.util.Log.d(
                    "ThServerNative",
                    "result.success(true) returned"
                )
            }

        } catch (error: Exception) {
            android.util.Log.e(
                "ThServerNative",
                "START_FAILED: ${error.message}",
                error
            )

            runOnUiThread {
                result.error(
                    "START_FAILED",
                    error.message,
                    null
                )
            }
        }
    }.start()
    }

    private fun stopServer(
        result: MethodChannel.Result
    ) {
        android.util.Log.d(
            "ThServerNative",
            "stopServer() CALLED"
        )

        val process = engineProcess

        if (process == null || !process.isAlive) {
            engineProcess = null

            result.success(true)

            android.util.Log.d(
                "ThServerNative",
                "No Rust process running"
            )

            return
        }

        process.destroy()

        engineProcess = null

        result.success(true)

        android.util.Log.d(
            "ThServerNative",
            "Rust process stopped"
        )
    }

    override fun onDestroy() {
        engineProcess?.destroy()
        engineProcess = null

        super.onDestroy()
    }
}