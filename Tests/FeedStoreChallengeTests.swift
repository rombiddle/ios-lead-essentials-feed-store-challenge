//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import RealmSwift

class RealmFeedStore: FeedStore {
	private let realm: Realm
		
	init(realm: Realm) {
		self.realm = realm
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			let confObject = realm.objects(RealmFeedCache.self).first
			if let conf = confObject {
				try realm.write {
					realm.delete(conf)
				}
			}
			completion(nil)
		} catch {
			
		}
		
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		do {
			try realm.write {
				let feed = feed.map { RealmFeedImage(id: $0.id,
													 description: $0.description,
													 location: $0.location,
													 url: $0.url)
				}
				let realmConf = RealmFeedCache(feed: feed, timestamp: timestamp)
				realm.add(realmConf as Object, update: .modified)
			}
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		let realmObject = realm.objects(RealmFeedCache.self).first
		if let conf = realmObject {
			let feed = conf.realmFeedtoLocals()
			completion(.found(feed: feed, timestamp: conf.timestamp))
		} else {
			completion(.empty)
		}
	}
}

class RealmFeedImage: Object {
	@objc dynamic var id: String = ""
	@objc dynamic var rDescription: String? = nil
	@objc dynamic var location: String? = nil
	@objc dynamic var url: String = ""
	
	convenience init(id: UUID, description: String?, location: String?, url: URL) {
		self.init()
		self.id = id.uuidString
		self.rDescription = description
		self.location = location
		self.url = url.absoluteString
	}
	
	func toLocal() -> LocalFeedImage {
		return LocalFeedImage(id: UUID(uuidString: self.id)!,
							  description: self.rDescription,
							  location: self.location,
							  url: URL(string: self.url)!)
	}
}

class RealmFeedCache: Object {
	@objc dynamic var id = 0
	var feed = List<RealmFeedImage>()
	@objc dynamic var timestamp = Date()
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	convenience init(feed: [RealmFeedImage], timestamp: Date) {
		self.init()
		self.feed.append(objectsIn: feed)
		self.timestamp = timestamp
	}
	
	func realmFeedtoLocals() -> [LocalFeedImage] {
		self.feed.map { $0.toLocal() }
	}
}

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
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
//		let sut = try makeSUT()
//
//		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
//		let sut = try makeSUT()
//
//		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
//		let sut = try makeSUT()
//
//		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
//		let sut = try makeSUT()
//
//		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() throws -> FeedStore {
		let sut = RealmFeedStore(realm: testRealmInstance())
		return sut
	}
	
	private func testRealmInstance() -> Realm {
		try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "\(type(of: self))Realm"))
	}

	
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() throws {
////		let sut = try makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() throws {
////		let sut = try makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
