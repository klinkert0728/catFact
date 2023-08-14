//
//  DBRecordProtocol.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation
import GRDB

public protocol DBRecordProtocol: PersistableRecord, FetchableRecord, Identifiable {}
