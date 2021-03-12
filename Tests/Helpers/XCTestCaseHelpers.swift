//
//  XCTestCase+MemoryLeakTracking.swift
//  Tests
//
//  Created by Romain Brunie on 09/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import RealmSwift

extension XCTestCase {
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}

	func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
}

