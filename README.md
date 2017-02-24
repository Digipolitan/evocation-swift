Evocation
================

[![Build Status](https://travis-ci.org/Digipolitan/evocation-swift.svg?branch=master)](https://travis-ci.org/Digipolitan/evocation-swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Evocation.svg)](https://img.shields.io/cocoapods/v/Evocation.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Evocation.svg?style=flat)](http://cocoadocs.org/docsets/Evocation.svg)
[![Twitter](https://img.shields.io/badge/twitter-@Digipolitan-blue.svg?style=flat)](http://twitter.com/Digipolitan)

> `Evocation` is a component which allows you to do **remote** and **local** CRUD operations.

Those CRUD operations must be done through **one single API**. 

### 1 - Concept
The main goal is to provide CRUD methods for each registered models. 

```swift
	/**
	Fetch and return the first item matching the criteria.
	*/
	func findOne<T>(model: T.Type, criteria: [String: Any]?, callback: @escaping (Result<T>) -> (Void))
	/**
	Fetch and return all items matching the criteria.
	*/
	func find<T>(model: T.Type, criteria: [String: Any]? = nil, callback: @escaping (Result<[T]>) -> (Void))
	/**
	Create and persist a collection of T.
	*/
	func store<T>(_ models: [T], callback: @escaping (Result<[T]>) -> (Void)) 
	/**
	Create and persist an instance of a T.
	*/
	func storeOne<T>(_ model: T, callback: @escaping (Result<T>) -> (Void)) 
	/**
	Update an instance of T
	*/
	func update<T>(_ models: [T], callback: @escaping (Result<[T]>) -> (Void)) 
	/**
	Update an instance of T
	*/
	func updateOne<T>(_ model: T, callback: (Result<T>) -> (Void))
	/**
	Remove items 
	*/
	func remove<T>(_ models: [T], callback: (Result<[T]>) -> (Void))
	
```

To achieve this, we are using a Design Pattern (DP) called [Repository](https://msdn.microsoft.com/en-us/library/ff649690.aspx). 
Our `Repository` is a protocol that define the methods to implement for your local and remote datasource.

```swift
/**
* Protocol that defines methods to implement for a Model's repository.
*/
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
``` 

The benefit of the `associatedtype` allows us to directly infer the type to be managed.

Two other parameters presented here are,`criteria` which allows you to target specific entities and` Result <T> ` which contains the targeted entity with some meta information about, the origin of the data:

```swift
open class Result<T> {
	public var metadata: [Evocation.RepositoryType: [String: AnyObject]]
	public var data: T?
	public var origin: Evocation.RepositoryType?
	public var error: Error?
	...
}
```

### 2 - Initialization
> As a reminder, the purpose of the library is to provide a common interface for data management whether the source is remote (** Webservice **) or local (** Database **).

- `Evocation`, the singleton which will be the common interface.
- `Proxy <T>`, which will maintain the repositories for a given model. This proxy will be subject to management templates that can be configured via `Strategies`
- `Strategy`, The configuration Object which define the behavior of the proxy.
- `Repository <T>`, which is the interface we presented previously.

Below is an explanation of the general operation:
//TODO: inset schema


- Registering `local` and `remote` for a model `Foo`.

    ```swift     
		Evocation.shared
			.register(for: Foo.self)
			.repository(remote: FooWebService())
			.repository(local: FooLocalStorage())
			.strategy(strategy)
    ```

- Defining a `Strategy`

Sometimes you might want to target the webservice and back the results in a local database. 

Sometimes you might want to target a local database and backup time to time the data through a webservice.

These behaviors can be defined through a combinaison of Rules

```swift
let localFirst  = Strategy.Rule(target: .local, fallback: .remote, synchronize: true)
let remoteFirst = Strategy.Rule(target: .remote, fallback: .local, synchronize: false)

let strategy = Strategy(remoteFirst)

guard let strategy2 = try? Strategy(rules: [
			.find: remoteFirst,
			.findOne: remoteFirst,
			.store: localFirst,
			.storeOne: localFirst,
			.update: localFirst,
			.updateOne: localFirst,
			.remove: remoteFirst,
			.removeOne: remoteFirst
	])
else { return }
```

Here the `target` is the first repository that will be targeted. The `fallback` will be used in case the target fail. The `synchronize` option tells if you want to do write operation on both datasource.

You can either configure a strategy with the same rule for all action, of decide to apply specific rule for each action.



### 3 - Use case (simple)
- Configuration

```swift
let strategy = Strategy.default()

Evocation.shared
	.register(for: Foo.self)
	.repository(remote: FooWS())
	.repository(local: FooDS())
	.strategy(strategy)
```
- Usage when connexion is up

```swift     
/**
* Status: Connexion UP 
*/
Evocation.find(model: Foo.self, criteria: nil) { result in 
    guard result.error == nil else {
        // notify an error has been raised
        return
    }
    
    var foos: [Foo] = result.data
    print(result.origin) // should print "remote" since we have a connexion.
}
```

- Usage when connexion is down

```swift
/**
* Status: Connexion DOWN 
*/
Evocation.find(model: Foo.self, criteria: nil) { result in 
    guard result.error == nil else {
        // notify an error has been raised
        return
    }
    
    var foos: [Foo] = result.data
    print(result.origin) // should print "local" since we don't have a connexion.
}
```




### 4 - IMPORTANT
> This tool is at a very early stage. It might have some breaking changes in the futur. To have more information about how the library works, you might want to check the test cases.
 


## Built With

[Fastlane](https://fastlane.tools/)
Fastlane is a tool for iOS, Mac, and Android developers to automate tedious tasks like generating screenshots, dealing with provisioning profiles, and releasing your application.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [contact@digipolitan.com](mailto:contact@digipolitan.com).

## License

Evocation is licensed under the [BSD 3-Clause license](LICENSE).
