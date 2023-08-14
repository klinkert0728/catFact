//
//  CatLoggerLevel.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import Logging

public enum CatLoggerLevel: String, Codable, CaseIterable {
	case trace
	case debug
	case info
	case notice
	case warning
	case error
	case critical

	var swiftLoggerLogLevel: Logger.Level {
		switch self {
		case .trace:	return .trace
		case .debug:	return .debug
		case .info:		return .info
		case .notice:	return .notice
		case .warning:	return .warning
		case .error:	return .error
		case .critical:	return .critical
		}
	}
}
