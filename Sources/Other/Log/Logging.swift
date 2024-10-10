import Logging

public let logger = Logger.configure()

extension Logger {
    static public func configure() -> Logger {
        var logger = Logger(label: "com.mourey.journey-jar")
        logger.logLevel = .debug
        logger.info("Hello JourneyJar!")
        return logger
    }
}
