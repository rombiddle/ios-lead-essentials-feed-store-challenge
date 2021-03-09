//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import RealmSwift

class RealmFeedStore: FeedStore {
	private let configuration: Realm.Configuration
		
	init(configuration: Realm.Configuration) {
		self.configuration = configuration
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			let realm = try Realm(configuration: self.configuration)
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
			let realm = try Realm(configuration: self.configuration)
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
		guard let realm = try? Realm(configuration: self.configuration) else {
			return completion(.empty)
		}
		
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
	@objc dynamic var desc: String? = nil
	@objc dynamic var location: String? = nil
	@objc dynamic var url: String = ""
	
	convenience init(id: UUID, description: String?, location: String?, url: URL) {
		self.init()
		self.id = id.uuidString
		self.desc = description
		self.location = location
		self.url = url.absoluteString
	}
	
	func toLocal() -> LocalFeedImage {
		return LocalFeedImage(id: UUID(uuidString: self.id)!,
							  description: self.desc,
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
	
	private func makeSUT(configuration: Realm.Configuration? = nil) throws -> FeedStore {
		let sut = RealmFeedStore(configuration: configuration ?? testRealmConfiguration())
		return sut
	}
	
	private func testRealmConfiguration() -> Realm.Configuration {
		Realm.Configuration(inMemoryIdentifier: "\(type(of: self))Realm")
	}
		
	private func cacheWithInvalidImage() -> RealmFeedCache {
		let invalidImage = RealmFeedImage(value: ["id": "invalidUUID", "desc": nil, "location": nil, "url": "invalidURL"])
		return RealmFeedCache(value: ["feed": [invalidImage], "timestamp": Date()])
	}
	
//	private func insertCacheWithInvalidImageIntoRealm() {
//		let realmInstance = autoreleasepool {
//			return testRealmInstance()
//		}
//		try! realmInstance.write {
//			realmInstance.add(cacheWithInvalidImage())
//		}
//	}
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
