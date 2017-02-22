//
//  Car.swift
//  Evocation
//
//  Created by Julien Sarazin on 27/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import Foundation

class Car {

	private(set) var id: String
	var model: String
	var year: Int

	init(model: String, year: Int) {
		self.id = UUID().uuidString
		self.model = model
		self.year = year
	}

	convenience init(id: String, model: String, year: Int) {
		self.init(model: model, year: year)
		self.id = id
		self.model = model
		self.year = year
    }

    fileprivate static var db: [Car] = [
		Car(id: "001", model: "Peugeot 508", year: 2011),
		Car(id: "002", model: "Jaguar", year: 1998),
		Car(id: "003", model: "Renault Super 5", year: 1988),
		Car(id: "004", model: "Citroen C3", year: 2001),
		Car(id: "005", model: "Mazda", year: 2002),
		Car(id: "006", model: "BMW M3", year: 2002),
		Car(id: "007", model: "Prosche 911", year: 2002),
		Car(id: "008", model: "Mercedes class A", year: 2002),
		Car(id: "009", model: "Aigo", year: 2002),
		Car(id: "010", model: "Bentley", year: 2002),
		Car(id: "011", model: "Mazerati", year: 2002),
		Car(id: "012", model: "Dacia", year: 2002),
		Car(id: "013", model: "Seat Ibiza", year: 2002)
	]
}

extension Car: CustomStringConvertible {
	var description: String {
		return "(model: \(self.model), year: \(self.year))"
	}
}

extension Car: Equatable {
	static func == (lhs: Car, rhs: Car) -> Bool {
		return lhs.id == rhs.id
	}
}

// Stubing DB
extension Car {
	static func resetDB() {
		self.db =  [
			Car(id: "001", model: "Peugeot 508", year: 2011),
			Car(id: "002", model: "Jaguar", year: 1998),
			Car(id: "003", model: "Renault Super 5", year: 1988),
			Car(id: "004", model: "Citroen C3", year: 2001),
			Car(id: "005", model: "Mazda", year: 2002),
			Car(id: "006", model: "BMW M3", year: 2002),
			Car(id: "007", model: "Prosche 911", year: 2002),
			Car(id: "008", model: "Mercedes class A", year: 2002),
			Car(id: "009", model: "Aigo", year: 2002),
			Car(id: "010", model: "Bentley", year: 2002),
			Car(id: "011", model: "Mazerati", year: 2002),
			Car(id: "012", model: "Dacia", year: 2002),
			Car(id: "013", model: "Seat Ibiza", year: 2002)
		]
	}

	static func findOne(criteria: [String: Any]?) -> Car? {
		let cars: [Car]? = Car.db.filter { (car) -> Bool in
			var matching = true
			if matching && criteria?["id"] != nil, let id = criteria!["id"] as? String {
				matching = car.id == id
			}

			if matching && criteria?["model"] != nil, let model = criteria!["model"] as? String {
				matching = car.model == model
			}
			if matching && criteria?["year"] != nil, let year = criteria!["id"] as? Int {
				matching = car.year == year
			}
			return matching
		}

		return cars?.first
	}

	static func find(criteria: [String: Any]?) -> [Car]? {
		let cars: [Car]? = Car.db.filter { (car) -> Bool in
			var matching = true
			if matching && criteria?["id"] != nil, let id = criteria!["id"] as? String {
				matching = car.id == id
			}

			if matching && criteria?["model"] != nil, let model = criteria!["model"] as? String {
				matching = car.model == model
			}
			if matching && criteria?["year"] != nil, let year = criteria!["year"] as? Int {
				matching = car.year == year
			}
			return matching
		}

		return cars
	}

	static func store(cars: [Car]) -> [Car]? {
		Car.db.append(contentsOf: cars)
		return nil // arbitrary, could return the stored cars, or nothing.
	}

	static func storeOne(car: Car) -> Car? {
		Car.db.append(car)
		return nil // idem
	}

	static func update(cars: [Car]) -> [Car]? {
		var updates = [Car]()
		db.forEach { (original) in
			cars.forEach({ (updated) in
				if original == updated {
					original.model = updated.model
					original.year = updated.year
					updates.append(updated)
				}
			})
		}

		return updates.count > 0 ? updates : nil
	}

	static func updateOne(car: Car) -> Car? {
		var found = false
		db.forEach { (original) in
			if original == car {
				original.model = car.model
				original.year = car.year
				found = true
			}
		}

		return found ? car : nil
	}

	static func remove(criteria: [String: Any]?) {
		let cars: [Car]? = Car.db.filter { (car) -> Bool in
			var matching = true
			if matching && criteria?["id"] != nil, let id = criteria!["id"] as? String {
				matching = car.id == id
			}

			if matching && criteria?["model"] != nil, let model = criteria!["model"] as? String {
				matching = car.model == model
			}
			if matching && criteria?["year"] != nil, let year = criteria!["year"] as? Int {
				matching = car.year == year
			}
			return matching
		}

		cars?.forEach({ (car) in
			Car.db.remove(at: Car.db.index(of: car)!)
		})
	}
}
