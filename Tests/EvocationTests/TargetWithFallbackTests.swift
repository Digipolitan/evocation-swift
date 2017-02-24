//
//  RemoteWithoutFallbackTests.swift
//  Evocation
//
//  Created by Julien Sarazin on 31/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import Quick
import Nimble

@testable import Evocation

class TargeteWithFallbackTests: QuickSpec {

	let targetMock	= CarRepositoryMock(type: .remote, mode: .failure)
	let fallbackMock	= CarRepositoryMock(type: .local, mode: .success)

	override func spec() {
		describe("Evocation") {
			beforeEach {
                guard let remoteFirst = try? Strategy.Rule(target: .remote, fallback: .local, synchronize: false) else {
                    return
                }

				if let strategy = try? Strategy(rules: [
					.find: remoteFirst,
					.findOne: remoteFirst,
					.store: remoteFirst,
					.storeOne: remoteFirst,
					.update: remoteFirst,
					.updateOne: remoteFirst,
					.remove: remoteFirst,
					.removeOne: remoteFirst
                    ]) {
                    Evocation.shared
                        .register(for: Car.self)
                        .repository(remote: self.targetMock)
                        .repository(local: self.fallbackMock)
                        .strategy(strategy)
                }
			}

			describe("configured with remote target and a local fallback") {
				afterEach {
					self.targetMock.reset()
					self.fallbackMock.reset()
				}

				context("when trying to use find() on the target but the target fail") {
					it("should call the fallback") {
						waitUntil { done in
							Evocation.shared
								.find(model: Car.self, callback: { _ -> (Void) in
									expect(self.targetMock.findCalled).to(beTrue())
									expect(self.fallbackMock.findCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use findOne() on the target but the target fail") {
					it("should call the fallback") {
						waitUntil { done in
							Evocation.shared
								.findOne(model: Car.self, criteria: ["year": 2002], callback: { _ -> (Void) in
									expect(self.targetMock.findOneCalled).to(beTrue())
									expect(self.fallbackMock.findOneCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use store() on the target but the target fail") {
					it("should call the fallback") {
						waitUntil { done in
							Evocation.shared
								.store([Car(model: "model 1", year: 1987), Car(model: "model 2", year: 2087)], callback: { _ -> (Void) in
									expect(self.targetMock.storeCalled).to(beTrue())
									expect(self.fallbackMock.storeCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use storeOne() on the target but the target fail") {
					it("should call the fallback") {
						waitUntil { done in
							Evocation.shared
								.storeOne(Car(model: "model 1", year: 2222), callback: { _ -> (Void) in
									expect(self.targetMock.storeOneCalled).to(beTrue())
									expect(self.fallbackMock.storeOneCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use update() on the target but the target fail") {
					it("should call the fallback") {
						waitUntil { done in
							Evocation.shared
								.update([Car(id: "1234", model: "model updated", year: 8888)], callback: { _ -> (Void) in
									expect(self.targetMock.updateCalled).to(beTrue())
									expect(self.fallbackMock.updateCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use updateOne() on the target but the target fail", {
					it("should use the fallback") {
						waitUntil { done in
							Evocation.shared
								.updateOne(Car(id: "1234", model: "model updated", year: 8888), callback: { _ -> (Void) in
									expect(self.targetMock.updateOneCalled).to(beTrue())
									expect(self.targetMock.updateOneCallCount).to(equal(1))
									done()
								})
						}
					}
				})

				context("when trying to use remove() on the target but the target fail", {
					it("should use the fallback") {
						waitUntil { done in
							Evocation.shared
								.remove([Car(id: "1234", model: "model updated", year: 8888)], callback: { _ -> (Void) in
									expect(self.targetMock.removeCalled).to(beTrue())
									expect(self.fallbackMock.removeCalled).to(beTrue())
									done()
								})
						}
					}
				})
			}
		}
	}
}
