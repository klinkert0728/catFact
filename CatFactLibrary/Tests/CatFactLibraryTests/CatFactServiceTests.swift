//
//  File.swift
//  
//
//  Created by Daniel Klinkert on 13.08.23.
//


import XCTest
import Foundation
import Combine
@testable import CatFactLibrary

final class CatFactServiceTests: XCTestCase {

	func test_fetchFactsFirstPage_shouldUseLimitAsQueryParameter() async throws  {
		let responseMock = MockRestAPI(response: [], pagination: .firstPage)
		let testUrl = try XCTUnwrap(URL(string: "http:www.test.com"))
		let mockDBManager = MockLocalDatabase()

		var sut = CatFactService(resAPI: responseMock, url: testUrl, localDatabase: mockDBManager)
		let _ = try await sut.fetchFacts(limit: 50)

		let url = try XCTUnwrap(responseMock.url)
		let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)

		XCTAssertNotNil(urlComponents?.queryItems?.first(where: {$0.name == "limit" }))
		XCTAssertNil(urlComponents?.queryItems?.first(where: {$0.name == "page" }))
		XCTAssertEqual(urlComponents?.queryItems?.first(where: {$0.name == "limit" })?.value, "50")
	}

	func test_fetchPaginatedFacts_shouldReturnEmpty_whenNoNextPageIsDefined() async throws  {
		let responseMock = MockRestAPI(response: [], pagination: .firstPage)
		let testUrl = try XCTUnwrap(URL(string: "http:www.test.com"))
		let mockDBManager = MockLocalDatabase()

		var sut = CatFactService(resAPI: responseMock, url: testUrl, localDatabase: mockDBManager)
		let result = try await sut.fetchPaginatedFacts(limit: 20)

		XCTAssertEqual(result, [])
	}

	func test_fetchPaginatedFacts_shouldNotReturnEmpty_whenNextPageIsDefined() async throws  {
		let responseMock = MockRestAPI(response: [], pagination: .page(at: "http://www.test.com?page=2"))
		let testUrl = try XCTUnwrap(URL(string: "http:www.test.com"))
		let mockDBManager = MockLocalDatabase()

		var sut = CatFactService(resAPI: responseMock, url: testUrl, localDatabase: mockDBManager)
		let _ = try await sut.fetchFacts(limit: 20)

		let _ = try await sut.fetchPaginatedFacts(limit: 20)

		let url = try XCTUnwrap(responseMock.url)
		let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
		XCTAssertNotNil(urlComponents?.queryItems?.first(where: {$0.name == "limit" }))
		XCTAssertEqual(urlComponents?.queryItems?.first(where: {$0.name == "page" })?.value, "2")
		XCTAssertEqual(urlComponents?.queryItems?.first(where: {$0.name == "limit" })?.value, "20")
	}

	func test_getRandomCatFact_throwSaveError_whenSavingToDatabaseFails() async throws  {
		let newFact = CatFact(fact: "Hello World cat fact", length: .random(in: 0...10))
		let responseMock = MockRestAPI(response: [newFact], pagination: .page(at: "http://www.test.com?page=2"))
		let testUrl = try XCTUnwrap(URL(string: "http:www.test.com"))
		let mockDBManager = MockLocalDatabase()
		mockDBManager.error = LocalDatabaseError.failedToSave

		let sut = CatFactService(resAPI: responseMock, url: testUrl, localDatabase: mockDBManager)
		do {
			try await sut.getRandomCatFact()
		} catch {
			guard let saveError = error as? LocalDatabaseError else {
				XCTFail("Unexpected error")
				return
			}

			XCTAssertEqual(saveError, .failedToSave)
		}
	}
}

private class MockLocalDatabase: SaveLocalDatabaseManagerProtocol & PublisherLocalDatabaseManagerProtocol {
	var savedValues = [CatFact]()
	var error: Error?

	func save<T>(_ objects: [T]) async throws where T : CatFactLibrary.DBRecordProtocol {
		guard let error else {
			self.savedValues = objects as! [CatFact]
			return
		}

		throw error
	}

	func allContinuous<T>(of type: T.Type, where expression: [CatFactLibrary.LocalDatabaseFetchOption], order: CatFactLibrary.LocalDatabaseSortOption?, limit: Int, offset: Int?) -> AnyPublisher<[T], Error> where T : CatFactLibrary.DBRecordProtocol {
		Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
	}
}

private class MockRestAPI: CatFactAPIServiceProtocol {

	let response: [CatFact]
	var paginationResponse: RESTAPIPagination
	var url: URL?

	init(response: [CatFact], pagination: RESTAPIPagination) {
		self.response = response
		self.paginationResponse = pagination
	}

	func fetchAll<T>(at url: URL) async throws -> CatFactLibrary.FactRestAPIResponse<T> where T : Decodable {
		self.url = url
		return FactRestAPIResponse(entries: response as! [T], nextPage: self.paginationResponse)
	}

	func fetchOne<T>(at url: URL) async throws -> T where T : Decodable {
		return self.response.first as! T
	}
}
