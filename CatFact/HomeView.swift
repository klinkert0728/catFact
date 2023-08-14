//
//  HomeView.swift
//  CatFact
//
//  Created by Daniel Klinkert on 06.08.23.
//

import SwiftUI

struct HomeView: View {
	@StateObject var viewModel: HomeViewModel

	init(homeViewModel: HomeViewModel) {
		self._viewModel = StateObject(wrappedValue: homeViewModel)
	}

	var body: some View {
		NavigationView {

			VStack {
				CatFactListView(catFactListViewModel: self.viewModel.createCatFactListViewModel())
			}
			.alert("", isPresented: self.$viewModel.error) {
				Button("OK") {
					self.viewModel.error = false
					self.viewModel.loadingState = nil
				}
			} message: {
				Text(self.viewModel.creatingErrorAlertMessage)
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					if case .inProgress = self.viewModel.loadingState {
						ProgressView()
					} else {
						Button {
							self.viewModel.getRandomCatFact()
						} label: {
							Image(systemName: "plus")
						}
					}
				}
			}
		}
	}
}
