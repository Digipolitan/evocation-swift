//
//  WithSynchronizationTests.swift
//  Evocation
//
//  Created by Julien Sarazin on 06/02/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import Quick
import Nimble

@testable import Evocation

class LocalSynhronizationTests: QuickSpec {

	let remoteMock = CarRepositoryMock(type: .remote)
	let localMock = CarRepositoryMock(type: .local)

	override func spec() {
		describe("Evocation") {
			beforeEach {
                if let remoteWithSync = try? Strategy.Rule(target: .remote, fallback: nil, synchronize: true) {
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
									expect(self.localMock.storeOrUpdateCalled).to(beTrue())
									expect(self.localMock.lastCallParameters as? [Car]).to(equal(result.data))
									done()
								})
						}
					}

					context("and no data is returned from the service") {
						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.find(model: Car.self, criteria: ["id": "unkown_id"], callback: { _ in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}

					context("and the target fails") {
						beforeEach {
							self.remoteMock.set(mode: .failure)
						}

						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.find(model: Car.self, criteria: ["id": "001"], callback: { _ in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}
				}

				context("when trying to use findOne() on the target") {
					it("should call storeOrUpdate with the data returned from the findOne() call") {
						waitUntil { done in
							Evocation.shared
								.findOne(model: Car.self, criteria: ["id": "001"], callback: { (result) -> (Void) in
									expect(self.localMock.storeOrUpdateCalled).to(beTrue())
									expect(self.localMock.lastCallParameters as? [Car]).to(equal([result.data]))
									done()
								})
						}
					}

					context("and no data is returned from the service") {
						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.findOne(model: Car.self, criteria: ["id": "unkown_id"], callback: { _ in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}

					context("and the target fails") {
						beforeEach {
							self.remoteMock.set(mode: .failure)
						}

						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.findOne(model: Car.self, criteria: ["id": "001"], callback: { _ in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}
				}

				context("when trying to use update() on the target") {
					it("should call storeOrUpdate with the data returned from the update() call") {
						waitUntil { done in
							Evocation.shared
								.update([Car(id: "001", model: "updated model", year: 8888)], callback: { (result) -> (Void) in
									expect(self.localMock.storeOrUpdateCalled).to(beTrue())
									expect(self.localMock.lastCallParameters as? [Car]).to(equal(result.data))
									done()
								})
						}
					}

					context("and no data is returned from the service") {
						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.update([Car(id: "unkown_id", model: "updated model", year: 8888)], callback: { _ -> (Void) in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}

					context("and the target fails") {
						beforeEach {
							self.remoteMock.set(mode: .failure)
						}

						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.update([Car(id: "001", model: "updated model", year: 8888)], callback: { _ -> (Void) in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}
				}

				context("when trying to use updateOne() on the target") {
					it("should call storeOrUpdate with the data returned from the updateOne() call") {
						waitUntil { done in
							Evocation.shared
								.updateOne(Car(id: "001", model: "updated model", year: 8888), callback: { (result) -> (Void) in
									expect(self.localMock.storeOrUpdateCalled).to(beTrue())
									expect(self.localMock.lastCallParameters as? [Car]).to(equal([result.data]))
									done()
								})
						}
					}

					context("and no data is returned from the service") {
						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.updateOne(Car(id: "unkown_id", model: "updated model", year: 8888), callback: { _ -> (Void) in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}

					context("and the target fails") {
						beforeEach {
							self.remoteMock.set(mode: .failure)
						}

						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.updateOne(Car(id: "001", model: "updated model", year: 8888), callback: { _ -> (Void) in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}
				}

				context("when trying to use remove() on the target") {
					it("should call remove with the data returned from the updateOne() call") {
						waitUntil { done in
							Evocation.shared
								.remove([Car(id: "001", model: "updated model", year: 8888)], callback: { (result) -> (Void) in
									expect(self.localMock.removeCalled).to(beTrue())
									expect(self.localMock.lastCallParameters as? [Car]).to(equal(result.data))
									done()
								})
						}
					}

					context("and no data is returned from the service") {
						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.updateOne(Car(id: "unkown_id", model: "updated model", year: 8888), callback: { _ -> (Void) in
										expect(self.localMock.storeOrUpdateCalled).to(beFalse())
										done()
									})
							}
						}
					}

					context("and the target fails") {
						beforeEach {
							self.remoteMock.set(mode: .failure)
						}

						it("should NOT call storeOrUpdate") {
							waitUntil { done in
								Evocation.shared
									.updateOne(Car(id: "001", model: "updated model", year: 8888), callback: { _ -> (Void) in
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
}
