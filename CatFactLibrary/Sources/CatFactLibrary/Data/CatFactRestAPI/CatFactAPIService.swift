//
//  CatFactAPIService.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation

/// CatfactAPIService
/// Interface to allow Services to interact with the REST API for the catFacts.
protocol CatFactAPIServiceProtocol {

	/// Fetches paginated array of entries. The entries must confirm Decodable protocol.
	/// - Parameter url: Url where to fetch the entries from.
	/// - Returns: Object that allows to determine if there are more pages available for the next request.
	func fetchAll<T>(at url: URL) async throws -> FactRestAPIResponse<T> where T: Decodable


	/// Fetch one specific element from the REST API endpoint.
	/// - Parameter url: Url where to fetch the entries from.
	/// - Returns: The fetched entry.
	func fetchOne<T>(at url: URL) async throws -> T where T: Decodable
}


struct CatFactAPIService: CatFactAPIServiceProtocol {

	private let session: CatFactAPIServiceSessionProtocol

	init(session: CatFactAPIServiceSessionProtocol = URLSession.shared) {
		self.session = session
	}

	func fetchAll<T>(at url: URL) async throws -> FactRestAPIResponse<T> where T: Decodable {
		let data = try await self.performRequest(for: url)

		let collectionResponse = try JSONDecoder().decode(FactRestAPIResponse<T>.self, from: data)
		return collectionResponse
	}

	func create<T>(at url: URL) async throws -> T where T : Decodable {
		let data = try await self.performRequest(for: url)

		let createdResponse = try JSONDecoder().decode(T.self, from: data)
		return createdResponse
	}

	func fetchOne<T>(at url: URL) async throws -> T where T: Decodable {
		let data = try await self.performRequest(for: url)
		return try JSONDecoder().decode(T.self, from: data)
	}

	private func performRequest(for url: URL) async throws -> Data {
		let request = URLRequest(url: url)
		
		do {
			let (data, _) = try await self.session.data(for: request)
			return data
		} catch {
			// Propagate custom error when needed
			guard let expectedError = CatFactAPIServiceError(apiError: error) else {
				throw error
			}

			throw expectedError
		}
	}
}
