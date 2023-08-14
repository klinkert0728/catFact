//
//  ThreadSafeDictionary.swift
//  
//
//  Created by Daniel Klinkert on 06.08.23.
//

import Foundation

internal class ThreadSafeDictionary<Key: Hashable, Value>: Collection {

	private var dictionary: [Key: Value]
	private let concurrentQueue = DispatchQueue(label: "Logging Queue", attributes: .concurrent)

	var startIndex: Dictionary<Key, Value>.Index {
		self.concurrentQueue.sync {
			return self.dictionary.startIndex
		}
	}

	var endIndex: Dictionary<Key, Value>.Index {
		self.concurrentQueue.sync {
			return self.dictionary.endIndex
		}
	}

	init(dict: [Key: Value] = [Key:Value]()) {
		self.dictionary = dict
	}

	func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
		self.concurrentQueue.sync {
			return self.dictionary.index(after: i)
		}
	}

	subscript(key: Key) -> Value? {
		get {
			self.concurrentQueue.sync {
				return self.dictionary[key]
			}
		}
		set(newValue) {
			self.concurrentQueue.async(flags: .barrier) { [weak self] in
				self?.dictionary[key] = newValue
			}
		}
	}

	// has implicit get
	subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
		self.concurrentQueue.sync {
			return self.dictionary[index]
		}
	}

	func removeValue(forKey key: Key) {
		self.concurrentQueue.async(flags: .barrier) { [weak self] in
			self?.dictionary.removeValue(forKey: key)
		}
	}

	func removeAll() {
		self.concurrentQueue.async(flags: .barrier) { [weak self] in
			self?.dictionary.removeAll()
		}
	}

}
