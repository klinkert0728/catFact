//
//  CatFactConfiguration+Extension.swift
//  CatFact
//
//  Created by Daniel Klinkert on 07.08.23.
//

import Foundation
import CatFactLibrary

extension CatFactConfiguration {
	static func setup() {
		guard let configurationUrl = Bundle.main.url(forResource: "Config", withExtension: "plist") else {
			assertionFailure("Missing configuration file")
			return
		}

		do {
			let infoPlistData = try Data(contentsOf: configurationUrl)
			let config = try PropertyListDecoder().decode(CatFactConfiguration.self, from: infoPlistData)
			CatFactConfiguration.current = config
		} catch {
			assertionFailure("Missing configuration")
		}
	}
}
