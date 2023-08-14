//
//  CatFactAPIServiceTests.swift
//  
//
//  Created by Daniel Klinkert on 07.08.23.
//

import XCTest
import Foundation
@testable import CatFactLibrary

final class CatFactAPIServiceTests: XCTestCase {

	func test_fetchAll_shouldThrowBadRequestError_whenUserPerformsABadRequest() async throws  {
		let session = MockSession(error: NSError(domain: "de.catFact", code: 400))
		let sut = CatFactAPIService(session: session)

		do {
			let _: FactRestAPIResponse<CatFact> = try await sut.fetchAll(at: URL(string: "test.com")!)
			XCTFail("Not expected success")

		} catch {
			guard let customError = error as? CatFactAPIServiceError else {
				XCTFail("Not expected Error")
				return
			}

			XCTAssert(CatFactAPIServiceError.badRequest == customError)
		}
	}

	func test_fetchAll_shouldNotThrowCustomError_whenErrorCodeDoesNotMatchRanges() async throws  {
		let session = MockSession(error: NSError(domain: "de.catFact", code: 600))
		let sut = CatFactAPIService(session: session)

		do {
			let _: FactRestAPIResponse<CatFact> = try await sut.fetchAll(at: URL(string: "test.com")!)
			XCTFail("Not expected success")
		} catch {
			XCTAssertEqual((error as NSError).code, 600)
		}
	}

	func test_fetchAll_returnCatFacts_whenRequestIsSuccess() async throws  {
		let json = """
		{
			"data": [
				{
				"fact": "Test fact",
				"length": 12
				}
			]
		}
		"""

		let data = try XCTUnwrap(json.data(using: .utf8))
		let session = MockSession(data: data)
		let sut = CatFactAPIService(session: session)

		do {
			let facts: FactRestAPIResponse<CatFact> = try await sut.fetchAll(at: URL(string: "test.com")!)
			XCTAssertEqual(facts.entries.first?.fact, "Test fact")
		} catch {
			XCTFail("Not expected Error")
		}
	}
}

class MockSession: CatFactAPIServiceSessionProtocol {

	// Properties that enable us to set exactly what data or error
	// we want our mocked URLSession to return for any request.
	var data: Data?
	var error: Error?

	init(data: Data? = nil, error: Error? = nil) {
		self.data = data
		self.error = error
	}

	func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		if let error {
			throw error
		}

		guard let data else {
			throw NSError()
		}

		return (data, URLResponse())
	}
}
