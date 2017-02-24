//
//  CarRepositoryMock.swift
//  Evocation
//
//  Created by Julien Sarazin on 31/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

@testable import Evocation

class CarRepositoryMock: Repository {
	typealias ModelType = Car

	enum Mode {
		case success
		case failure
	}

	private(set) var findCallCount: UInt            = 0
	private(set) var findOneCallCount: UInt         = 0
	private(set) var storeCallCount: UInt           = 0
	private(set) var storeOneCallCount: UInt        = 0
	private(set) var updateCallCount: UInt          = 0
	private(set) var updateOneCallCount: UInt		= 0
	private(set) var storeOrUpdateCallCount: UInt	= 0
	private(set) var removeCallCount: UInt          = 0
	private(set) var removeOneCallCount: UInt       = 0

	private var intialMode: Mode
	private var mode: Mode
	private var type: Evocation.RepositoryType
	fileprivate var lastParameterUsed: AnyObject?

	init(type: Evocation.RepositoryType, mode: Mode = .success) {
		self.type = type
		self.intialMode = mode
		self.mode = mode
	}

	func set(mode: Mode) {
		self.mode = mode
	}

	func reset() {
		self.findCallCount		= 0
		self.findOneCallCount	= 0
		self.storeCallCount	= 0
		self.storeOneCallCount = 0
		self.updateCallCount	= 0
		self.updateOneCallCount = 0
		self.storeOrUpdateCallCount = 0
		self.removeCallCount = 0
		self.removeOneCallCount = 0

		self.mode = self.intialMode
	}

	func findOne(criteria: [String: Any]?, completion: (Result<Car>) -> (Void)) {
		self.findOneCallCount += 1
		self.lastParameterUsed = criteria as AnyObject?

		let data = Car.findOne(criteria: criteria)
		let error = self.mode == .failure ? NSError() : nil

		let result = Result<Car>(metadata: nil, origin: self.type, data: data, error: error)
		completion(result)
	}

	func find(criteria: [String: Any]?, completion: (Result<[Car]>) -> (Void)) {
		self.findCallCount += 1
		self.lastParameterUsed = criteria as AnyObject?

		let data = Car.find(criteria: criteria)
		let error = self.mode == .failure ? NSError() : nil

		let result = Result<[Car]>(metadata: nil, origin: self.type, data: data, error: error)
		completion(result)
	}

	func store(models: [Car], completion: (Result<[Car]>) -> (Void)) {
		self.storeCallCount += 1
		self.lastParameterUsed = models as AnyObject?

		let data = Car.store(cars: models)
		let error = self.mode == .failure ? NSError() : nil

		let result = Result<[Car]>(metadata: nil, origin: self.type, data: data, error: error)
		completion(result)
	}

	func storeOne(model: Car, completion: (Result<Car>) -> (Void)) {
		self.storeOneCallCount += 1
		self.lastParameterUsed = model

		let data = Car.storeOne(car: model)
		let error = self.mode == .failure ? NSError() : nil

		let result = Result<Car>(metadata: nil, origin: self.type, data: data, error: error)
		completion(result)
	}

	func update(models: [Car], completion: (Result<[Car]>) -> (Void)) {
		self.updateCallCount += 1
		self.lastParameterUsed = models as AnyObject?

		let data = Car.update(cars: models)
		let error = self.mode == .failure ? NSError() : nil

		let result = Result<[Car]>(metadata: nil, origin: self.type, data: data, error: error)
		completion(result)
	}

	func updateOne(model: Car, completion: (Result<Car>) -> (Void)) {
		self.updateOneCallCount += 1
		self.lastParameterUsed = model

		let data = Car.updateOne(car: model)
		let error = self.mode == .failure ? NSError() : nil

		let result = Result<Car>(metadata: nil, origin: self.type, data: data, error: error)
		completion(result)
	}

	func storeOrUpdate(models: [Car], completion: (Result<[Car]>) -> (Void)) {
		self.storeOrUpdateCallCount += 1
		self.lastParameterUsed = models as AnyObject?

		print("calling: storeOrUpdate -> \(models)")
		let results = Result<[Car]>(data: models)
		completion(results)
	}

	func remove(models: [Car], completion: (Result<[Car]>) -> (Void)) {
		self.removeCallCount += 1
		self.lastParameterUsed = models as AnyObject?

		let error = self.mode == .failure ? NSError() : nil
		let result = Result<[Car]>(metadata: nil, origin: self.type, data: models, error: error)
		completion(result)
	}
}

extension CarRepositoryMock {

	var findCalled: Bool {
		return self.findCallCount > 0
	}

	var findOneCalled: Bool {
		return self.findOneCallCount > 0
	}

	var storeCalled: Bool {
		return self.storeCallCount > 0
	}

	var storeOneCalled: Bool {
		return self.storeOneCallCount > 0
	}

	var updateCalled: Bool {
		return self.updateCallCount > 0
	}

	var updateOneCalled: Bool {
		return self.updateOneCallCount > 0
	}

	var storeOrUpdateCalled: Bool {
		return self.storeOrUpdateCallCount > 0
	}

	var removeCalled: Bool {
		return self.removeCallCount > 0
	}

	var removeOneCalled: Bool {
		return self.removeOneCallCount > 0
	}

	var lastCallParameters: AnyObject? {
		return self.lastParameterUsed
	}
}
