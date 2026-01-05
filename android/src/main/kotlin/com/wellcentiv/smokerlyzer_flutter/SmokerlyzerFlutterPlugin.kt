package com.wellcentiv.smokerlyzer_flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.bedfont.icosdk.ble.v2.SmokerlyzerBluetoothLeManager
import com.bedfont.icosdk.ble.v2.SmokerlyzerBluetoothLeManager.ConnectCodeConstants

class SmokerlyzerFlutterPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var _smokerlyzerManager: SmokerlyzerBluetoothLeManager? = null
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * Lazily initialized Bluetooth manager - only created when first accessed.
     * This prevents Bluetooth permission prompt on app startup.
     */
    private val smokerlyzerManager: SmokerlyzerBluetoothLeManager
        get() {
            if (_smokerlyzerManager == null) {
                _smokerlyzerManager = SmokerlyzerBluetoothLeManager.build(context)
            }
            return _smokerlyzerManager!!
        }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        // Note: smokerlyzerManager is now lazily initialized
        // It will be created on first use (e.g., scanAndConnect)

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "smokerlyzer_flutter")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "smokerlyzer_flutter/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "scanAndConnect" -> scanAndConnect(result)
            "disconnect" -> disconnect(result)
            "getIsConnected" -> getIsConnected(result)
            "startBreathTest" -> startBreathTest(result)
            "handleRecovery" -> handleRecovery(result)
            "startBreathTestNoRecovery" -> startBreathTestNoRecovery(result)
            else -> result.notImplemented()
        }
    }

    private fun scanAndConnect(result: Result) {
        smokerlyzerManager.scanAndConnect(arrayOf("Compact", "iCOquit")) { update ->
            handleConnectionUpdate(update)
        }
        result.success(true)
    }

    private fun disconnect(result: Result) {
        smokerlyzerManager.disconnect()
        result.success(null)
    }

    private fun getIsConnected(result: Result) {
        smokerlyzerManager.getIsConnected { isConnected ->
            mainHandler.post {
                result.success(isConnected)
            }
        }
    }

    private fun startBreathTest(result: Result) {
        smokerlyzerManager.getIsConnected { isConnected ->
            if (isConnected) {
                smokerlyzerManager.startBreathTest { isSuccessful, ppm, status ->
                    mainHandler.post {
                        val data = hashMapOf<String, Any>(
                            "status" to if (isSuccessful) "success" else "failure",
                            "data" to hashMapOf(
                                "latest" to ppm,
                                "max" to ppm,
                                "state" to status.toString()
                            )
                        )
                        result.success(data)
                    }
                }
            } else {
                mainHandler.post {
                    result.error("NOT_CONNECTED", "Not connected to a device", null)
                }
            }
        }
    }

    private fun handleRecovery(result: Result) {
        smokerlyzerManager.getIsConnected { isConnected ->
            if (isConnected) {
                smokerlyzerManager.handleRecovery { isComplete, _, _ ->
                    mainHandler.post {
                        if (isComplete) {
                            result.success(null)
                        } else {
                            result.error("RECOVERY_FAILED", "Recovery failed", null)
                        }
                    }
                }
            } else {
                mainHandler.post {
                    result.error("NOT_CONNECTED", "Not connected to a device", null)
                }
            }
        }
    }

    private fun startBreathTestNoRecovery(result: Result) {
        smokerlyzerManager.getIsConnected { isConnected ->
            if (isConnected) {
                smokerlyzerManager.startBreathTestNoRecovery { isSuccessful, ppm, status ->
                    mainHandler.post {
                        val data = hashMapOf<String, Any>(
                            "status" to if (isSuccessful) "success" else "failure",
                            "data" to hashMapOf(
                                "latest" to ppm,
                                "max" to ppm,
                                "state" to status.toString()
                            )
                        )
                        result.success(data)
                    }
                }
            } else {
                mainHandler.post {
                    result.error("NOT_CONNECTED", "Not connected to a device", null)
                }
            }
        }
    }

    private fun handleConnectionUpdate(update: ConnectCodeConstants) {
        val eventData = when (update) {
            ConnectCodeConstants.SUCCESS -> hashMapOf(
                "type" to "SUCCESS",
                "data" to hashMapOf("message" to "Connected successfully")
            )
            ConnectCodeConstants.SUCCESS_NEEDS_RECOVERY -> hashMapOf(
                "type" to "SUCCESS_NEEDS_RECOVERY",
                "data" to hashMapOf("message" to "Connected, recovery needed")
            )
            ConnectCodeConstants.ZEROING -> hashMapOf(
                "type" to "ZEROING",
                "data" to hashMapOf("message" to "Zeroing sensor")
            )
            ConnectCodeConstants.ERROR_FAILED_TO_FINALIZE -> hashMapOf(
                "type" to "FAILURE",
                "error" to "Failed to finalize connection"
            )
            ConnectCodeConstants.ERROR_FAILED_TO_CONNECT -> hashMapOf(
                "type" to "FAILURE",
                "error" to "Failed to connect"
            )
            ConnectCodeConstants.ERROR_SCAN_FAILED -> hashMapOf(
                "type" to "FAILURE",
                "error" to "Scan failed"
            )
            else -> hashMapOf(
                "type" to "UNKNOWN",
                "error" to "Unknown status"
            )
        }

        mainHandler.post {
            eventSink?.success(eventData)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    // EventChannel.StreamHandler
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
