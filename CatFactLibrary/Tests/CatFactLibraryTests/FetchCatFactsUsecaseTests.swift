//
//  FetchCatFactsUseCaseTests.swift
//  
//
//  Created by Daniel Klinkert on 13.08.23.
//

import XCTest
import Foundation
import Combine
@testable import CatFactLibrary

final class FetchCatFactsUseCaseTests: XCTestCase {
	private var cancellable = Set<AnyCancellable>()

	private func generateRandomFacts(numberOfFacts: Int) -> [CatFact] {
		var randomFacts = [CatFact]()
		for iteration in 0..<numberOfFacts {
			let newFact = CatFact(fact: "random \(iteration)", length: .random(in: 0...10), creationDate: nil)
			randomFacts.append(newFact)
		}

		return randomFacts
	}

	func test_fetchFactsFirstPage_shouldReturnCatFactValues() async throws {
		let mockCatService = CatServiceMock()
		let response = self.generateRandomFacts(numberOfFacts: 20)
		mockCatService.responseToPublish = response

		let newFactsExpectaction = self.expectation(description: "Expect newFacts")
		let sut = FetchCatFactsUseCase(catFactService: mockCatService, localDatabase: LocalDatabaseMock())

		sut.catFactsPublisher(limit: 20)
			.sink { newFacts in
				XCTAssertFalse(newFacts.isEmpty)
				newFactsExpectaction.fulfill()
			}
			.store(in: &self.cancellable)

		let _ = try await sut.fetchCatFacts()

		await self.fulfillment(of: [newFactsExpectaction], timeout: 1)
	}

	func test_fetchFactsFirstPage_shouldReturnThrowError_whenAPIFailsToFetchFactsWithBadRequest() async {
		let mockCatService = CatServiceMock()
		mockCatService.error = CatFactAPIServiceError.badRequest

		let sut = FetchCatFactsUseCase(catFactService: mockCatService, localDatabase: LocalDatabaseMock())
		let errorExpectation = self.expectation(description: "Expect error")

		do {
			try await sut.fetchCatFacts()
		} catch CatFactAPIServiceError.badRequest {
			errorExpectation.fulfill()
		} catch {
			XCTFail("Not the exepcted error")
		}

		await self.fulfillment(of: [errorExpectation], timeout: 1)
	}

	func test_fetchFactsFirstPage_shouldReturnThrowError_whenAPIFailsToFetchFactsWithSomethingWentWrong() async {
		let mockCatService = CatServiceMock()
		mockCatService.error = CatFactAPIServiceError.somethingWentWrong

		let sut = FetchCatFactsUseCase(catFactService: mockCatService, localDatabase: LocalDatabaseMock())
		let errorExpectation = self.expectation(description: "Expect error")

		do {
			try await sut.fetchMoreCatFacts()
		} catch CatFactAPIServiceError.somethingWentWrong {
			errorExpectation.fulfill()
		} catch {
			XCTFail("Not the exepcted error")
		}

		await self.fulfillment(of: [errorExpectation], timeout: 1)
	}
}

private struct LocalDatabaseMock: SaveLocalDatabaseManagerProtocol {
	func save<T>(_ objects: [T]) async throws where T : DBRecordProtocol {

	}
}

private class CatServiceMock: CatFactServiceProtocol {

	private let catFactsSubject = CurrentValueSubject<[CatFact], Never>([CatFact]())
	var responseToPublish = [CatFact]()
	var error: Error?

	func catFactPublisher(limit: Int) -> AnyPublisher<[CatFactLibrary.CatFact], Never> {
		// drops first as the CurrentValueSubject will always publish the initial value fist
		self.catFactsSubject.dropFirst().eraseToAnyPublisher()
	}

	func fetchFacts(limit: Int) async throws -> [CatFactLibrary.CatFact] {
		guard let error = self.error else {
			self.catFactsSubject.value = self.responseToPublish
			return self.responseToPublish
		}

		throw error
	}

	func fetchPaginatedFacts(limit: Int) async throws -> [CatFactLibrary.CatFact] {
		guard let error = self.error else {
			self.catFactsSubject.value = self.responseToPublish
			return self.responseToPublish
		}

		throw error
	}

	func getRandomCatFact() async throws -> CatFactLibrary.CatFact {
		return responseToPublish.first!
	}

}
