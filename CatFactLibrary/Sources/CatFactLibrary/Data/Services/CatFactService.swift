//
//  CatFactService.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import Combine
import CatLogger

protocol CreateCatFactServiceProtocol {

	@discardableResult
	func getRandomCatFact() async throws -> CatFact 
}

protocol FetchCatFactServiceProtocol {

	/// Publisher for the entries
	/// - Parameter limit: value to limit the live updates on the database
	/// - Returns: Publisher with the Fact entries
	func catFactPublisher(limit: Int) -> AnyPublisher<[CatFact], Never>

	@discardableResult
	/// Fetch first page of facts
	/// - Parameter limit: limit the api request. ideally the same as the limit on the local database
	/// - Returns: fetched ordered entries
	mutating func fetchFacts(limit: Int) async throws -> [CatFact]

	@discardableResult
	/// Fetch following pages for the CatFact api. empty when no more pages available
	/// - Parameter limit: limit the api request, keep it consistent with the first page fetch
	/// - Returns: fetched ordered entries
	mutating func fetchPaginatedFacts(limit: Int) async throws -> [CatFact]
}

protocol CatFactServiceProtocol: FetchCatFactServiceProtocol, CreateCatFactServiceProtocol {}

struct CatFactService: CatFactServiceProtocol {

	private let resAPI: CatFactAPIServiceProtocol
	private let localDatabase: PublisherLocalDatabaseManagerProtocol
	private let baseUrl: URL
	private var nextPageUrl: URL?
	private var lastEntrytimestamp: Int?

	init(resAPI: CatFactAPIServiceProtocol, url: URL, localDatabase: PublisherLocalDatabaseManagerProtocol) {
		self.baseUrl = url
		self.resAPI = resAPI
		self.localDatabase = localDatabase
	}

	mutating func fetchFacts(limit: Int) async throws -> [CatFact] {
		let requestUrl = self.baseUrl.appending(path: "facts")
		guard let url = self.addComponents(to: requestUrl, limit: limit)?.url else {
			return []
		}

		let facts: FactRestAPIResponse<CatFact> = try await self.resAPI.fetchAll(at: url)

		self.nextPageUrl = self.addComponents(to: facts.nextPage.pageValue, limit: limit)?.url
		let orderedEntries = self.orderEntries(entries: facts.entries)
		return orderedEntries
	}

	mutating func fetchPaginatedFacts(limit: Int) async throws -> [CatFact] {
		guard let nextPageUrl else {
			return []
		}

		let facts: FactRestAPIResponse<CatFact> = try await self.resAPI.fetchAll(at: nextPageUrl)
		self.nextPageUrl = self.addComponents(to: facts.nextPage.pageValue, limit: limit)?.url
		let orderedEntries = self.orderEntries(entries: facts.entries)
		return orderedEntries
	}

	/// Added just to make ordering in the local database meaningful, asssumes the response is ordered descending.
	/// - Parameter entries: entries without creationDate.
	/// - Returns: Entries with creationdate based on the previous fetched entries.
	mutating private func orderEntries(entries: [CatFact]) -> [CatFact] {
		var orderedEntries = [CatFact]()
		let comparisonTimeInterval: Int = {
			guard let lastEntrytimestamp else {
				return Int(Date().timeIntervalSince1970)
			}

			return lastEntrytimestamp
		}()

		for (index, entry) in entries.enumerated() {
			var newEntry = entry
			newEntry.creationDate = comparisonTimeInterval - index
			orderedEntries.append(newEntry)
		}

		self.lastEntrytimestamp = orderedEntries.last?.creationDate

		return orderedEntries
	}

	func catFactPublisher(limit: Int) -> AnyPublisher<[CatFact], Never> {
		return self.localDatabase.allContinuous(of: CatFact.self, where: [.all], order: .descending(CatFact.Columns.creationDate), limit: limit, offset: nil)
			.replaceError(with: [], logInto: CatLogger.catFactLibrary.database)
			.removeDuplicates()
			.eraseToAnyPublisher()
	}


	func getRandomCatFact() async throws -> CatFact  {
		let requestUrl = self.baseUrl.appending(path: "fact")
		var randomFact: CatFact = try await self.resAPI.fetchOne(at: requestUrl)
		randomFact.creationDate = Int(Date().timeIntervalSince1970)
		return randomFact
	}

	private func addComponents(to url: URL?, limit: Int) -> URLComponents? {
		guard
			let url = url,
			var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			return nil
		}

		let queryItem = URLQueryItem(name: "limit", value: "\(limit)")
		if var query = urlComponents.queryItems {
			query.append(queryItem)
			urlComponents.queryItems = query
		} else {
			urlComponents.queryItems = [queryItem]
		}

		return urlComponents
	}
}
