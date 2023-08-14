import Logging
import Foundation

public enum CatLogger {

	public static func setup(_ factory: @escaping (_ label: String) -> [LogHandler]) {
		LoggingSystem.bootstrap { label in
			let loggers = factory(label)
			return MultiplexLogHandler(loggers)
		}
	}
}
