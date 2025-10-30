import Foundation

/// Simple logger for the service
class Logger {
    static let shared = Logger()
    
    private let logFilePath: String
    private let dateFormatter: DateFormatter
    private let queue = DispatchQueue(label: "com.whybex.keepmyheadphones.logger")

    private init() {
        // Store logs in user's Library/Logs
        let logsDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Logs")
            .appendingPathComponent("KeepMyHeadphones")
        
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        logFilePath = logsDir.appendingPathComponent("service.log").path
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    func log(_ message: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let timestamp = self.dateFormatter.string(from: Date())
            let logMessage = "[\(timestamp)] \(message)\n"
            
            // Print to console
            print(logMessage, terminator: "")
            
            // Write to file
            if let data = logMessage.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: self.logFilePath) {
                    if let fileHandle = FileHandle(forWritingAtPath: self.logFilePath) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } else {
                    try? data.write(to: URL(fileURLWithPath: self.logFilePath))
                }
            }
        }
    }
}

