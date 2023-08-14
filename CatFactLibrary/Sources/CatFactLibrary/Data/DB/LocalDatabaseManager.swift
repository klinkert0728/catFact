//
//  LocalDatabaseManager.swift
//
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Combine
import Foundation
import GRDB
import CatLogger


// MARK: - LocalDatabaseManagerBatchProtocol
protocol LocalDatabaseManagerBatchProtocol {
	@discardableResult
	/// Delete records by id with a batche request.
	/// - Parameters:
	///   - ids: ids to delete
	///   - _: type of record to delete
	/// - Returns: number of records deleted.
	func delete<T>(ids: [T.ID], of _: T.Type) throws -> Int where T: DBRecordProtocol, T.ID: DatabaseValueConvertible

	/// Delete all records of the database. with a batche request.
	/// - Parameter of: Type of record to delete.
	func deleteAll<T: DBRecordProtocol>(of: T.Type) throws

	func save<T: DBRecordProtocol>(_ objects: [T]) throws
}

// MARK: - DeleteLocalDatabaseManagerProtocol
protocol DeleteLocalDatabaseManagerProtocol {

	func delete<T>(ids: [T.ID], of type: T.Type) async throws where T: DBRecordProtocol, T.ID: DatabaseValueConvertible

	func delete<T: DBRecordProtocol>(_ object: T) async throws -> Bool

	func deleteAll<T: DBRecordProtocol>(of type: T.Type) async throws
}

// MARK: - DeleteLocalDatabaseManagerProtocol
protocol PublisherLocalDatabaseManagerProtocol {

	/// Creates a publisher for the localdDatabase using the passed parameters
	/// - Parameters:
	///   - type: type of Record to listen too
	///   - expression: fetch query
	///   - order: desired order.
	///   - limit: limit the publisher results
	///   - offset: adds the possibility to start after an index
	/// - Returns: Publisher for the Database Record.
	func allContinuous<T: DBRecordProtocol>(of type: T.Type, where expression: [LocalDatabaseFetchOption], order: LocalDatabaseSortOption?, limit: Int, offset: Int?) -> AnyPublisher<[T], Error>
}

// MARK: - DeleteLocalDatabaseManagerProtocol
protocol SaveLocalDatabaseManagerProtocol {
	func save<T: DBRecordProtocol>(_ objects: [T]) async throws
}

// MARK: - BatchLocalDatabaseManagerProtocol
protocol BatchLocalDatabaseManagerProtocol {
	func batch(closure: @escaping (LocalDatabaseManagerBatchProtocol) throws -> Void) async throws
}

// MARK: - LocalDatabaseManagerProtocol
protocol LocalDatabaseManagerProtocol: DeleteLocalDatabaseManagerProtocol, PublisherLocalDatabaseManagerProtocol, SaveLocalDatabaseManagerProtocol, BatchLocalDatabaseManagerProtocol {

	func all<T: DBRecordProtocol>(of type: T.Type, where expressions: [LocalDatabaseFetchOption]) async throws -> [T]
}


// MARK: - LocalDatabaseManager implementation.
struct LocalDatabaseManager: LocalDatabaseManagerProtocol {

	public enum DatabaseLocation {
		case fileSystem(URL)
		case memory

		fileprivate var path: String {
			switch self {
			case .fileSystem(let url):
				return url.absoluteURL.path
			case .memory:
				return ":memory:"
			}
		}
	}

	private let queue: DatabaseQueue

	init(location: DatabaseLocation, logCategory: CatLogger.CatLoggerCategory?) {
		var config = Configuration()
		config.foreignKeysEnabled = true

		if let logCategory {
			config.prepareDatabase { (database: Database) in
				database.trace { logCategory.debug("\($0)") }
			}
		}

		let databasePath = location.path
		CatLogger.catFactLibrary.database.info("local datasbase path: \(databasePath)")

		// This is bad and should be avoided by wrapping queue object instead of using the GRDB implementation.
		self.queue = try! DatabaseQueue(path: databasePath, configuration: config)

		do {
			// Setup and/or migrate table structures
			try DBStructureMigrator.performMigrations(on: self.queue)
		} catch {
			CatLogger.catFactLibrary.database.error("failed to perform migrations")
		}
	}

	func all<T>(of type: T.Type, where expressions: [LocalDatabaseFetchOption]) async throws -> [T] where T : DBRecordProtocol {
		try await self.all(of: type, where: nil)
	}

	func allContinuous<T>(of type: T.Type, where expression: [LocalDatabaseFetchOption], order: LocalDatabaseSortOption?, limit: Int, offset: Int?) -> AnyPublisher<[T], Error> where T : DBRecordProtocol {
		let orderParams: SQLOrdering? = {
			guard let order else {
				return nil
			}

			switch order {
			case .ascending(let column):
				return column.asc
			case .descending(let column):
				return column.desc
			}
		}()

		guard let value = try? self.apply(options: expression) else {
			return self.allContinuous(of: type, where: nil, order: orderParams, limit: limit, offset: offset)
		}

		return self.allContinuous(of: type, where: value, order: orderParams, limit: limit, offset: offset)
	}

	/// Apply the query from the service
	/// - Parameter options: passed options to query the database
	/// - Returns: Returns `SQLExpression` to query the the database.
	private func apply(options: [LocalDatabaseFetchOption]) throws -> SQLExpression? {
		var resultQuery = [SQLExpression]()
		for currentOption in options {
			switch currentOption {
			case .whereEquals(let field, let value):
				resultQuery.append(Column(field.name) == value)
			case .whereNotEquals(let field, let value):
				resultQuery.append(Column(field.name) != value)
			case .all:
				continue
			}
		}

		return resultQuery.joined(operator: .and)
	}
}

// MARK: - Saving
extension LocalDatabaseManager {
	func save<T: DBRecordProtocol>(_ objects: [T]) async throws {
		guard objects.isEmpty == false else {
			return
		}

		try await self.batch {
			do {
				try $0.save(objects)
			} catch {
				throw LocalDatabaseError.failedToSave
			}
		}
	}
}

// MARK: - Deleting
extension LocalDatabaseManager {
	func delete<T>(ids: [T.ID], of _: T.Type) async throws where T: DBRecordProtocol, T.ID: DatabaseValueConvertible {
		guard ids.isEmpty == false else {
			return
		}

		try await self.batch {
			_ = try $0.delete(ids: ids, of: T.self)
		}
	}

	func delete<T: DBRecordProtocol>(_ object: T) async throws -> Bool {
		try await self.queue.write { database -> Bool in
			try object.delete(database)
		}
	}

	func deleteAll<T: DBRecordProtocol>(of _: T.Type) async throws {
		_ = try await self.queue.write { database in
			try T.deleteAll(database)
		}
	}
}

// MARK: - Reading
private extension LocalDatabaseManager {

	private enum DBRecordProtocolFetch {
		static func countElements<T: DBRecordProtocol>(database: Database, type: T.Type, expression: SQLExpression?) throws -> Int {
			guard let expression = expression else {
				return try type.fetchCount(database)
			}

			return try type.filter(expression).fetchCount(database)
		}

		/// Fetches one element from the database matching passed parameters
		/// - Parameters:
		///   - database: database to fetch element from
		///   - type: type of record
		///   - expression: expression to filter the element for
		/// - Returns: Fetched record.
		static func first<T: DBRecordProtocol>(database: Database, type: T.Type, expression: SQLExpression?) throws -> T? {
			guard let expression = expression else {
				return try type.fetchOne(database)
			}

			return try type.filter(expression).fetchOne(database)
		}

		/// Fetches a collection of items matching the passed parameters.
		/// - Parameters:
		///   - database: database to fetch element from
		///   - type: type of record
		///   - expression: expression to filter the element for
		///   - order: desired order
		///   - limit: limit value for the query
		///   - offset: start after offset
		/// - Returns: Collection of records.
		static func all<T: DBRecordProtocol>(database: Database, type: T.Type, expression: SQLExpression?, order: SQLOrderingTerm? = nil, limit: Int? = nil, offset: Int? = nil) throws -> [T] {
			guard let expression = expression else {
				return try type.fetchAll(database)
			}

			if let order {
				return try type.filter(expression)
					.order(order)
					.limit(limit ?? 20, offset: offset)
					.fetchAll(database)
			} else {
				let limit = limit ?? 20
				return try type.filter(expression).limit(limit, offset: offset).fetchAll(database)
			}
		}
	}

	func all<T: DBRecordProtocol>(of type: T.Type, where expression: SQLExpression?) throws -> [T] {
		try self.queue.read { database in
			try DBRecordProtocolFetch.all(database: database, type: type, expression: expression)
		}
	}

	func all<T: DBRecordProtocol>(of type: T.Type, where expression: SQLExpression?) async throws -> [T] {
		try await self.queue.read { database -> [T] in
			try DBRecordProtocolFetch.all(database: database, type: type, expression: expression)
		}
	}

	func allContinuous<T: DBRecordProtocol>(of type: T.Type, where expression: SQLExpression?, order: SQLOrderingTerm? = nil, limit: Int? = nil, offset: Int? = nil) -> AnyPublisher<[T], Error> {
		ValueObservation.tracking { (database: Database) in
			try DBRecordProtocolFetch.all(database: database, type: type, expression: expression, order: order, limit: limit, offset: offset)
		}
		.publisher(in: self.queue)
		.eraseToAnyPublisher()
	}
}

// MARK: - Transactions
extension LocalDatabaseManager {
	func batch(closure: @escaping (LocalDatabaseManagerBatchProtocol) throws -> Void) async throws {
		try await self.queue.write { database in
			try closure(Self.Batch(using: database))
		}
	}

	struct Batch: LocalDatabaseManagerBatchProtocol {
		private let database: Database

		init(using database: Database) {
			self.database = database
		}

		func delete<T>(ids: [T.ID], of _: T.Type) throws -> Int where T: DBRecordProtocol, T.ID: DatabaseValueConvertible {
			try T.deleteAll(self.database, keys: ids)
		}

		func save<T: DBRecordProtocol>(_ objects: [T]) throws {
			for object in objects {
				try object.insert(self.database, onConflict: .replace)
			}
		}

		func deleteAll<T: DBRecordProtocol>(of _: T.Type) throws {
			try T.deleteAll(self.database)
		}
	}
}

// MARK: - Private Helpers
private extension Array where Element == any DBRecordProtocol.Type {
	func deleteAll(in database: Database) throws -> Int {
		var deletedRecordCount = 0

		for entityToEmpty in self {
			deletedRecordCount += try entityToEmpty.deleteAll(database)
		}

		return deletedRecordCount
	}

	func remove(_ recordTypesToRemove: [any DBRecordProtocol.Type]) -> Self {
		self.filter { (recordType: DBRecordProtocol.Type) -> Bool in
			let contains = recordTypesToRemove.contains { (recordTypeToRemove: any DBRecordProtocol.Type) -> Bool in
				recordTypeToRemove.databaseTableName == recordType.databaseTableName
			}

			return contains == false
		}
	}

	private func contains(_ recordType: any DBRecordProtocol.Type) -> Bool {
		self.contains { (recordTypeToSearch: DBRecordProtocol.Type) -> Bool in
			recordTypeToSearch.databaseTableName == recordType.databaseTableName
		}
	}
}
