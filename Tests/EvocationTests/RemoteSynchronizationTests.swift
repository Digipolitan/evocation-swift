//
//  RemoteSynchronizationTests.swift
//  Evocation
//
//  Created by Julien Sarazin on 06/02/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import Quick
import Nimble

@testable import Evocation

class RemoteSynhronizationTests: QuickSpec {

	let remoteMock	= CarRepositoryMock(type: .remote)
	let localMock	= CarRepositoryMock(type: .local)

	override func spec() {
		describe("Evocation") {
            guard let remoteWithSync = try? Strategy.Rule(target: .local, fallback: nil, synchronize: true) else {
                return
            }
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
                        .repository(remote: self.remoteMock)
                        .repository(local: self.localMock)
                        .strategy(strategy)
                }
			}

			describe("configured with a target, no fallback and a synchronization") {
				afterEach {
					self.remoteMock.reset()
					self.localMock.reset()
				}

				context("when trying to use find() on the target") {
					it("should call storeOrUpdate() with the data returned from the find() call") {
						waitUntil { done in
							Evocation.shared
								.find(model: Car.self, criteria: ["id": "001"], callback: { (result) -> (Void) in
									expect(self.remoteMock.storeOrUpdateCalled).to(beTrue())
									expect(self.remoteMock.lastCallParameters as? [Car]).to(equal(result.data))
									done()
								})
						}
					}

					it("should NOT call storeOrUpdate if no data is returned from the find() call") {
						waitUntil { done in
							Evocation.shared
								.find(model: Car.self, criteria: ["id": "unkown_id"], callback: { _ in
									expect(self.remoteMock.storeOrUpdateCalled).to(beFalse())
									done()
								})
						}
					}
				}

				context("when trying to use findOne() on the target") {
					it("should call storeOrUpdateOne with the data returned from the findOne() call") {
						waitUntil { done in
							Evocation.shared
								.findOne(model: Car.self, criteria: ["id": "001"], callback: { (result) -> (Void) in
									expect(self.remoteMock.storeOrUpdateCalled).to(beTrue())
									expect(self.remoteMock.lastCallParameters as? [Car]).to(equal([result.data]))
									done()
								})
						}
					}

					it("should NOT call storeOrUpdate if no data is returned from the find() call") {
						waitUntil { done in
							Evocation.shared
								.findOne(model: Car.self, criteria: ["id": "unkown_id"], callback: { _ in
									expect(self.remoteMock.storeOrUpdateCalled).to(beFalse())
									done()
								})
						}
					}
				}

				context("when trying to use update() on the target") {
					it("should call storeOrUpdateOne with the data returned from the update() call") {
						waitUntil { done in
							Evocation.shared
								.update([Car(id: "001", model: "updated model", year: 8888)], callback: { (result) -> (Void) in
									expect(self.remoteMock.storeOrUpdateCalled).to(beTrue())
									expect(self.remoteMock.lastCallParameters as? [Car]).to(equal(result.data))
									done()
								})
						}
					}

					it("should NOT call storeOrUpdate if no data is returned from the update() call") {
						waitUntil { done in
							Evocation.shared
								.update([Car(id: "unkown_id", model: "updated model", year: 8888)], callback: { _ -> (Void) in
									expect(self.remoteMock.storeOrUpdateCalled).to(beFalse())
									done()
								})
						}
					}
				}

				context("when trying to use updateOne() on the target") {
					it("should call storeOrUpdateOne with the data returned from the updateOne() call") {
						waitUntil { done in
							Evocation.shared
								.updateOne(Car(id: "001", model: "updated model", year: 8888), callback: { (result) -> (Void) in
									expect(self.remoteMock.storeOrUpdateCalled).to(beTrue())
									expect(self.remoteMock.lastCallParameters as? [Car]).to(equal([result.data]))
									done()
								})
						}
					}

					it("should NOT call storeOrUpdate if no data is returned from the updateOne() call") {
						waitUntil { done in
							Evocation.shared
								.updateOne(Car(id: "unkown_id", model: "updated model", year: 8888), callback: { _ -> (Void) in
									expect(self.localMock.storeOrUpdateCalled).to(beFalse())
									done()
								})
						}
					}
				}
			}
		}
	}
}
