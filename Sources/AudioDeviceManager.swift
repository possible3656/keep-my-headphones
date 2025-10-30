import Foundation
import CoreAudio

/// Represents an audio device with its properties
struct AudioDevice: Codable, Equatable {
    let id: AudioDeviceID
    let name: String
    let uid: String
    let isExternal: Bool
    
    static func == (lhs: AudioDevice, rhs: AudioDevice) -> Bool {
        return lhs.uid == rhs.uid
    }
}

/// Manages audio device detection, switching, and state persistence
class AudioDeviceManager {
    
    private let logger = Logger.shared
    private let stateFilePath: String
    
    init() {
        // Store state in user's Library/Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let serviceDir = appSupport.appendingPathComponent("KeepMyHeadphones")
        try? FileManager.default.createDirectory(at: serviceDir, withIntermediateDirectories: true)
        stateFilePath = serviceDir.appendingPathComponent("device_state.json").path
    }
    
    // MARK: - Device Detection
    
    /// Get the current default output audio device
    func getCurrentOutputDevice() -> AudioDevice? {
        var deviceID = AudioDeviceID()
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )
        
        guard status == noErr else {
            logger.log("Failed to get current output device: \(status)")
            return nil
        }
        
        return getDeviceInfo(deviceID: deviceID)
    }
    
    /// Get all available output audio devices
    func getAllOutputDevices() -> [AudioDevice] {
        var propertySize: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        // Get size
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize
        )
        
        guard status == noErr else {
            logger.log("Failed to get device list size: \(status)")
            return []
        }
        
        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        // Get devices
        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceIDs
        )
        
        guard status == noErr else {
            logger.log("Failed to get device list: \(status)")
            return []
        }
        
        return deviceIDs.compactMap { deviceID in
            guard let device = getDeviceInfo(deviceID: deviceID),
                  hasOutputStreams(deviceID: deviceID) else {
                return nil
            }
            return device
        }
    }
    
    /// Get detailed information about a specific device
    private func getDeviceInfo(deviceID: AudioDeviceID) -> AudioDevice? {
        guard let name = getDeviceName(deviceID: deviceID),
              let uid = getDeviceUID(deviceID: deviceID) else {
            return nil
        }
        
        let isExternal = !isBuiltInDevice(deviceID: deviceID)
        
        return AudioDevice(id: deviceID, name: name, uid: uid, isExternal: isExternal)
    }
    
    private func getDeviceName(deviceID: AudioDeviceID) -> String? {
        var propertySize: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize
        )

        guard status == noErr else { return nil }

        var name: Unmanaged<CFString>?
        status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &name
        )

        guard status == noErr, let cfString = name?.takeUnretainedValue() else { return nil }
        return cfString as String
    }
    
    private func getDeviceUID(deviceID: AudioDeviceID) -> String? {
        var propertySize: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize
        )

        guard status == noErr else { return nil }

        var uid: Unmanaged<CFString>?
        status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &uid
        )

        guard status == noErr, let cfString = uid?.takeUnretainedValue() else { return nil }
        return cfString as String
    }
    
    private func hasOutputStreams(deviceID: AudioDeviceID) -> Bool {
        var propertySize: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize
        )
        
        return status == noErr && propertySize > 0
    }
    
    private func isBuiltInDevice(deviceID: AudioDeviceID) -> Bool {
        // Get device name for additional checks
        guard let deviceName = getDeviceName(deviceID: deviceID) else {
            return false
        }

        let nameLower = deviceName.lowercased()

        // Check if the name explicitly indicates external headphones
        if nameLower.contains("external headphones") ||
           nameLower.contains("headphones") && !nameLower.contains("built-in") {
            logger.log("Device '\(deviceName)' identified as external based on name")
            return false
        }

        // Check if it's explicitly built-in speakers
        if nameLower.contains("built-in") ||
           (nameLower.contains("speaker") && !nameLower.contains("external")) {
            logger.log("Device '\(deviceName)' identified as built-in based on name")
            return true
        }

        // Check transport type
        var transportType: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyTransportType,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &transportType
        )

        guard status == noErr else { return false }

        // Log transport type for debugging
        let transportName = getTransportTypeName(transportType)
        logger.log("Device '\(deviceName)' transport type: \(transportName) (0x\(String(transportType, radix: 16)))")

        // USB, Bluetooth, AirPlay, etc. are definitely external
        if transportType == kAudioDeviceTransportTypeUSB ||
           transportType == kAudioDeviceTransportTypeBluetooth ||
           transportType == kAudioDeviceTransportTypeBluetoothLE ||
           transportType == kAudioDeviceTransportTypeAirPlay ||
           transportType == kAudioDeviceTransportTypeVirtual ||
           transportType == kAudioDeviceTransportTypeThunderbolt ||
           transportType == kAudioDeviceTransportTypeDisplayPort ||
           transportType == kAudioDeviceTransportTypeHDMI {
            return false
        }

        // For built-in transport type, check the data source to distinguish
        // between built-in speakers and headphone jack
        if transportType == kAudioDeviceTransportTypeBuiltIn {
            if let dataSource = getDataSourceName(deviceID: deviceID) {
                logger.log("Device '\(deviceName)' data source: \(dataSource)")
                let dataSourceLower = dataSource.lowercased()

                // Headphone jack is external even though transport is built-in
                if dataSourceLower.contains("headphone") ||
                   dataSourceLower.contains("external") ||
                   dataSourceLower.contains("line out") {
                    return false
                }
            }

            // If we can't determine from data source, use the name
            // Built-in speakers typically have "speaker" in the name
            return nameLower.contains("speaker")
        }

        // Default to built-in for unknown transport types
        return true
    }

    private func getTransportTypeName(_ transportType: UInt32) -> String {
        switch transportType {
        case kAudioDeviceTransportTypeBuiltIn:
            return "Built-In"
        case kAudioDeviceTransportTypeUSB:
            return "USB"
        case kAudioDeviceTransportTypeBluetooth:
            return "Bluetooth"
        case kAudioDeviceTransportTypeBluetoothLE:
            return "Bluetooth LE"
        case kAudioDeviceTransportTypeAirPlay:
            return "AirPlay"
        case kAudioDeviceTransportTypeVirtual:
            return "Virtual"
        case kAudioDeviceTransportTypeThunderbolt:
            return "Thunderbolt"
        case kAudioDeviceTransportTypeDisplayPort:
            return "DisplayPort"
        case kAudioDeviceTransportTypeHDMI:
            return "HDMI"
        default:
            return "Unknown"
        }
    }

    private func getDataSourceName(deviceID: AudioDeviceID) -> String? {
        var dataSource: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDataSource,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &dataSource
        )

        guard status == noErr else { return nil }

        // Try to get a string representation of the data source
        // For simplicity, we'll just return the numeric value as a string
        // In practice, common values are:
        // - 'ispk' (internal speaker)
        // - 'hdpn' (headphone)
        // - 'lineout' (line out)
        let dataSourceString = String(format: "%c%c%c%c",
                                     (dataSource >> 24) & 0xFF,
                                     (dataSource >> 16) & 0xFF,
                                     (dataSource >> 8) & 0xFF,
                                     dataSource & 0xFF)

        return dataSourceString
    }
    
    // MARK: - Device Switching
    
    /// Set the default output audio device
    func setOutputDevice(_ device: AudioDevice) -> Bool {
        var deviceID = device.id
        let propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            propertySize,
            &deviceID
        )
        
        if status == noErr {
            logger.log("Successfully switched to device: \(device.name)")
            return true
        } else {
            logger.log("Failed to switch to device: \(device.name), error: \(status)")
            return false
        }
    }
    
    /// Find the built-in speakers device
    func getBuiltInSpeakers() -> AudioDevice? {
        return getAllOutputDevices().first { device in
            !device.isExternal && device.name.lowercased().contains("speaker")
        }
    }
    
    /// Find a device by its UID
    func findDeviceByUID(_ uid: String) -> AudioDevice? {
        return getAllOutputDevices().first { $0.uid == uid }
    }
    
    // MARK: - State Persistence
    
    /// Save the current external headphone device
    func saveExternalDevice(_ device: AudioDevice) {
        do {
            let data = try JSONEncoder().encode(device)
            try data.write(to: URL(fileURLWithPath: stateFilePath))
            logger.log("Saved external device: \(device.name)")
        } catch {
            logger.log("Failed to save device state: \(error)")
        }
    }
    
    /// Load the previously saved external headphone device
    func loadSavedExternalDevice() -> AudioDevice? {
        guard FileManager.default.fileExists(atPath: stateFilePath) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: stateFilePath))
            let device = try JSONDecoder().decode(AudioDevice.self, from: data)
            logger.log("Loaded saved device: \(device.name)")
            return device
        } catch {
            logger.log("Failed to load device state: \(error)")
            return nil
        }
    }
    
    /// Clear the saved device state
    func clearSavedDevice() {
        try? FileManager.default.removeItem(atPath: stateFilePath)
        logger.log("Cleared saved device state")
    }
}

