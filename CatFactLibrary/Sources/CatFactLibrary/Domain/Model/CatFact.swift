//
//  CatFact.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation

/// CatFact Model
/// creationDate is updated based on the fetch entries from the API.
public struct CatFact: Codable, Identifiable, Equatable {

	/// Random cat fact.
	public let fact: String

	/// Length of the random fact string.
	public let length: Int

	/// Unique id for the CatFact.
	public let id: String = UUID().uuidString

	/// Creation date of the Catfact
	var creationDate: Int?

	init(fact: String, length: Int, creationDate: Int?) {
		self.fact = fact
		self.length = length
		self.creationDate = creationDate
	}
}
