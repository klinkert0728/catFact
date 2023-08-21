//
//  HomeViewModel.swift
//  CatFact
//
//  Created by Daniel Klinkert on 13.08.23.
//

import Foundation
import CatFactLibrary
import CatLogger
import Combine

enum HomeLoadingState: Hashable, Identifiable {
	var id: Self {
		self
	}

	case completed
	case inProgress
	case failed
}

@MainActor
class HomeViewModel: ObservableObject {
	private let fetchCatListUseCase: FetchCatFactsUseCaseProtocol
	private let createCatFactUseCase: CreateCatfactUseCaseProtocol

	let creatingErrorAlertMessage = "Creating Failed, please try again"
	@Published var creatingFact = false
	@Published var loadingState: HomeLoadingState?
	@Published var error = false

	init(fetchCatListUseCase: FetchCatFactsUseCaseProtocol, createCatFactUseCase: CreateCatfactUseCaseProtocol) {
		self.fetchCatListUseCase = fetchCatListUseCase
		self.createCatFactUseCase = createCatFactUseCase
	}

	func createCatFactListViewModel() -> CatFactListViewModel {
		CatFactListViewModel(fetchFactsUseCase: self.fetchCatListUseCase)
	}

	func getRandomCatFact() {
		Task {
			self.loadingState = .inProgress
			do {
				try await self.createCatFactUseCase.createRandomCatFact()
				self.loadingState = .completed
			} catch {
				self.loadingState = .failed
				self.error = true
				CatLogger.app.system.error("failed to create random catFact \(error)")
			}
		}
	}
}
