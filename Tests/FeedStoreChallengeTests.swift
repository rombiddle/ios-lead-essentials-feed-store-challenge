//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import RealmSwift

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		try setupEmptyStoreState()
	}
	
	override func tearDownWithError() throws {
		try undoStoreSideEffects()
		
		try super.tearDownWithError()
	}
	
	//  ***********************
	//
	//  Follow the TDD process:
	//
	//  1. Uncomment and run one test at a time (run tests with CMD+U).
	//  2. Do the minimum to make the test pass and commit.
	//  3. Refactor if needed and commit again.
	//
	//  Repeat this process until all tests are passing.
	//
	//  ***********************
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = try makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
		let sut = try makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
		let sut = try makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT(configuration: Realm.Configuration? = nil, file: StaticString = #filePath, line: UInt = #line) throws -> FeedStore {
		let sut = RealmFeedStore(configuration: configuration ?? testRealmConfiguration())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func setupEmptyStoreState() throws {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() throws {
		deleteStoreArtifacts()
	}
			
	private func cacheWithInvalidImage() -> RealmFeedCache {
		let invalidImage = RealmFeedImage(value: ["id": "invalidUUID", "desc": nil, "location": nil, "url": "invalidURL"])
		return RealmFeedCache(value: ["feed": [invalidImage], "timestamp": Date()])
	}
	
	private func insertCacheWithInvalidImageIntoRealm() {
		let realm = try! Realm(configuration: testRealmConfiguration())
		
		try! realm.write {
			realm.add(cacheWithInvalidImage())
		}
	}
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {

	func test_retrieve_deliversFailureOnRetrievalError() throws {
		let sut = try makeSUT()
		
		insertCacheWithInvalidImageIntoRealm()

		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnFailure() throws {
		let sut = try makeSUT()
		
		insertCacheWithInvalidImageIntoRealm()

		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
	}

}

extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {

	func test_insert_deliversErrorOnInsertionError() throws {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let conf = Realm.Configuration(fileURL: invalidStoreURL)
		let sut = try makeSUT(configuration: conf)

		assertThatInsertDeliversErrorOnInsertionError(on: sut)
	}

	func test_insert_hasNoSideEffectsOnInsertionError() throws {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let conf = Realm.Configuration(fileURL: invalidStoreURL)
		let sut = try makeSUT(configuration: conf)

		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
	}

}

extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {

	func test_delete_deliversErrorOnDeletionError() throws {
		let noDeletePermissionURL = cachesDirectory()
		let conf = Realm.Configuration(fileURL: noDeletePermissionURL)
		let sut = try makeSUT(configuration: conf)

		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
	}

	func test_delete_hasNoSideEffectsOnDeletionError() throws {
		let noDeletePermissionURL = cachesDirectory()
		let conf = Realm.Configuration(fileURL: noDeletePermissionURL)
		let sut = try makeSUT(configuration: conf)

		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
	}

}
