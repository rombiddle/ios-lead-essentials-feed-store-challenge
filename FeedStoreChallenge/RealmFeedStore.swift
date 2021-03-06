//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Romain Brunie on 09/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmFeedStore: FeedStore {
	private let queue = DispatchQueue(label: "\(RealmFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
	private let configuration: Realm.Configuration
		
	public init(configuration: Realm.Configuration) {
		self.configuration = configuration
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async(flags: .barrier) {
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
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		queue.async(flags: .barrier) {
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
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		queue.async {
			do {
				let realm = try Realm(configuration: self.configuration)
				let realmObject = realm.objects(RealmFeedCache.self).first
				if let conf = realmObject {
					let feed = try conf.realmFeedtoLocals()
					completion(.found(feed: feed, timestamp: conf.timestamp))
				} else {
					completion(.empty)
				}
			} catch Realm.Error.filePermissionDenied, Realm.Error.fileAccess {
				completion(.empty)
			} catch {
				completion(.failure(error))
			}
		}
	}
}
