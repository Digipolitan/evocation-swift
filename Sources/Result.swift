//
//  Result.swift
//  Evocation
//
//  Created by Julien Sarazin on 26/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

open class Result<T> : NSCopying {

	public var metadata: [Evocation.RepositoryType: [String: AnyObject]]
	public var data: T?
	public var origin: Evocation.RepositoryType?
	public var error: Error?

	public init(metadata: [Evocation.RepositoryType: [String: AnyObject]]? = nil, origin: Evocation.RepositoryType? = nil, data: T? = nil, error: Error? = nil) {
		self.metadata = metadata ?? [.remote: [String: AnyObject](), .local: [String: AnyObject]()]
		self.data = data
		self.origin = origin
		self.error = error
	}

	public func copy(with zone: NSZone? = nil) -> Any {
		return Result<T>(metadata: self.metadata, origin: self.origin, data: self.data, error: self.error)
	}
}
