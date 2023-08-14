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
	private let fetchCatListUsecase: FetchCatFactsUsecaseProtocol
	private let createCatFactUsecase: CreateCatfactUsecaseProtocol

	let creatingErrorAlertMessage = "Creating Failed, please try again"
	@Published var creatingFact = false
	@Published var loadingState: HomeLoadingState?
	@Published var error = false

	init(fetchCatListUsecase: FetchCatFactsUsecaseProtocol, createCatFactUsecase: CreateCatfactUsecaseProtocol) {
		self.fetchCatListUsecase = fetchCatListUsecase
		self.createCatFactUsecase = createCatFactUsecase
	}

	func createCatFactListViewModel() -> CatFactListViewModel {
		CatFactListViewModel(fetchFactsUseCase: self.fetchCatListUsecase)
	}

	func getRandomCatFact() {
		Task {
			self.loadingState = .inProgress
			do {
				try await self.createCatFactUsecase.createRandomCatFact()
				self.loadingState = .completed
			} catch {
				self.loadingState = .failed
				self.error = true
				CatLogger.app.system.error("failed to create random catFact \(error)")
			}
		}
	}
}
