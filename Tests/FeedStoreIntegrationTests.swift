//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import RealmSwift

class FeedStoreIntegrationTests: XCTestCase {
	
	//  ***********************
	//
	//  Uncomment and implement the following tests if your
	//  implementation persists data to disk (e.g., CoreData/Realm)
	//
	//  ***********************
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		try setupEmptyStoreState()
	}
	
	override func tearDownWithError() throws {
		try undoStoreSideEffects()
		
		try super.tearDownWithError()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
//		let sut = try makeSUT()
//
//		expect(sut, toRetrieve: .empty)
	}
	
	func test_retrieve_deliversFeedInsertedOnAnotherInstance() throws {
//		let storeToInsert = try makeSUT()
//		let storeToLoad = try makeSUT()
//		let feed = uniqueImageFeed()
//		let timestamp = Date()
//
//		insert((feed, timestamp), to: storeToInsert)
//
//		expect(storeToLoad, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_insert_overridesFeedInsertedOnAnotherInstance() throws {
//		let storeToInsert = try makeSUT()
//		let storeToOverride = try makeSUT()
//		let storeToLoad = try makeSUT()
//
//		insert((uniqueImageFeed(), Date()), to: storeToInsert)
//
//		let latestFeed = uniqueImageFeed()
//		let latestTimestamp = Date()
//		insert((latestFeed, latestTimestamp), to: storeToOverride)
//
//		expect(storeToLoad, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}
	
	func test_delete_deletesFeedInsertedOnAnotherInstance() throws {
//		let storeToInsert = try makeSUT()
//		let storeToDelete = try makeSUT()
//		let storeToLoad = try makeSUT()
//
//		insert((uniqueImageFeed(), Date()), to: storeToInsert)
//
//		deleteCache(from: storeToDelete)
//
//		expect(storeToLoad, toRetrieve: .empty)
	}
	
	// - MARK: Helpers
	
	private func makeSUT(configuration: Realm.Configuration? = nil, file: StaticString = #filePath, line: UInt = #line) throws -> FeedStore {
		let sut = RealmFeedStore(configuration: configuration ?? testRealmConfiguration())
		trackForMemoryLeaks(sut)
		return sut
	}
	
	private func setupEmptyStoreState() throws {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() throws {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func testRealmConfiguration() -> Realm.Configuration {
		Realm.Configuration(fileURL: testSpecificStoreURL())
	}
		
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self))RealmStore")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
	
}
