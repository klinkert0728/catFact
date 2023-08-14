//
//  FactRestAPIResponse.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation


// MARK: - FactRestAPIResponse
struct FactRestAPIResponse<T: Decodable> {
	let entries: [T]
	let nextPage: RESTAPIPagination

	private enum CodingKeys: String, CodingKey {
		case entries = "data"
		case nextPage = "next_page_url"
	}
}

extension FactRestAPIResponse: Decodable {

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.entries = try container.decode([T].self, forKey: .entries)

		let nextPage = try container.decodeIfPresent(String.self, forKey: .nextPage)
		if let nextPage = nextPage {
			self.nextPage = .page(at: nextPage)
		} else {
			self.nextPage = .noMorePagesAvailable
		}
	}
}
