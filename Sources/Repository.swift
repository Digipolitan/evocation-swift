//
//  Repository.swift
//  Evocation
//
//  Created by Julien Sarazin on 26/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

public protocol Repository {

	associatedtype ModelType

	func find(criteria: [String: Any]?, completion: (Result<[ModelType]>) -> (Void))
	func findOne(criteria: [String: Any]?, completion: (Result<ModelType>) -> (Void))

	func store(models: [ModelType], completion: (Result<[ModelType]>) -> (Void))
	func storeOne(model: ModelType, completion: (Result<ModelType>) -> (Void))

	func update(models: [ModelType], completion: (Result<[ModelType]>) -> (Void))
	func updateOne(model: ModelType, completion: (Result<ModelType>) -> (Void))

	func remove(models: [ModelType], completion: (Result<[ModelType]>) -> (Void))
	func storeOrUpdate(models: [ModelType], completion: (Result<[ModelType]>) -> (Void))
}

public enum RepositoryType {
	case local
	case remote
}

open class AnyRepository<T> : Repository {

	public typealias ModelType = T

    private var repository: Any?

	private var _find: (([String: Any]?, (Result<[T]>) -> (Void)) -> Void)
	private var _findOne: (([String: Any]?, (Result<T>) -> (Void)) -> Void)

	private var _store: (([T], (Result<[T]>) -> (Void)) -> Void)
	private var _storeOne: ((T, (Result<T>) -> (Void)) -> Void)

	private var _update: (([T], (Result<[T]>) -> (Void)) -> Void)
	private var _updateOne: ((T, (Result<T>) -> (Void)) -> Void)

	private var _storeOrUpdate: (([T], (Result<[T]>) -> (Void)) -> Void)

	private var _remove: (([T], (Result<[T]>) -> (Void)) -> Void)

	public required init<R: Repository>(_ repository: R) where R.ModelType == T {
		self.repository = repository
		self._find = repository.find
		self._findOne = repository.findOne
		self._store = repository.store
		self._storeOne = repository.storeOne
		self._update = repository.update
		self._updateOne = repository.updateOne

		self._remove = repository.remove
		self._storeOrUpdate = repository.storeOrUpdate
	}

	// MARK: Protocol implementation
	public func findOne(criteria: [String : Any]?, completion: (Result<T>) -> (Void)) {
		return self._findOne(criteria, completion)
	}

	public func find(criteria: [String : Any]?, completion: (Result<[T]>) -> (Void)) {
		return self._find(criteria, completion)
	}

	public func store(models: [T], completion: (Result<[T]>) -> (Void)) {
		return self._store(models, completion)
	}

	public func storeOne(model: T, completion: (Result<T>) -> (Void)) {
		return self._storeOne(model, completion)
	}

	public func update(models: [T], completion: (Result<[T]>) -> (Void)) {
		return self._update(models, completion)
	}

	public func updateOne(model: T, completion: (Result<T>) -> (Void)) {
		return self._updateOne(model, completion)
	}

	public func storeOrUpdate(models: [T], completion: (Result<[T]>) -> (Void)) {
		return self._storeOrUpdate(models, completion)
	}

	public func remove(models: [T], completion: (Result<[T]>) -> (Void)) {
		return self._remove(models, completion)
	}
}
