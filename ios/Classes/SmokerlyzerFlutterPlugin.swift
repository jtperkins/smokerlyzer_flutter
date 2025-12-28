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
                print("[SMOKERLYZER_SWIFT] handleRecovery method called from Flutter")
                do {
                    try await handleRecovery()
                    print("[SMOKERLYZER_SWIFT] handleRecovery completed successfully")
                    result(nil)
                } catch {
                    print("[SMOKERLYZER_SWIFT] handleRecovery error: \(error)")
                    result(FlutterError(code: "RECOVERY_ERROR", message: error.localizedDescription, details: nil))
                }
                
            case "startBreathTestNoRecovery":
                print("[SMOKERLYZER_SWIFT] startBreathTestNoRecovery called")
                do {
                    let data = try await startBreathTestNoRecovery()
                    print("[SMOKERLYZER_SWIFT] startBreathTestNoRecovery succeeded: \(data)")
                    result(data)
                } catch {
                    print("[SMOKERLYZER_SWIFT] startBreathTestNoRecovery error: \(error)")
                    result(FlutterError(code: "BREATH_TEST_ERROR", message: error.localizedDescription, details: nil))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - SDK Methods
    
    @MainActor
    private func scanAndConnect() -> Bool {
        return smokerlyzerBluetooth.scanAndConnect { [weak self] update in
            self?.handleConnectionUpdate(update: update)
        }
    }
    
    @MainActor
    private func disconnect() {
        smokerlyzerBluetooth.disconnect()
    }
    
    @MainActor
    private func getIsConnected() async -> Bool {
        return await withCheckedContinuation { continuation in
            smokerlyzerBluetooth.getIsConnected { isConnected in
                continuation.resume(returning: isConnected)
            }
        }
    }
    
    @MainActor
    private func startBreathTest() async throws -> [String: Any] {
        print("[SMOKERLYZER_SWIFT] startBreathTest: entering, isMainThread=\(Thread.isMainThread)")
        return try await withCheckedThrowingContinuation { continuation in
            // SDK requires main thread - ensure we're on it
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "SmokerlyzerSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Plugin deallocated"]))
                    return
                }
                print("[SMOKERLYZER_SWIFT] startBreathTest: calling SDK on main thread=\(Thread.isMainThread)")
                self.smokerlyzerBluetooth.startBreathTest { result in
                    print("[SMOKERLYZER_SWIFT] startBreathTest: SDK callback received")
                    switch result {
                    case .success(let ppmResult):
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
    }
    
    @MainActor
    private func handleRecovery() async throws {
        print("[SMOKERLYZER_SWIFT] handleRecovery: entering, isMainThread=\(Thread.isMainThread)")
        return try await withCheckedThrowingContinuation { continuation in
            // SDK requires main thread - ensure we're on it
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "SmokerlyzerSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Plugin deallocated"]))
                    return
                }
                print("[SMOKERLYZER_SWIFT] handleRecovery: calling SDK on main thread=\(Thread.isMainThread)")
                self.smokerlyzerBluetooth.handleRecovery { result in
                    print("[SMOKERLYZER_SWIFT] handleRecovery: SDK callback received")
                    switch result {
                    case .success:
                        print("[SMOKERLYZER_SWIFT] handleRecovery: SUCCESS")
                        continuation.resume()
                    case .failure(let error):
                        print("[SMOKERLYZER_SWIFT] handleRecovery: FAILURE - \(error)")
                        continuation.resume(throwing: error)
                    @unknown default:
                        continuation.resume(throwing: NSError(domain: "SmokerlyzerSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                    }
                }
            }
        }
    }
    
    @MainActor
    private func startBreathTestNoRecovery() async throws -> [String: Any] {
        print("[SMOKERLYZER_SWIFT] startBreathTestNoRecovery: entering, isMainThread=\(Thread.isMainThread)")
        return try await withCheckedThrowingContinuation { continuation in
            // SDK requires main thread - ensure we're on it
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "SmokerlyzerSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Plugin deallocated"]))
                    return
                }
                print("[SMOKERLYZER_SWIFT] startBreathTestNoRecovery: calling SDK on main thread=\(Thread.isMainThread)")
                self.smokerlyzerBluetooth.startBreathTestNoRecovery { result in
                    print("[SMOKERLYZER_SWIFT] startBreathTestNoRecovery: SDK callback received")
                    switch result {
                    case .success(let ppmResult):
                        print("[SMOKERLYZER_SWIFT] startBreathTestNoRecovery: success with ppm=\(ppmResult.latest)")
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
    }
    
    // MARK: - Connection Update Handler
    
    private func handleConnectionUpdate(update: ConnectionUpdate) {
        var eventData: [String: Any] = [:]
        
        switch update {
        case .success(let peripheralId):
            print("[SMOKERLYZER_SWIFT] ConnectionUpdate: SUCCESS - \(peripheralId.name)")
            eventData["type"] = "SUCCESS"
            eventData["data"] = ["name": peripheralId.name, "uuid": peripheralId.uuid.uuidString]
        case .successNeedsRecovery(let peripheralId):
            print("[SMOKERLYZER_SWIFT] ConnectionUpdate: SUCCESS_NEEDS_RECOVERY - \(peripheralId.name)")
            eventData["type"] = "SUCCESS_NEEDS_RECOVERY"
            eventData["data"] = ["name": peripheralId.name, "uuid": peripheralId.uuid.uuidString]
        case .zeroing:
            print("[SMOKERLYZER_SWIFT] ConnectionUpdate: ZEROING")
            eventData["type"] = "ZEROING"
        case .failure(let error):
            print("[SMOKERLYZER_SWIFT] ConnectionUpdate: FAILURE - \(error)")
            eventData["type"] = "FAILURE"
            eventData["error"] = error.localizedDescription
        @unknown default:
            print("[SMOKERLYZER_SWIFT] ConnectionUpdate: UNKNOWN")
            eventData["type"] = "UNKNOWN"
        }
        
        print("[SMOKERLYZER_SWIFT] Sending event to Flutter: \(eventData)")
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
