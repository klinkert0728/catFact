//
//  RESTAPIPagination.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation

// MARK: - RESTAPIPagination
/// Custom implementation that determines if the `FactRestAPIResponse` has more pages available.
enum RESTAPIPagination {
	case firstPage
	case page(at: String)
	case noMorePagesAvailable

	var pageValue: URL? {
		switch self {
		case .firstPage, .noMorePagesAvailable:
			return nil
		case .page(let pageValue):
			return URL(string: pageValue)
		}
	}
}
