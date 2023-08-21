//
//  CatFactListViewModel.swift
//  CatFact
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import CatFactLibrary
import Combine
import CatLogger

@MainActor class CatFactListViewModel: ObservableObject {
	@Published var catFacts = [CatFact]()
	@Published var limit = 20

	private var cancellable = Set<AnyCancellable>()
	private let fetchFactsUseCase: FetchCatFactsUseCaseProtocol

	init(fetchFactsUseCase: FetchCatFactsUseCaseProtocol) {
		self.fetchFactsUseCase = fetchFactsUseCase
		self.configureFactsUpdate()
	}

	func configureFactsUpdate() {
		self.$limit
			.removeDuplicates()
			.compactMap { [weak self] in
				return self?.fetchFactsUseCase.catFactsPublisher(limit: $0)
			}
			.switchToLatest()
			.removeDuplicates()
			.filter { $0.isEmpty == false }
			.assign(to: &self.$catFacts)
	}

	func fetchCatFacts() async {
		do {
			try await self.fetchFactsUseCase.fetchCatFacts()
		} catch {
			CatLogger.app.system.error("Error loading first cat fact page \(error)")
		}
	}

	func fetchMorePages() async {
		do {
			try await self.fetchFactsUseCase.fetchMoreCatFacts()
			self.limit += 20
		} catch {
			CatLogger.app.system.error("Error loading more cat fact pages \(error)")
		}
	}
}
