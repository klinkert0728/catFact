//
//  CatFactConfiguration.swift
//  
//
//  Created by Daniel Klinkert on 07.08.23.
//

import Foundation

/// Holds the configuration of the app. e.g base url, environment etc.
public struct CatFactConfiguration: Decodable {
	public enum Environment: String, Decodable {
		case dev
	}

	enum CodingKeys: String, CodingKey {
		case apiBaseUrl
		case environment
	}

	public static var current: CatFactConfiguration?

	let environment: Environment
	let apiBaseUrl: String

	init(apiBaseUrl: String, environment: Environment) {
		self.apiBaseUrl = apiBaseUrl
		self.environment = environment
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.apiBaseUrl = try container.decode(String.self, forKey: .apiBaseUrl)
		self.environment = try container.decode(Environment.self, forKey: .environment)
	}
}
