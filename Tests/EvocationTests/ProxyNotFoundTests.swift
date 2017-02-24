//
//  ProxyNotFoundTests.swift
//  Evocation
//
//  Created by Julien Sarazin on 06/02/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import Quick
import Nimble

@testable import Evocation

class ProxyNotFoundTests: QuickSpec {
	let mock = CarRepositoryMock(type: .remote, mode: .failure)

	override func spec() {
		describe("Evocation") {
			describe("configured with a remote registered for a model X") {

				Evocation.shared
					.register(for: Car.self)
					.repository(remote: self.mock)
					.strategy(Strategy.default())

				context("when trying to use a method for the model Y") {
					it("should return an error of type `ProxyNotFoundError`") {
						waitUntil { done in
							Evocation.shared
								.find(model: User.self, criteria: ["id": "001"], callback: { (result) -> (Void) in
									expect(result.error?.localizedDescription).to(equal(EvocationError.proxyNotFound(for: User.self).localizedDescription))
									done()
								})
						}
					}
				}
			}
		}
	}
}
