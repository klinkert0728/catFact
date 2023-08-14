//
//  CatFactAPIServiceSessionProtocol.swift
//  
//
//  Created by Daniel Klinkert on 14.08.23.
//

import Foundation

protocol CatFactAPIServiceSessionProtocol {

	func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
