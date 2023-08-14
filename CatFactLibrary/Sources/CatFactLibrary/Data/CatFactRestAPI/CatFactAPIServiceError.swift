//
//  CatFactAPIServiceError.swift
//  
//
//  Created by Daniel Klinkert on 14.08.23.
//

import Foundation

/// Custom errors defined in the CatFact REST API.
public enum CatFactAPIServiceError: Error {
	case somethingWentWrong
	case badRequest

	init?(apiError: Error) {
		switch (apiError as NSError).code {
		case (400...499):
			self = .badRequest
		case (500...599):
			self = .somethingWentWrong
		default:
			return nil
		}
	}
}
