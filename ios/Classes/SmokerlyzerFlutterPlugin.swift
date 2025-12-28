import Flutter
import UIKit
import SmokerlyzerSDK

public class SmokerlyzerFlutterPlugin: NSObject, FlutterPlugin {
    private var eventSink: FlutterEventSink?
    private let smokerlyzerBluetooth = SmokerlyzerBluetooth()
    
    override init() {
        super.init()
        smokerlyzerBluetooth.register(connectionObserver: self)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SmokerlyzerFlutterPlugin()
        
        let channel = FlutterMethodChannel(name: "smokerlyzer_flutter", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "smokerlyzer_flutter/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task { @MainActor in
            switch call.method {
            case "scanAndConnect":
                let didStart = scanAndConnect()
                result(didStart)
                
            case "disconnect":
                disconnect()
                result(nil)
                
            case "getIsConnected":
                let isConnected = await getIsConnected()
                result(isConnected)
                
            case "startBreathTest":
                do {
                    let data = try await startBreathTest()
                    result(data)
                } catch {
                    result(FlutterError(code: "BREATH_TEST_ERROR", message: error.localizedDescription, details: nil))
                }
                
            case "handleRecovery":
                do {
                    try await handleRecovery()
                    result(nil)
                } catch {
                    result(FlutterError(code: "RECOVERY_ERROR", message: error.localizedDescription, details: nil))
                }
                
            case "startBreathTestNoRecovery":
                do {
                    let data = try await startBreathTestNoRecovery()
                    result(data)
                } catch {
                    result(FlutterError(code: "BREATH_TEST_ERROR", message: error.localizedDescription, details: nil))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - SDK Methods
    
    private func scanAndConnect() -> Bool {
        return smokerlyzerBluetooth.scanAndConnect { [weak self] update in
            self?.handleConnectionUpdate(update: update)
        }
    }
    
    private func disconnect() {
        smokerlyzerBluetooth.disconnect()
    }
    
    private func getIsConnected() async -> Bool {
        return await withCheckedContinuation { continuation in
            smokerlyzerBluetooth.getIsConnected { isConnected in
                continuation.resume(returning: isConnected)
            }
        }
    }
    
    private func startBreathTest() async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            smokerlyzerBluetooth.startBreathTest { [weak self] result in
                guard self != nil else { return }
                switch result {
                case .success(let ppmResult):
                    // Note: PPMResult only has 'latest' and 'state' - no 'max' property
                    // Using 'latest' as both values since SDK doesn't track max
                    let data: [String: Any] = [
                        "status": "success",
                        "data": [
                            "latest": ppmResult.latest,
                            "max": ppmResult.latest,
                            "state": String(reflecting: ppmResult.state)
                        ]
                    ]
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                @unknown default:
                    continuation.resume(throwing: NSError(domain: "SmokerlyzerSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
    
    private func handleRecovery() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            smokerlyzerBluetooth.handleRecovery { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                @unknown default:
                    continuation.resume(throwing: NSError(domain: "SmokerlyzerSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
    
    private func startBreathTestNoRecovery() async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            smokerlyzerBluetooth.startBreathTestNoRecovery { [weak self] result in
                guard self != nil else { return }
                switch result {
                case .success(let ppmResult):
                    // Note: PPMResult only has 'latest' and 'state' - no 'max' property
                    // Using 'latest' as both values since SDK doesn't track max
                    let data: [String: Any] = [
                        "status": "success",
                        "data": [
                            "latest": ppmResult.latest,
                            "max": ppmResult.latest,
                            "state": String(reflecting: ppmResult.state)
                        ]
                    ]
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                @unknown default:
                    continuation.resume(throwing: NSError(domain: "SmokerlyzerSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
    
    // MARK: - Connection Update Handler
    
    private func handleConnectionUpdate(update: ConnectionUpdate) {
        var eventData: [String: Any] = [:]
        
        switch update {
        case .success(let peripheralId):
            eventData["type"] = "SUCCESS"
            eventData["data"] = ["name": peripheralId.name, "uuid": peripheralId.uuid.uuidString]
        case .successNeedsRecovery(let peripheralId):
            eventData["type"] = "SUCCESS_NEEDS_RECOVERY"
            eventData["data"] = ["name": peripheralId.name, "uuid": peripheralId.uuid.uuidString]
        case .zeroing:
            eventData["type"] = "ZEROING"
        case .failure(let error):
            eventData["type"] = "FAILURE"
            eventData["error"] = error.localizedDescription
        @unknown default:
            eventData["type"] = "UNKNOWN"
        }
        
        eventSink?(eventData)
    }
}

// MARK: - FlutterStreamHandler

extension SmokerlyzerFlutterPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: - ConnectionObserver

extension SmokerlyzerFlutterPlugin: ConnectionObserver {
    public func bluetoothAvailable(_ available: Bool) {
        let eventData: [String: Any] = [
            "type": "CONNECTION_BLUETOOTH_AVAILABLE",
            "data": ["available": available]
        ]
        eventSink?(eventData)
    }
    
    public func connected(to peripheral: PeripheralIdentifier) {
        let eventData: [String: Any] = [
            "type": "CONNECTION_CONNECTED",
            "data": ["name": peripheral.name, "uuid": peripheral.uuid.uuidString]
        ]
        eventSink?(eventData)
    }
    
    public func disconnected(from peripheral: PeripheralIdentifier) {
        let eventData: [String: Any] = [
            "type": "CONNECTION_DISCONNECTED",
            "data": ["name": peripheral.name, "uuid": peripheral.uuid.uuidString]
        ]
        eventSink?(eventData)
    }
}
