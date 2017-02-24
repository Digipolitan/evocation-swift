//
//  Proxy.swift
//  Evocation
//
//  Created by Julien Sarazin on 26/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

/**
* Proxy will hold the repositories (remote and local) for a model.
* Thus `Evocation` will be able to retrieve each repository when
*/
open class Proxy<T> {

	private(set) var strategy: Strategy
	private var remoteRepository: AnyRepository<T>?
	private var localRepository: AnyRepository<T>?

	public var local: AnyRepository<T>? {
		return self.localRepository
	}

	public var remote: AnyRepository<T>? {
		return self.remoteRepository
	}

	public init(_ strategy: Strategy? = nil) {
		self.strategy = strategy ?? Strategy.default()
	}

	public func repository<R: Repository>(remote: R) -> Self
		where R.ModelType == T {
			self.remoteRepository = AnyRepository<T>(remote)
			return self
	}

	public func repository<R: Repository>(local: R) -> Self
		where R.ModelType == T {
			self.localRepository = AnyRepository<T>(local)
			return self
	}

	@discardableResult
	public func strategy(_ strategy: Strategy) -> Self {
		self.strategy = strategy
		return self
	}
}
