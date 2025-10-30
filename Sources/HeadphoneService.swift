import Foundation

/// Main service that coordinates audio device switching based on power events
class HeadphoneService {
    
    private let audioManager = AudioDeviceManager()
    private let powerMonitor = PowerEventMonitor()
    private let logger = Logger.shared
    
    private var isRunning = false
    
    init() {
        setupPowerEventHandlers()
    }
    
    /// Start the service
    func start() {
        guard !isRunning else {
            logger.log("Service is already running")
            return
        }
        
        logger.log("=== Headphone Issue Service Starting ===")
        logger.log("Service version: 1.0.0")
        
        // Log current audio device
        if let currentDevice = audioManager.getCurrentOutputDevice() {
            logger.log("Current output device: \(currentDevice.name) (External: \(currentDevice.isExternal))")
        }
        
        // Start monitoring power events
        powerMonitor.startMonitoring()
        isRunning = true
        
        logger.log("Service started successfully")
    }
    
    /// Stop the service
    func stop() {
        guard isRunning else { return }
        
        logger.log("=== Headphone Issue Service Stopping ===")
        powerMonitor.stopMonitoring()
        isRunning = false
        logger.log("Service stopped")
    }
    
    /// Setup handlers for power events
    private func setupPowerEventHandlers() {
        // Handle system will sleep
        powerMonitor.onSystemWillSleep = { [weak self] in
            self?.handleSystemWillSleep()
        }
        
        // Handle system did wake
        powerMonitor.onSystemDidWake = { [weak self] in
            self?.handleSystemDidWake()
        }
    }
    
    /// Handle system going to sleep
    private func handleSystemWillSleep() {
        logger.log("--- Handling System Sleep ---")
        
        // Get current output device
        guard let currentDevice = audioManager.getCurrentOutputDevice() else {
            logger.log("Could not get current output device")
            return
        }
        
        logger.log("Current device: \(currentDevice.name) (External: \(currentDevice.isExternal))")
        
        // Check if current device is an external headphone
        if currentDevice.isExternal {
            logger.log("External headphone detected, saving device info")
            audioManager.saveExternalDevice(currentDevice)
            
            // Switch to built-in speakers
            if let builtInSpeakers = audioManager.getBuiltInSpeakers() {
                logger.log("Switching to built-in speakers: \(builtInSpeakers.name)")
                if audioManager.setOutputDevice(builtInSpeakers) {
                    logger.log("Successfully switched to built-in speakers before sleep")
                } else {
                    logger.log("Failed to switch to built-in speakers")
                }
            } else {
                logger.log("Warning: Could not find built-in speakers")
            }
        } else {
            logger.log("Current device is not external, no action needed")
            // Clear any previously saved device since we're not using external headphones
            audioManager.clearSavedDevice()
        }
    }
    
    /// Handle system waking up
    private func handleSystemDidWake() {
        logger.log("--- Handling System Wake ---")
        
        // Add a small delay to allow audio system to stabilize
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.performWakeAudioSwitch()
        }
    }
    
    /// Perform the audio device switch after wake
    private func performWakeAudioSwitch() {
        // Check if we have a saved external device
        guard let savedDevice = audioManager.loadSavedExternalDevice() else {
            logger.log("No saved external device found, no action needed")
            return
        }
        
        logger.log("Found saved device: \(savedDevice.name)")
        
        // Get all currently available devices
        let availableDevices = audioManager.getAllOutputDevices()
        logger.log("Available devices after wake: \(availableDevices.map { $0.name }.joined(separator: ", "))")
        
        // Check if the saved device is available
        if let matchingDevice = audioManager.findDeviceByUID(savedDevice.uid) {
            logger.log("Saved device is available, switching back to: \(matchingDevice.name)")
            
            if audioManager.setOutputDevice(matchingDevice) {
                logger.log("Successfully switched back to external headphone")
            } else {
                logger.log("Failed to switch back to external headphone")
            }
        } else {
            logger.log("Saved device is not available after wake")
            
            // Check if any external headphone is connected (might be a different one)
            let externalDevices = availableDevices.filter { $0.isExternal }
            if !externalDevices.isEmpty {
                logger.log("Found \(externalDevices.count) external device(s), but not the original one")
                logger.log("Keeping current audio device selection")
            } else {
                logger.log("No external devices found after wake")
            }
        }
        
        // Clear the saved device state after attempting to restore
        audioManager.clearSavedDevice()
    }
}

