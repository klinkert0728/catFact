//
//  CatLoggerSubSystem.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation

extension CatLogger {
	open class CatLoggerSubSystem {
		let id: String
		let name: String

		public static var fallbackBundleIdentifier = "de.catfact.CatFact"
		private let channels = ThreadSafeDictionary<String, CatLoggerCategory>()

		public init(name: String) {
			self.name = name
			let bundleIdentifier = (Bundle.main.bundleIdentifier ?? Self.fallbackBundleIdentifier).lowercased()
			self.id = "\(bundleIdentifier).\(name)"
		}

		public var allChannels: [CatLoggerCategory] {
			return self.channels.map { $0.value }
		}

		public func channel(name: String) -> CatLoggerCategory {
			if let existingChannel = self.channels[name] {
				return existingChannel
			}

			let newChannel = CatLoggerCategory(name: name, parent: self)
			self.channels[name] = newChannel
			return newChannel
		}
	}
}
