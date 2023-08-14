//
//  FrameworkConfiguration+Swinject.swift
//  
//
//  Created by Daniel Klinkert on 13.08.23.
//

import Foundation
import Swinject
import CatLogger

/// Dependency injection configuration for the framework.
public struct FrameworkConfiguration {
	private let defaultContainer = Container()

	public static var current: FrameworkConfiguration?

	public init() {}

	/// Needs to be called in the init to configure the localdatabase.
	public func setup() {
		self.defaultContainer.register(LocalDatabaseManagerProtocol.self) { _ in
			let url = FileManager.default
				.urls(for: .documentDirectory, in: .userDomainMask)
				.first?
				.appendingPathComponent("catfact.db")

			let location: LocalDatabaseManager.DatabaseLocation = {
				if let url {
					return .fileSystem(url)
				} else {
					return .memory
				}
			}()

			return LocalDatabaseManager(location: location, logCategory: CatLogger.catFactLibrary.database)
		}
		.inObjectScope(.container)
	}
}


extension FrameworkConfiguration {
	var database: LocalDatabaseManagerProtocol? {
		self.defaultContainer.resolve(LocalDatabaseManagerProtocol.self)
	}
}
