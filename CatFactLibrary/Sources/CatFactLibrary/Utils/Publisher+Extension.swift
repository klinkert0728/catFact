//
//  Publisher+Extension.swift
//  
//
//  Created by Daniel Klinkert on 07.08.23.
//

import Foundation
import Combine
import CatLogger

extension Publisher {
	/// Replaces any errors in the stream with the provided element and logs error into the passed category
	/// - Parameters:
	///   - fallback: An element to emit when the upstream publisher fails.
	///   - category: category to log the error into
	/// - Returns: A publisher that replaces an error from the upstream publisher with the provided output element.
	func replaceError(
		with fallback: Self.Output,
		logInto category: CatLogger.CatLoggerCategory,
		file: StaticString = #file,
		function: StaticString = #function,
		line: UInt = #line
	) -> AnyPublisher<Self.Output, Never> {
		self.logError(category: category, file: file, function: function, line: line)
			.replaceError(with: fallback)
			.eraseToAnyPublisher()
	}

	/// Logs possible error to the passed log category
	/// - Parameters:
	///   - category: category to log the error into
	func logError(category: CatLogger.CatLoggerCategory, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> AnyPublisher<Self.Output, Self.Failure> {
		self.catch { error in
			category.error(error, file: file, function: function, line: line)
			return Fail<Self.Output, Self.Failure>(error: error)
		}
			.eraseToAnyPublisher()
	}
}
