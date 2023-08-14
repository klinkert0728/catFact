//
//  LocalDatabaseFetchOption.swift
//
//
//  Created by Daniel Klinkert on 10.07.23.
//

import GRDB

// MARK: - LocalDatabaseFetchOption
/// Allows the Services to perform queries to the local database.
public enum LocalDatabaseFetchOption {
	case whereEquals(ColumnExpression, DatabaseValueConvertible)
	case whereNotEquals(ColumnExpression, DatabaseValueConvertible)
	case all
}

/// Allow the services to sort the localDatabase.
public enum LocalDatabaseSortOption {
	case ascending(ColumnExpression)
	case descending(ColumnExpression)
}

