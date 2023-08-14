//
//  CatFactListView.swift
//  CatFact
//
//  Created by Daniel Klinkert on 13.08.23.
//

import SwiftUI

struct CatFactListView: View {
	@StateObject var viewModel: CatFactListViewModel

	init(catFactListViewModel: CatFactListViewModel) {
		self._viewModel = StateObject(wrappedValue: catFactListViewModel)
	}

	var body: some View {
		List {
			ForEach(self.viewModel.catFacts) { fact in
				let lastFact = fact.id == self.viewModel.catFacts.last?.id
				let firstFact = fact.id == self.viewModel.catFacts.first?.id
				HStack {
					Image(systemName: "globe")
						.imageScale(.large)
						.foregroundColor(.accentColor)

					Text("\(self.viewModel.catFacts.firstIndex(where: { $0.id == fact.id }) ?? 0)")
					Text(fact.fact)
				}
				.padding()
				.task {
					if lastFact, self.viewModel.limit <= self.viewModel.catFacts.count {
						await self.viewModel.fetchMorePages()
					} else if firstFact {
						self.viewModel.limit = 20
					}
				}
			}
		}
		.task {
			await self.viewModel.fetchCatFacts()
		}
	}
}
