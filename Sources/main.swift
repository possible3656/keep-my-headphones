import Foundation

// Create and start the service
let service = HeadphoneService()
service.start()

// Setup signal handlers for graceful shutdown
signal(SIGINT) { _ in
    print("\nReceived SIGINT, shutting down...")
    exit(0)
}

signal(SIGTERM) { _ in
    print("\nReceived SIGTERM, shutting down...")
    exit(0)
}

// Keep the service running
RunLoop.main.run()

