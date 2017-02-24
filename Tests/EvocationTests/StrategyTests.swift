//
//  EvocationTests.swift
//  EvocationTests
//
//  Created by Julien Sarazin on 26/01/2017.
//  Copyright © 2017 Digipolitan. All rights reserved.
//

import Quick
import Nimble

@testable import Evocation

class StrategyTests: QuickSpec {
	override func spec() {
		describe("an invalid rule") {
			context("when the target and the fallback are the same") {
				it("should throw an invalidRule error") {
					expect {
						return try Strategy.Rule(target: .remote, fallback: .remote, synchronize: true)
						}
						.to(throwError(StrategyError.invalidRule))
				}
			}
		}

		describe("an incomplete strategy") {
			context("when an action does not have a rule associated") {
				it("should throw an incompleteConfiguration error") {
					expect {
                        if let rule = try? Strategy.Rule(target: .remote, fallback: nil, synchronize: false) {
                            return try Strategy(rules: [
                                .find: rule
                            ])
                        }
                        return nil
                    }
                    .to(throwError(StrategyError.incompleteConfiguration))
				}
			}
		}
	}
}
