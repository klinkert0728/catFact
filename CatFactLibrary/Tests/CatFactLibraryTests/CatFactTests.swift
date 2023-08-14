//
//  CatFactTests.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import XCTest
@testable import CatFactLibrary


final class CatFactTests: XCTestCase {

	func test_initWithJSONData_shouldReturnCatFact_whenDataIsValid() throws {
		let json = """
		 {
			"fact": "Test fact",
			"length": 12
		 }
		"""

		let data = try XCTUnwrap(json.data(using: .utf8))
		
		let catFact = try JSONDecoder().decode(CatFact.self, from: data)
		XCTAssertEqual(catFact.fact, "Test fact")
	}

	func test_initWithJSONData_shouldThrowError_whenFactPropertyIsMissing() throws {
		let json = """
		 {
			"length": 12
		 }
		"""

		let data = try XCTUnwrap(json.data(using: .utf8))

		XCTAssertThrowsError(try JSONDecoder().decode(CatFact.self, from: data))
	}

	func test_initWithJSONData_shouldThrowError_whenLenghtPropertyIsMissing() throws {
		let json = """
		 {
			"fact": "Test fact"
		 }
		"""

		let data = try XCTUnwrap(json.data(using: .utf8))
		XCTAssertThrowsError(try JSONDecoder().decode(CatFact.self, from: data))
	}
}
