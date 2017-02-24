//
//  Strategy.swift
//  Evocation
//
//  Created by Julien Sarazin on 30/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

public enum StrategyError: Error {
	case invalidRule
	case incompleteConfiguration
}

open class Strategy {

	public struct Rule {
		private(set) var synchronize: Bool
		private(set) var target: Evocation.RepositoryType
		private(set) var fallback: Evocation.RepositoryType?

		init(target: Evocation.RepositoryType = .remote, fallback: Evocation.RepositoryType? = nil, synchronize: Bool = true) throws {
			self.target = target
			self.fallback = fallback
			self.synchronize = synchronize

			if self.fallback != nil && self.target == self.fallback {
				throw(StrategyError.invalidRule)
			}
		}
	}

	private static let ActionsCount = 8

	public enum Action: Int {
		case find
		case findOne
		case store
		case storeOne
		case update
		case updateOne
		case remove
		case removeOne
	}

	private(set) var rules: [Action: Rule]

	public init(rules: [Action: Rule]) throws {
		self.rules = rules
		if self.rules.keys.count < Strategy.ActionsCount {
			throw(StrategyError.incompleteConfiguration)
		}
	}

	public static func `default`() -> Strategy {
		guard
            let localFirst = try? Rule(target: .local, fallback: .remote),
            let remoteFirst = try? Rule(fallback: .local)
            else {
            fatalError("Rules cannot be nil, report an error to @Digipolitan")
        }
        let rules: [Action: Rule] = [
            .find: remoteFirst,
            .findOne: remoteFirst,
            .store: localFirst,
            .storeOne: localFirst,
            .update: localFirst,
            .updateOne: localFirst,
            .remove: remoteFirst,
            .removeOne: remoteFirst
        ]
        if let strategy = try? Strategy(rules: rules) {
            return strategy
        }
        fatalError("Strategy cannot be nil, report an error to @Digipolitan")
	}
}
