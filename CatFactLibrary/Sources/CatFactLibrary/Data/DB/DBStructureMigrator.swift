//
//  DBStructureMigrator.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import GRDB

internal enum DBStructureMigrator {
	internal static func performMigrations(on databaseQueue: DatabaseQueue) throws {
		var migrator = DatabaseMigrator()
		self.addMigrationV1(to: &migrator)

		try migrator.migrate(databaseQueue)
	}

	private static func addMigrationV1(to migrator: inout DatabaseMigrator) {
		migrator.registerMigration("v1") { (database: Database) in
			try database.create(table: CatFact.databaseTableName, ifNotExists: true) { (definition: TableDefinition) in
				definition.column(CatFact.Columns.identifier.name, .text).unique().notNull().indexed().primaryKey()
				definition.column(CatFact.Columns.fact.name, .text)
				definition.column(CatFact.Columns.creationDate.name, .numeric)
				definition.column(CatFact.Columns.length.name, .numeric).notNull()
			}
		}
	}
}
