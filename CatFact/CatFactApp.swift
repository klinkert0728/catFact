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
				let fetchCatFactsUsecase = self.appDelegate.fetchCatFactUsecase,
				let createCatFactUsecase = self.appDelegate.createCatFactUsecase
			{
				let viewModel = HomeViewModel(
					fetchCatListUsecase: fetchCatFactsUsecase,
					createCatFactUsecase: createCatFactUsecase
				)

					HomeView(homeViewModel: viewModel)
			} else {
				ProgressView()
			}
		}
	}
}
