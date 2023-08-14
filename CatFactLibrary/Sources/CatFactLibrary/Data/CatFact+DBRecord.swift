//
//  CatFact+DBRecord.swift
//  
//
//  Created by Daniel Klinkert on 13.08.23.
//

import Foundation
import GRDB

extension CatFact: DBRecordProtocol {
	public static let databaseTableName = "CatFacts"

	/// Definition of all database columns for a catFact
	public enum Columns: String, ColumnExpression, CaseIterable {
		case identifier = "id"
		case fact = "fact"
		case length = "length"
		case creationDate = "creationDate"
	}

	// swiftlint:disable:next function_body_length
	public init(row: Row) throws {
		self.init(fact: row[Columns.fact], length: row[Columns.length], creationDate: row[Columns.creationDate])
	}

	public func encode(to container: inout PersistenceContainer) throws {
		container[Columns.identifier] = self.id
		container[Columns.fact] = self.fact
		container[Columns.length] = self.length
		container[Columns.creationDate] = self.creationDate
	}
}
