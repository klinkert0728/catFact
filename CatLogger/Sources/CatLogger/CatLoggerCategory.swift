//
//  CatLoggerCategory.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import Logging

extension CatLogger {

	public struct CatLoggerCategory {

		private let name: String
		private var logger: Logger
		public var logLevel: CatLoggerLevel {
			get {
				CatLoggerLevel(rawValue: self.logger.logLevel.rawValue) ?? .error
			}

			set {
				self.logger.logLevel = newValue.swiftLoggerLogLevel
			}
		}

		internal init(name: String, parent: CatLoggerSubSystem) {
			self.name = name
			self.logger = Logger(label: parent.id)
		}

		private func log(level: Logger.Level, message: @escaping @autoclosure () -> String, error: Error?, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {

			let metaData: (() -> Logger.Metadata) = {
				var metaData = Logger.Metadata()
				metaData["line"] = .stringConvertible(line)
				metaData["function"] = .stringConvertible(function)
				metaData["file"] = .stringConvertible(file)
				if let error = error {
					metaData["error"] = "\(error)"
				}

				return metaData
			}

			let formattedMessage: (() -> Logger.Message) = {
				return "\(message())"
			}

			self.logger.log(level: level, formattedMessage(), metadata: metaData(), source: self.name, file: "\(file)", function: "\(function)", line: line)
		}
	}
}

extension CatLogger.CatLoggerCategory {

	public func debug(_ message: @escaping @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		self.log(level: .debug, message: message(), error: nil, file: file, function: function, line: line)
	}

	public func debug(_ message: @escaping @autoclosure () -> Any, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		self.debug("\(message())", file: file, function: function, line: line)
	}

	public func info(_ message: @escaping @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		self.log(level: .info, message: message(), error: nil, file: file, function: function, line: line)
	}

	public func info(_ message: @escaping @autoclosure () -> Any, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		self.info("\(message())", file: file, function: function, line: line)
	}

	public func error(_ error: Error?, _ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		self.log(level: .error, message: message, error: error, file: file, function: function, line: line)
	}

	public func error(_ message: @escaping @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		self.error(nil, message(), file: file, function: function, line: line)
	}

	public func error(_ error: Error, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		self.error(error, "", file: file, function: function, line: line)
	}
}
