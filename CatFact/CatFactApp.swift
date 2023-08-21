//
//  CatFactApp.swift
//  CatFact
//
//  Created by Daniel Klinkert on 06.08.23.
//

import SwiftUI
import CatFactLibrary

@main
struct CatFactApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		WindowGroup {
			if
				let fetchCatFactsUseCase = self.appDelegate.fetchCatFactUseCase,
				let createCatFactUseCase = self.appDelegate.createCatFactUseCase
			{
				let viewModel = HomeViewModel(
					fetchCatListUseCase: fetchCatFactsUseCase,
					createCatFactUseCase: createCatFactUseCase
				)

					HomeView(homeViewModel: viewModel)
			} else {
				ProgressView()
			}
		}
	}
}
