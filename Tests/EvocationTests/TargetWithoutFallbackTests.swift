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

class TargetWithoutFallbackTests: QuickSpec {

	let remoteMock	= CarRepositoryMock(type: .remote, mode: .success)

	override func spec() {
		describe("Evocation") {
			beforeEach {
                guard let remoteOnly = try? Strategy.Rule(target: .remote, fallback: nil, synchronize: false) else {
                    return
                }
                if let strategy = try? Strategy(rules: [
					.find: remoteOnly,
					.findOne: remoteOnly,
					.store: remoteOnly,
					.storeOne: remoteOnly,
					.update: remoteOnly,
					.updateOne: remoteOnly,
					.remove: remoteOnly,
					.removeOne: remoteOnly
                    ]) {
                    Evocation.shared
                        .register(for: Car.self)
                        .repository(remote: self.remoteMock)
                        .strategy(strategy)
                }
			}

			describe("properly configured with a remote target") {
				afterEach {
					self.remoteMock.reset()
				}

				context("when trying to use find()") {
					it("should use the remote service") {
						waitUntil { done in
							Evocation.shared
								.find(model: Car.self, callback: { _ -> (Void) in
									expect(self.remoteMock.findCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use the findOne()") {
					it("should use the remote service ") {
						waitUntil { done in
							Evocation.shared
								.findOne(model: Car.self, criteria: ["year": 2002], callback: { _ -> (Void) in
									expect(self.remoteMock.findOneCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use the store()") {
					it("should use the remote service ") {
						waitUntil { done in
							Evocation.shared
								.store([Car(model: "model 1", year: 1987), Car(model: "model 2", year: 2087)], callback: { _ -> (Void) in
									expect(self.remoteMock.storeCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use storeOne()") {
					it("should use the remote service ") {
						waitUntil { done in
							Evocation.shared
								.storeOne(Car(model: "model 1", year: 2222), callback: { _ -> (Void) in
									expect(self.remoteMock.storeOneCalled).to(beTrue())
									done()
								})
						}
					}

				}

				context("when trying to use update()") {
					it("should use the remote service ") {
						waitUntil { done in
							Evocation.shared
								.update([Car(id: "1234", model: "model updated", year: 8888)], callback: { _ -> (Void) in
									expect(self.remoteMock.updateCalled).to(beTrue())
									done()
								})
						}
					}
				}

				context("when trying to use updateOne()", {
					it("should use the remote service ") {
						waitUntil { done in
							Evocation.shared
								.updateOne(Car(id: "1234", model: "model updated", year: 8888), callback: { _ -> (Void) in
									expect(self.remoteMock.updateOneCalled).to(beTrue())
									done()
								})
						}
					}
				})

				context("when trying to use remove()", {
					it("should use the remote service ") {
						waitUntil { done in
							Evocation.shared
								.remove([Car(id: "1234", model: "model", year: 8888)], callback: { _ -> (Void) in
									expect(self.remoteMock.removeCalled).to(beTrue())
									done()
								})
						}
					}
				})
			}
		}
	}
}
