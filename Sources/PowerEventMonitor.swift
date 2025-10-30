import Foundation
import IOKit
import IOKit.pwr_mgt

/// Monitors system power events (sleep/wake)
class PowerEventMonitor {

    private let logger = Logger.shared
    private var notificationPort: IONotificationPortRef?
    private var notifier: io_object_t = 0
    private var rootPort: io_connect_t = 0

    // IOKit message type constants (raw values)
    private let kIOMessageCanSystemSleep: UInt32 = 0xE0000270
    private let kIOMessageSystemWillSleep: UInt32 = 0xE0000280
    private let kIOMessageSystemWillNotSleep: UInt32 = 0xE0000290
    private let kIOMessageSystemWillPowerOn: UInt32 = 0xE0000320
    private let kIOMessageSystemHasPoweredOn: UInt32 = 0xE0000300

    // Callbacks for power events
    var onSystemWillSleep: (() -> Void)?
    var onSystemDidWake: (() -> Void)?

    init() {}
    
    /// Start monitoring power events
    func startMonitoring() {
        // Register for sleep/wake notifications
        rootPort = IORegisterForSystemPower(
            Unmanaged.passUnretained(self).toOpaque(),
            &notificationPort,
            { (refCon, service, messageType, messageArgument) in
                guard let refCon = refCon else { return }
                let monitor = Unmanaged<PowerEventMonitor>.fromOpaque(refCon).takeUnretainedValue()
                monitor.handlePowerEvent(messageType: messageType, messageArgument: messageArgument)
            },
            &notifier
        )

        if rootPort == MACH_PORT_NULL {
            logger.log("Failed to register for power notifications")
            return
        }

        // Add notification port to run loop
        if let notificationPort = notificationPort {
            CFRunLoopAddSource(
                CFRunLoopGetCurrent(),
                IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue(),
                .defaultMode
            )
            logger.log("Power event monitoring started")
        }
    }
    
    /// Stop monitoring power events
    func stopMonitoring() {
        if notifier != 0 {
            IODeregisterForSystemPower(&notifier)
            notifier = 0
        }
        
        if let notificationPort = notificationPort {
            IONotificationPortDestroy(notificationPort)
            self.notificationPort = nil
        }
        
        logger.log("Power event monitoring stopped")
    }
    
    /// Handle power event messages
    private func handlePowerEvent(messageType: UInt32, messageArgument: UnsafeMutableRawPointer?) {
        switch messageType {
        case kIOMessageCanSystemSleep:
            // System is asking if it can sleep
            // We must respond to allow sleep
            logger.log("System can sleep message received")
            if let argument = messageArgument {
                IOAllowPowerChange(rootPort, Int(bitPattern: argument))
            }

        case kIOMessageSystemWillSleep:
            // System is about to sleep
            logger.log("System will sleep")
            onSystemWillSleep?()

            // Acknowledge the notification
            if let argument = messageArgument {
                IOAllowPowerChange(rootPort, Int(bitPattern: argument))
            }

        case kIOMessageSystemHasPoweredOn:
            // System has woken up
            logger.log("System has woken up")
            onSystemDidWake?()

        case kIOMessageSystemWillPowerOn:
            // System is about to wake up
            logger.log("System will power on")

        case kIOMessageSystemWillNotSleep:
            // System decided not to sleep
            logger.log("System will not sleep")

        default:
            break
        }
    }
    
    deinit {
        stopMonitoring()
    }
}

