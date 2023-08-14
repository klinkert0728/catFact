//
//  CatFactLibrarySubSystem.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import CatLogger

extension CatLogger {

	/// Define subsystem for the Library. Useful when filtering logs.
	class CatFactLibrarySubSystem: CatLogger.CatLoggerSubSystem {
		lazy var database = self.channel(name: "database")
		lazy var catFacts = self.channel(name: "catFacts")
	}

	static let catFactLibrary = CatFactLibrarySubSystem(name: "catFactLibrary")
}

