//
//  UseCaseProvider.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import CatLogger

/// Helper to create Usecases.
public struct UseCaseProvider {
	private let frameWorkConfiguration: FrameworkConfiguration

	public init(frameWorkConfiguration: FrameworkConfiguration) {
		self.frameWorkConfiguration = frameWorkConfiguration
	}

	public func fetchCatFactsUseCase() throws -> FetchCatFactsUsecaseProtocol?  {
		guard
			let baseURLString = CatFactConfiguration.current?.apiBaseUrl,
			let baseURL = URL(string: baseURLString),
			let database = self.frameWorkConfiguration.database else {
				return nil
		}

		let catService = CatFactService(resAPI: CatFactAPIService(), url: baseURL, localDatabase: database)
		return FetchCatFactsUsecase(catFactService: catService, localDatabase: database)
	}

	public func createCatfactUsecase() throws -> CreateCatfactUsecaseProtocol? {
		guard
			let baseURLString = CatFactConfiguration.current?.apiBaseUrl,
			let baseURL = URL(string: baseURLString),
			let database = self.frameWorkConfiguration.database else {
				return nil
		}

		let catFactService = CatFactService(resAPI: CatFactAPIService(), url: baseURL, localDatabase: database)
		return CreateCatfactUseCase(catFactService: catFactService, localDatabase: database)
	}
}
