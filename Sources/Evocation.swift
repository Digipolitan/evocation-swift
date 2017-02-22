//
//  Evocation.swift
//  Evocation
//
//  Created by Julien Sarazin on 26/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

public enum EvocationError<T>: Error {
	case rulesNotDefined(for: Strategy.Action, with: T.Type)
	case proxyNotFound(for: T.Type)
	case missingRepository(type: Evocation.RepositoryType, for: T.Type)
}

/**
* Singleton used as manager to register repositories for each model.
*/
open class Evocation {

    public enum RepositoryType {
		case remote
		case local
	}

	public static let shared = Evocation()

    private init() {
		self.proxies = [String: Any]()
	}

	fileprivate var proxies: [String: Any]

	/**
	Create a Proxy by registering a model.
	*/
	public func register<T>(for type: T.Type) -> Proxy<T> {
		let proxy = Proxy<T>()
		self.proxies[String(describing: T.self)] = proxy
		return proxy
	}

	/**
	Fetch and return the first item matching the criteria.
	*/
	public func findOne<T>(model: T.Type, criteria: [String: Any]?, callback: @escaping (Result<T>) -> (Void)) {
		guard let proxy = self.proxies[String(describing: T.self)] as? Proxy<T> else {
			let result = Result<T>(error: EvocationError.proxyNotFound(for: T.self))
			return callback(result)
		}

		guard let rule = proxy.strategy.rules[.findOne] else {
			// no rule found.
			// can't start the algorithm
			let result = Result<T>(error: EvocationError.rulesNotDefined(for: .findOne, with: T.self))
			return callback(result)
		}

		guard let target = rule.target == .remote ? proxy.remote : proxy.local else {
			let result = Result<T>(error: EvocationError.missingRepository(type: rule.target, for: T.self))
			return callback(result)
		}

		target.findOne(criteria: criteria) { (result) -> (Void) in
			guard result.error == nil else {
				// an error occured, or no data has been found,.
				// setting the initial target result in the key "_raw"
				result.metadata[rule.target] = ["_raw": result]
				if rule.fallback != nil {
					// since we haven't been able to get data from the remote
					// and a fallback has been set
					// we'll try to get data from the fallback
					guard let fallback = rule.fallback! == .remote ? proxy.remote : proxy.local else {
						// but no fallback repository registered ...
						result.error = EvocationError.missingRepository(type: rule.fallback!, for: T.self)
						return callback(result)
					}

					return fallback.findOne(criteria: criteria, completion: { (fallbackResult) -> (Void) in
						fallbackResult.metadata[rule.target] = result.metadata[rule.target]
						return callback(fallbackResult)
					})
				}

				// we don't have fallback
				return callback(result)
			}

			// setting the initial target result in the key "_raw"
			result.metadata[rule.target] = ["_raw": result]

			guard rule.synchronize, let data = result.data else {
				// synchronize disabled, or no data found => job done.
				return callback(result)
			}

			let neededRepositoryType: Evocation.RepositoryType = rule.target == .local ? .remote : .local
			guard let repository = neededRepositoryType == .remote ? proxy.remote : proxy.local else {
				// no repository registered == ERROR
				result.error = EvocationError.missingRepository(type: neededRepositoryType, for: T.self)
				return callback(result)
			}

			repository.storeOrUpdate(models: [data], completion: { (syncResult) -> (Void) in
				result.metadata[neededRepositoryType] = ["_raw": syncResult]
				// in any case we set the local error in the global result
				result.error = syncResult.error

				return callback(result)
			})
		}
	}

	/**
	Fetch and return all items matching the criteria.
	*/
	public func find<T>(model: T.Type, criteria: [String: Any]? = nil, callback: @escaping (Result<[T]>) -> (Void)) {
		guard let proxy = self.proxies[String(describing: T.self)] as? Proxy<T> else {
			let result = Result<[T]>(error: EvocationError.proxyNotFound(for: T.self))
			return callback(result)
		}

		guard let rule = proxy.strategy.rules[.find] else {
			// no rule found.
			// can't start the algorithm
			let result = Result<[T]>(error: EvocationError.rulesNotDefined(for: .find, with: T.self))
			return callback(result)
		}

		guard let target = rule.target == .remote ? proxy.remote : proxy.local else {
			let result = Result<[T]>(error: EvocationError.missingRepository(type: rule.target, for: T.self))
			return callback(result)
		}

		target.find(criteria: criteria) { (result) -> (Void) in
			guard result.error == nil else {
				// an error occured.
				// setting the initial target result in the key "_raw"
				result.metadata[rule.target] = ["_raw": result]
				if rule.fallback != nil {
					// since we haven't been able to get data from the remote
					// and a fallback has been set
					// we'll try to get data from the fallback
					guard let fallback = rule.fallback! == .remote ? proxy.remote : proxy.local else {
						// but no fallback repository registered ...
						result.error = EvocationError.missingRepository(type: rule.fallback!, for: T.self)
						return callback(result)
					}

					return fallback.find(criteria: criteria, completion: { (fallbackResult) -> (Void) in
						fallbackResult.metadata[rule.target] = result.metadata[rule.target]
						return callback(fallbackResult)
					})
				}

				// we don't have fallback
				return callback(result)
			}

			// setting the initial target result in the key "_raw"
			result.metadata[rule.target] = ["_raw": result]

			guard rule.synchronize, let data = result.data, data.count > 0 else {
				// synchronize disabled, or no data found => job done.
				return callback(result)
			}

			let neededRepositoryType: Evocation.RepositoryType = rule.target == .local ? .remote : .local
			guard let repository = neededRepositoryType == .remote ? proxy.remote : proxy.local else {
				// no repository registered == ERROR
				result.error = EvocationError.missingRepository(type: neededRepositoryType, for: T.self)
				return callback(result)
			}

			repository.storeOrUpdate(models: data, completion: { (syncResult) -> (Void) in
				result.metadata[neededRepositoryType] = ["_raw": syncResult]
				// in any case we set the local error in the global result
				result.error = syncResult.error

				return callback(result)
			})
		}
	}

	/**
	Create and persist a collection of T.
	*/
	public func store<T>(_ models: [T], callback: @escaping (Result<[T]>) -> (Void)) {
		guard let proxy = self.proxies[String(describing: T.self)] as? Proxy<T> else {
			let result = Result<[T]>(error: EvocationError.proxyNotFound(for: T.self))
			return callback(result)
		}

		guard let rule = proxy.strategy.rules[.store] else {
			// no rule found.
			// can't start the algorithm
			let result = Result<[T]>(error: EvocationError.rulesNotDefined(for: .store, with: T.self))
			return callback(result)
		}

		guard let target = rule.target == .remote ? proxy.remote : proxy.local else {
			let result = Result<[T]>(error: EvocationError.missingRepository(type: rule.target, for: T.self))
			return callback(result)
		}

		target.store(models: models) { (result) -> (Void) in
			guard result.error == nil else {
				// an error occured.
				// setting the initial target result in the key "_raw"
				result.metadata[rule.target] = ["_raw": result]
				if rule.fallback != nil {
					// since we haven't been able to get data from the remote
					// and a fallback has been set
					// we'll try to get data from the fallback
					guard let fallback = rule.fallback! == .remote ? proxy.remote : proxy.local else {
						// but no fallback repository registered ...
						result.error = EvocationError.missingRepository(type: rule.fallback!, for: T.self)
						return callback(result)
					}

					return fallback.store(models: models, completion: { (fallbackResult) -> (Void) in
						fallbackResult.metadata[rule.target] = result.metadata[rule.target]
						return callback(fallbackResult)
					})
				}

				// we don't have fallback
				return callback(result)
			}

			// setting the initial target result in the key "_raw"
			result.metadata[rule.target] = ["_raw": result]

			guard rule.synchronize, let data = result.data, data.count > 0 else {
				// synchronize disabled, or no data  => job done.
				return callback(result)
			}

			let neededRepositoryType: Evocation.RepositoryType = rule.target == .local ? .remote : .local
			guard let repository = neededRepositoryType == .remote ? proxy.remote : proxy.local else {
				// no repository registered == ERROR
				result.error = EvocationError.missingRepository(type: neededRepositoryType, for: T.self)
				return callback(result)
			}

			repository.storeOrUpdate(models: data, completion: { (syncResult) -> (Void) in
				result.metadata[neededRepositoryType] = ["_raw": syncResult]
				// in any case we set the local error in the global result
				result.error = syncResult.error

				return callback(result)
			})
		}
	}

	/**
	Create and persist an instance of a T.
	*/
	public func storeOne<T>(_ model: T, callback: @escaping (Result<T>) -> (Void)) {
		guard let proxy = self.proxies[String(describing: T.self)] as? Proxy<T> else {
			let result = Result<T>(error: EvocationError.proxyNotFound(for: T.self))
			return callback(result)
		}

		guard let rule = proxy.strategy.rules[.storeOne] else {
			// no rule found.
			// can't start the algorithm
			let result = Result<T>(error: EvocationError.rulesNotDefined(for: .storeOne, with: T.self))
			return callback(result)
		}

		guard let target = rule.target == .remote ? proxy.remote : proxy.local else {
			let result = Result<T>(error: EvocationError.missingRepository(type: rule.target, for: T.self))
			return callback(result)
		}

		target.storeOne(model: model) { (result) -> (Void) in
			guard result.error == nil else {
				// an error occured.
				// setting the initial target result in the key "_raw"
				result.metadata[rule.target] = ["_raw": result]
				if rule.fallback != nil {
					// since we haven't been able to get data from the remote
					// and a fallback has been set
					// we'll try to get data from the fallback
					guard let fallback = rule.fallback! == .remote ? proxy.remote : proxy.local else {
						// but no fallback repository registered ...
						result.error = EvocationError.missingRepository(type: rule.fallback!, for: T.self)
						return callback(result)
					}

					return fallback.storeOne(model: model, completion: { (fallbackResult) -> (Void) in
						fallbackResult.metadata[rule.target] = result.metadata[rule.target]
						return callback(fallbackResult)
					})
				}

				// we don't have fallback
				return callback(result)
			}

			// setting the initial target result in the key "_raw"
			result.metadata[rule.target] = ["_raw": result]

			guard rule.synchronize, let data = result.data else {
				// synchronize disabled, or no data => job done.
				return callback(result)
			}

			let neededRepositoryType: Evocation.RepositoryType = rule.target == .local ? .remote : .local
			guard let repository = neededRepositoryType == .remote ? proxy.remote : proxy.local else {
				// no repository registered == ERROR
				result.error = EvocationError.missingRepository(type: neededRepositoryType, for: T.self)
				return callback(result)
			}

			repository.storeOrUpdate(models: [data], completion: { (syncResult) -> (Void) in
				result.metadata[neededRepositoryType] = ["_raw": syncResult]
				// in any case we set the local error in the global result
				result.error = syncResult.error

				return callback(result)
			})
		}
	}

	/**
	Update an instance of T
	*/
	public func update<T>(_ models: [T], callback: @escaping (Result<[T]>) -> (Void)) {
		guard let proxy = self.proxies[String(describing: T.self)] as? Proxy<T> else {
			let result = Result<[T]>(error: EvocationError.proxyNotFound(for: T.self))
			return callback(result)
		}

		guard let rule = proxy.strategy.rules[.update] else {
			// no rule found.
			// can't start the algorithm
			let result = Result<[T]>(error: EvocationError.rulesNotDefined(for: .update, with: T.self))
			return callback(result)
		}

		guard let target = rule.target == .remote ? proxy.remote : proxy.local else {
			let result = Result<[T]>(error: EvocationError.missingRepository(type: rule.target, for: T.self))
			return callback(result)
		}

		target.update(models: models) { (result) -> (Void) in
			guard result.error == nil else {
				// an error occured.
				// setting the initial target result in the key "_raw"
				result.metadata[rule.target] = ["_raw": result]
				if rule.fallback != nil {
					// since we haven't been able to get data from the remote
					// and a fallback has been set
					// we'll try to get data from the fallback
					guard let fallback = rule.fallback! == .remote ? proxy.remote : proxy.local else {
						// but no fallback repository registered ...
						result.error = EvocationError.missingRepository(type: rule.fallback!, for: T.self)
						return callback(result)
					}

					return fallback.update(models: models, completion: { (fallbackResult) -> (Void) in
						fallbackResult.metadata[rule.target] = result.metadata[rule.target]
						return callback(fallbackResult)
					})
				}

				// we don't have fallback
				return callback(result)
			}

			// setting the initial target result in the key "_raw"
			result.metadata[rule.target] = ["_raw": result]

			guard rule.synchronize, let data = result.data, data.count > 0 else {
				// synchronize disabled, or no data  => job done.
				return callback(result)
			}

			let neededRepositoryType: Evocation.RepositoryType = rule.target == .local ? .remote : .local
			guard let repository = neededRepositoryType == .remote ? proxy.remote : proxy.local else {
				// no repository registered == ERROR
				result.error = EvocationError.missingRepository(type: neededRepositoryType, for: T.self)
				return callback(result)
			}

			repository.storeOrUpdate(models: data, completion: { (syncResult) -> (Void) in
				result.metadata[neededRepositoryType] = ["_raw": syncResult]
				// in any case we set the local error in the global result
				result.error = syncResult.error

				return callback(result)
			})
		}
	}

	/**
	Update an instance of T
	*/
	public func updateOne<T>(_ model: T, callback: (Result<T>) -> (Void)) {
		guard let proxy = self.proxies[String(describing: T.self)] as? Proxy<T> else {
			let result = Result<T>(error: EvocationError.proxyNotFound(for: T.self))
			return callback(result)
		}

		guard let rule = proxy.strategy.rules[.updateOne] else {
			// no rule found.
			// can't start the algorithm
			let result = Result<T>(error: EvocationError.rulesNotDefined(for: .updateOne, with: T.self))
			return callback(result)
		}

		guard let target = rule.target == .remote ? proxy.remote : proxy.local else {
			let result = Result<T>(error: EvocationError.missingRepository(type: rule.target, for: T.self))
			return callback(result)
		}

		target.updateOne(model: model) { (result) -> (Void) in
			guard result.error == nil else {
				// an error occured.
				// setting the initial target result in the key "_raw"
				result.metadata[rule.target] = ["_raw": result]
				if rule.fallback != nil {
					// since we haven't been able to get data from the remote
					// and a fallback has been set
					// we'll try to get data from the fallback
					guard let fallback = rule.fallback! == .remote ? proxy.remote : proxy.local else {
						// but no fallback repository registered ...
						result.error = EvocationError.missingRepository(type: rule.fallback!, for: T.self)
						return callback(result)
					}

					return fallback.updateOne(model: model, completion: { (fallbackResult) -> (Void) in
						fallbackResult.metadata[rule.target] = result.metadata[rule.target]
						return callback(fallbackResult)
					})
				}

				// we don't have fallback
				return callback(result)
			}

			// setting the initial target result in the key "_raw"
			result.metadata[rule.target] = ["_raw": result]

			guard rule.synchronize, let data = result.data else {
				// synchronize disabled, or no data => job done.
				return callback(result)
			}

			let neededRepositoryType: Evocation.RepositoryType = rule.target == .local ? .remote : .local
			guard let repository = neededRepositoryType == .remote ? proxy.remote : proxy.local else {
				// no repository registered == ERROR
				result.error = EvocationError.missingRepository(type: neededRepositoryType, for: T.self)
				return callback(result)
			}

			repository.storeOrUpdate(models: [data], completion: { (syncResult) -> (Void) in
				result.metadata[neededRepositoryType] = ["_raw": syncResult]
				// in any case we set the local error in the global result
				result.error = syncResult.error

				return callback(result)
			})
		}
	}

	/*
	Remove items matching the criteria.
	*/
	public func remove<T>(_ models: [T], callback: (Result<[T]>) -> (Void)) {
		guard let proxy = self.proxies[String(describing: T.self)] as? Proxy<T> else {
			let result = Result<[T]>(error: EvocationError.proxyNotFound(for: T.self))
			return callback(result)
		}

		guard let rule = proxy.strategy.rules[.remove] else {
			// no rule found.
			// can't start the algorithm
			let result = Result<[T]>(error: EvocationError.rulesNotDefined(for: .remove, with: T.self))
			return callback(result)
		}

		guard let target = rule.target == .remote ? proxy.remote : proxy.local else {
			let result = Result<[T]>(error: EvocationError.missingRepository(type: rule.target, for: T.self))
			return callback(result)
		}

		target.remove(models: models) { (result) -> (Void) in
			guard result.error == nil else {
				// an error occured.
				// setting the initial target result in the key "_raw"
				result.metadata[rule.target] = ["_raw": result]
				if rule.fallback != nil {
					// since we haven't been able to get data from the remote
					// and a fallback has been set
					// we'll try to get data from the fallback
					guard let fallback = rule.fallback! == .remote ? proxy.remote : proxy.local else {
						// but no fallback repository registered ...
						result.error = EvocationError.missingRepository(type: rule.fallback!, for: T.self)
						return callback(result)
					}

					return fallback.remove(models: models, completion: { (fallbackResult) -> (Void) in
						fallbackResult.metadata[rule.target] = result.metadata[rule.target]
						return callback(fallbackResult)
					})
				}

				// we don't have fallback
				return callback(result)
			}

			// setting the initial target result in the key "_raw"
			result.metadata[rule.target] = ["_raw": result]

			guard rule.synchronize else {
				// synchronize disabled, or no data => job done.
				return callback(result)
			}

			let neededRepositoryType: Evocation.RepositoryType = rule.target == .local ? .remote : .local
			guard let repository = neededRepositoryType == .remote ? proxy.remote : proxy.local else {
				// no repository registered == ERROR
				result.error = EvocationError.missingRepository(type: neededRepositoryType, for: T.self)
				return callback(result)
			}

			repository.remove(models: models, completion: { (syncResult) -> (Void) in
				result.metadata[neededRepositoryType] = ["_raw": syncResult]
				// in any case we set the local error in the global result
				result.error = syncResult.error

				return callback(result)
			})
		}
	}
}
