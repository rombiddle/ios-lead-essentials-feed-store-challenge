//
//  RealmFeedCache.swift
//  FeedStoreChallenge
//
//  Created by Romain Brunie on 09/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmFeedCache: Object {
	@objc dynamic var id = 0
	var feed = List<RealmFeedImage>()
	@objc dynamic var timestamp = Date()
	
	public override static func primaryKey() -> String? {
		return "id"
	}
	
	public convenience init(feed: [RealmFeedImage], timestamp: Date) {
		self.init()
		self.feed.append(objectsIn: feed)
		self.timestamp = timestamp
	}
	
	public func realmFeedtoLocals() throws -> [LocalFeedImage] {
		try self.feed.map { try $0.toLocal() }
	}
}
