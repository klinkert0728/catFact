//
//  CreateCatfactUseCase.swift
//  
//
//  Created by Daniel Klinkert on 13.08.23.
//

import Foundation

public protocol CreateCatfactUseCaseProtocol {
	/// Create random CatFact.
	func createRandomCatFact() async throws
}

struct CreateCatfactUseCase: CreateCatfactUseCaseProtocol {

	private let catFactService: CreateCatFactServiceProtocol
	private let localDatabase: SaveLocalDatabaseManagerProtocol

	init(catFactService: CreateCatFactServiceProtocol, localDatabase: SaveLocalDatabaseManagerProtocol) {
		self.catFactService = catFactService
		self.localDatabase = localDatabase
	}

	func createRandomCatFact() async throws {
		let randomFact = try await self.catFactService.getRandomCatFact()
		try await self.localDatabase.save([randomFact])
	}
}
