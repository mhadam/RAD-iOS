//
//  ConvertTimeRangeTestCase.swift
//  RADTests
//
//  Copyright 2018 NPR
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//  this file except in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

import XCTest
import AVFoundation
import OHHTTPStubs
@testable import RAD

class ConvertTimeRangeTestCase: AnalyticsTestCase, RADExtractionTestCase {
    override var configuration: Configuration {
        return Configuration(
            submissionTimeInterval: .seconds(10),
            batchSize: 10,
            expirationTimeInterval: DateComponents(day: 1),
            sessionExpirationTimeInterval: .hours(24),
            requestHeaderFields: [:])
    }

    func testEventsGeneration() {
        let item: AVPlayerItem! = findResource(name: "480Events")

        let requestExpectation = self.expectation(
            description: "Request did fail.")
        requestExpectation.assertForOverFulfill = false

        OHHTTPStubs.stubRequests(
            passingTest: checkUrlClosure,
            withStubResponse: { _ -> OHHTTPStubsResponse in
                requestExpectation.fulfill()
                return OHHTTPStubsResponse(
                    jsonObject: [:], statusCode: 500, headers: nil)
        })

        play(item: item, for: .seconds(3.2))

        wait(for: [requestExpectation], timeout: .seconds(30))

        checkEvents(for: item)
    }

    private func checkEvents(for item: AVPlayerItem) {
        guard let context = Storage.shared?.mainQueueContext else {
            XCTFail("Context is not available")
            return
        }
        guard let md5 = extractMD5(from: item) else {
            XCTFail("MD5 is not available.")
            return
        }
        let eventsExpectation = self.expectation(
            description: "Events are checked.")
        let fetchEvents = FetchOperation<Event>(context: context)
        fetchEvents.input = NSPredicate(
            format: "md5 == '\(md5)'", argumentArray: nil)
        let completion = ClosureInputOperation<[Event]>(closure: { events in
            XCTAssert(
                events.count == 13,
                "Expected number of events were not created.")
            eventsExpectation.fulfill()
        })
        fetchEvents.chainOperation(with: completion)

        concurrentQueue.addOperations(
            [fetchEvents, completion], waitUntilFinished: false)
        wait(for: [eventsExpectation], timeout: .seconds(20))
    }
}
