//
//  MissingRepositories.swift
//  Evocation
//
//  Created by Julien Sarazin on 06/02/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import Quick
import Nimble

@testable import Evocation

class MissingRespositoriesTests: QuickSpec {

	let failureMock	= CarRepositoryMock(type: .remote, mode: .failure)
	let successMock = CarRepositoryMock(type: .remote)

	override func spec() {

        guard
            let remoteThenLocal = try? Strategy.Rule(target: .remote, fallback: .local, synchronize: false),
            let remoteWithSync	= try? Strategy.Rule(target: .remote, fallback: nil, synchronize: true) else {
                return
        }

		describe("Evocation") {
			describe("configured with a remote target and a local fallback but forgot to set the local repository for the registered model") {

				beforeEach {
					if let strategy = try? Strategy(rules: [
						.find: remoteThenLocal,
						.findOne: remoteThenLocal,
						.store: remoteThenLocal,
						.storeOne: remoteThenLocal,
						.update: remoteThenLocal,
						.updateOne: remoteThenLocal,
						.remove: remoteThenLocal,
						.removeOne: remoteThenLocal
                        ]) {
                        Evocation.shared
                            .register(for: Car.self)
                            .repository(remote: self.failureMock)
                            .strategy(strategy)
                    }
				}

				afterEach {
					self.failureMock.reset()
				}

				context("when trying to use a method on the target and the target fail") {
					it("should return an error of type `MissingRepository`") {
						waitUntil { done in
							Evocation.shared
								.find(model: Car.self, criteria: ["id": "001"], callback: { (result) -> (Void) in
									expect(result.error?.localizedDescription).to(equal(EvocationError.missingRepository(type: .local, for: Car.self).localizedDescription))
									done()
								})
						}
					}
				}
			}

			describe("configured with a remote target and a synchronization, but forgot to set the local repository for the registered model") {
				beforeEach {
					if let strategy = try? Strategy(rules: [
						.find: remoteWithSync,
						.findOne: remoteWithSync,
						.store: remoteWithSync,
						.storeOne: remoteWithSync,
						.update: remoteWithSync,
						.updateOne: remoteWithSync,
						.remove: remoteWithSync,
						.removeOne: remoteWithSync
                        ]) {
                        Evocation.shared
                            .register(for: Car.self)
                            .repository(remote: self.successMock)
                            .strategy(strategy)
                    }
				}

				afterEach {
					self.successMock.reset()
				}

				context("when trying to use a method on the target and the target returns results that must be synchronize") {
					it("should return an error of type `MissingRepository`") {
						waitUntil { done in
							Evocation.shared
								.find(model: Car.self, criteria: ["id": "001"], callback: { (result) -> (Void) in
									expect(result.error?.localizedDescription).to(equal(EvocationError.missingRepository(type: .local, for: Car.self).localizedDescription))
									done()
								})
						}
					}
				}
			}
		}
	}
}
