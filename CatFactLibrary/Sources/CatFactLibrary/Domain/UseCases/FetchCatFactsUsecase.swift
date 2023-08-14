//
//  FetchCatFactsUsecase.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import Combine
import CatLogger

public protocol FetchCatFactsUsecaseProtocol {

	/// Publisher fot the CatFact entries
	/// - Parameter limit: limit the entries that get live updates
	/// - Returns: publisher of CatFact entries
	func catFactsPublisher(limit: Int) -> AnyPublisher<[CatFact], Never>

	/// Fetch first page of CatFacts and stores the result in the localDatabase
	func fetchCatFacts() async throws

	/// Fetch additional pages of CatFacts and stores the result in the localDatabase.
	func fetchMoreCatFacts() async throws
}

final class FetchCatFactsUsecase: FetchCatFactsUsecaseProtocol {

	private var catFactService: FetchCatFactServiceProtocol
	private let localDatabase: SaveLocalDatabaseManagerProtocol
	/// Define the size of the page to load from the API.
	private let pageSize = 20

	init(catFactService: FetchCatFactServiceProtocol, localDatabase: SaveLocalDatabaseManagerProtocol) {
		self.catFactService = catFactService
		self.localDatabase = localDatabase
	}

	public func fetchCatFacts() async throws {
		do {
			let facts = try await self.catFactService.fetchFacts(limit: self.pageSize)
			try await self.persistPage(facts: facts)
		} catch CatFactAPIServiceError.badRequest {
			CatLogger.catFactLibrary.catFacts.error("failed to fetch first page of facts")
			// propagte custom error when needed
			throw CatFactAPIServiceError.badRequest
		} catch CatFactAPIServiceError.somethingWentWrong {
			CatLogger.catFactLibrary.catFacts.error("failed to fetch first page of facts")
			throw  CatFactAPIServiceError.somethingWentWrong
		} catch {
			CatLogger.catFactLibrary.catFacts.error("failed to fetch facts or save with first page of facts unexpected error \(error)")
			throw error
		}
	}

	public func fetchMoreCatFacts() async throws {
		do {
			let facts = try await self.catFactService.fetchPaginatedFacts(limit: self.pageSize)
			try await self.persistPage(facts: facts)
		} catch {
			// propagte custom error when needed
			throw error
		}
	}

	private func persistPage(facts: [CatFact]) async throws {
		try await self.localDatabase.save(facts)
	}

	func catFactsPublisher(limit: Int) -> AnyPublisher<[CatFact], Never> {
		return self.catFactService.catFactPublisher(limit: limit)
			.removeDuplicates()
			.eraseToAnyPublisher()
	}
}
