import Logging

public let logger = Logger.configure()

public func logError(_ errorDescription: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
    logger.error("🛑 \(errorDescription)", file: file, function: function, line: line)
}

extension Logger {
    static public func configure() -> Logger {
        var logger = Logger(label: "com.mourey.journey-jar")
        logger.logLevel = .debug
        logger.info("Hello JourneyJar!")
        return logger
    }
}
