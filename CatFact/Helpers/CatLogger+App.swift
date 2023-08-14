//
//  CatLogger+App.swift
//  CatFact
//
//  Created by Daniel Klinkert on 13.08.23.
//

import Foundation
import CatLogger

extension CatLogger {

	class AppSubSystem: CatLoggerSubSystem {
		/// System related (app delegate / setup )
		lazy var system = self.channel(name: "system")
	}

	static let app = AppSubSystem(name: "app")
}
